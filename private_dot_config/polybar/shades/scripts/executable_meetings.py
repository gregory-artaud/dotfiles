#!/usr/bin/env python3
import os
import time
import re
from datetime import datetime, timedelta
import inotify.adapters

ICON_NOW = " "
ICON_INCOMING = " "
ICON_FINISHED = " "
ICON_SEPARATOR = "  "
ICON_NO_MEETINGS = "󱁖 "


def get_relative_time(dt):
    now = datetime.now()
    diff = dt - now
    total_minutes = round(diff.total_seconds() / 60)
    if total_minutes > 0:
        if total_minutes >= 1440:
            days, remaining_minutes = divmod(total_minutes, 1440)
            hours, minutes = divmod(remaining_minutes, 60)
            return f"(in {days}d {hours}h {minutes}m)"
        elif total_minutes >= 60:
            hours, minutes = divmod(total_minutes, 60)
            return f"(in {hours}h {minutes}m)"
        else:
            return f"(in {total_minutes}m)"
    else:
        total_minutes = abs(total_minutes)
        if total_minutes >= 1440:
            days, remaining_minutes = divmod(total_minutes, 1440)
            hours, minutes = divmod(remaining_minutes, 60)
            return f"({days} days {hours} hours {minutes} minutes ago)"
        elif total_minutes >= 60:
            hours, minutes = divmod(total_minutes, 60)
            return f"({hours} hours {minutes} minutes ago)"
        else:
            return f"({total_minutes} minutes ago)"


APTS_LINE = re.compile(
    r"^\s*(\d{2}/\d{2}/\d{4}) @ (\d{2}:\d{2})\s*->\s*(\d{2}/\d{2}/\d{4}) @ (\d{2}:\d{2})(?:>[^|]*)?(?:\|\s*(.*))?$"
)


def parse_apts_line(line):
    m = APTS_LINE.match(line)
    if not m:
        return None
    d1, t1, d2, t2, title = m.groups()
    start = datetime.strptime(f"{d1} {t1}", "%m/%d/%Y %H:%M")
    end = datetime.strptime(f"{d2} {t2}", "%m/%d/%Y %H:%M")
    name = (title or "").strip() or "Untitled"
    return {"name": name, "start": start, "end": end}


def load_meetings(apts_file):
    items = []
    try:
        with open(apts_file, "r") as f:
            for line in f:
                item = parse_apts_line(line.strip())
                if item:
                    items.append(item)
    except Exception:
        return []
    today = datetime.now().date()
    items = [x for x in items if x["start"].date() == today or x["end"].date() == today]
    items.sort(key=lambda x: (x["start"], x["end"]))
    return items


def display_meetings(meetings):
    displayed = 0
    if not meetings:
        print(f"{ICON_NO_MEETINGS} No meetings today", flush=True)
        return
    meeting_outputs = []
    now = datetime.now()
    for meeting in meetings:
        title = meeting["name"]
        start = meeting["start"]
        end = meeting["end"]
        if end < now:
            if now - end <= timedelta(minutes=5):
                icon = ICON_FINISHED
            else:
                continue
        elif start - now > timedelta(minutes=1):
            icon = ICON_INCOMING
        else:
            icon = ICON_NOW
        if icon == ICON_INCOMING:
            meeting_str = f"{icon}{title} {get_relative_time(start)}"
        else:
            text = get_relative_time(end)
            meeting_str = f'{icon}{title} {text.replace("(", "(ended " if "ago" in text else "(ends ")}'
        meeting_outputs.append(meeting_str)
        displayed += 1
        if displayed == 3:
            break
    output = f" {ICON_SEPARATOR} ".join(meeting_outputs) if displayed else ICON_NO_MEETINGS + " No meetings !"
    print(output, flush=True)


def main():
    apts_file = os.path.expanduser("~/.local/share/calcurse/apts")
    meetings = load_meetings(apts_file)
    try:
        last_modified = os.path.getmtime(apts_file)
    except OSError:
        last_modified = None
    i = inotify.adapters.Inotify()
    try:
        i.add_watch(apts_file)
    except Exception:
        pass
    while True:
        events = list(i.event_gen(yield_nones=True, timeout_s=0.1))
        if events:
            meetings = load_meetings(apts_file)
            try:
                last_modified = os.path.getmtime(apts_file)
            except OSError:
                last_modified = None
        else:
            try:
                current_mod = os.path.getmtime(apts_file)
                if last_modified is None or current_mod != last_modified:
                    meetings = load_meetings(apts_file)
                    last_modified = current_mod
            except OSError:
                pass
        display_meetings(meetings)
        time.sleep(15)


if __name__ == "__main__":
    main()

