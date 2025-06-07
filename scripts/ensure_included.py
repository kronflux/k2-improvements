#!/usr/bin/env python3

import os
import sys

def add_include(config_path, include_path, commented=False, placement='end', marker=None):
    """
    Add an include statement to a configuration file if it doesn't exist.

    Args:
        config_path (str): Full path to the configuration file
        include_path (str): Path to be included
        commented (bool): Whether to comment out the include (default: False)
        placement (str): 'end', 'before', or 'after'
        marker (str): The marker line to insert before/after (required if placement is 'before' or 'after')
    """
    target = f"[include {include_path}]"
    if commented:
        target = f"#{target}"

    # Create the directory path if it doesn't exist
    os.makedirs(os.path.dirname(config_path), exist_ok=True)

    # If file doesn't exist, create it with the include
    if not os.path.exists(config_path):
        with open(config_path, 'w') as handle:
            handle.write(target + '\n')
        return

    with open(config_path, 'r') as handle:
        contents = handle.readlines()

    # Already present? Quit
    for line in contents:
        if line.strip() == target:
            return

    # Argument-driven placement
    if placement in ('before', 'after') and marker:
        for idx, line in enumerate(contents):
            if line.strip() == marker.strip():
                insert_at = idx if placement == 'before' else idx + 1
                contents.insert(insert_at, target + '\n')
                with open(config_path, 'w') as handle:
                    handle.writelines(contents)
                return
        # If marker not found, append to end
        contents.append(target + '\n')
        with open(config_path, 'w') as handle:
            handle.writelines(contents)
        return

    # Legacy behavior: insert before #*# or [include overrides.cfg], else append to end
    insert_before = None
    for idx, line in enumerate(contents):
        if line.startswith('#*#') or line.startswith('[include overrides.cfg]'):
            insert_before = idx
            break

    if insert_before is not None:
        contents.insert(insert_before, target + '\n')
    else:
        contents.append(target + '\n')

    with open(config_path, 'w') as handle:
        handle.writelines(contents)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: script.py <config_path> <include_path> [commented] [placement] [marker]")
        sys.exit(1)

    config_path = os.path.expanduser(sys.argv[1])
    include_path = os.path.expanduser(sys.argv[2])
    commented = False
    placement = 'end'
    marker = None

    if len(sys.argv) > 3:
        # Support literal "True" or "False" (as used previously)
        if sys.argv[3].lower() in ('true', 'false'):
            commented = sys.argv[3].lower() == 'true'
        elif sys.argv[3]:
            # Support future extension for boolean parsing
            commented = bool(sys.argv[3])
    if len(sys.argv) > 4:
        placement = sys.argv[4]
    if len(sys.argv) > 5:
        marker = sys.argv[5]

    add_include(config_path, include_path, commented, placement, marker)
