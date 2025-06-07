import argparse
import os
import re
import sys

def remove_section_from_cfg(input_file: str, section_to_remove: str, backup_dir: str = None) -> tuple[bool, str]:
    """
    Remove a section from an INI style CFG file and optionally save the removed section separately, preserving comments.

    Args:
        input_file: Path to the input CFG file
        section_to_remove: Name of the section to remove
        backup_dir: Directory to store the removed section (if provided)

    Returns:
        tuple: (success: bool, message: str)
    """
    try:
        input_file = os.path.expanduser(input_file)
        if backup_dir:
            backup_dir = os.path.expanduser(backup_dir)

        # Read the original file content
        with open(input_file, 'r') as f:
            lines = f.readlines()

        current_section = None
        removed_lines = []
        kept_lines = []
        in_target_section = False
        found_section = False

        # Process the file line by line
        for line in lines:
            section_match = re.match(r'^\s*\[(.*?)\]\s*$', line)
            if section_match:
                current_section = section_match.group(1)
                in_target_section = (current_section == section_to_remove)
                if in_target_section:
                    found_section = True

            if in_target_section:
                removed_lines.append(line)
            else:
                kept_lines.append(line)

        if not found_section:
            return False, f"Section '{section_to_remove}' not found in {input_file}"

        backup_msg = ""
        # Save the backup only if backup_dir is specified
        if backup_dir:
            os.makedirs(backup_dir, exist_ok=True)
            backup_file = os.path.join(backup_dir, f"{section_to_remove}.cfg")
            with open(backup_file, 'w') as f:
                f.writelines(removed_lines)
            backup_msg = f" Backup saved to {backup_file}"

        # Save the modified file (overwrite input)
        with open(input_file, 'w') as f:
            f.writelines(kept_lines)

        return True, f"Section removed successfully.{backup_msg}"

    except Exception as e:
        return False, f"Error: {str(e)}"

def parse_args():
    parser = argparse.ArgumentParser(
        description="Remove a section from a Klipper/INI style CFG file, optionally backing up the section."
    )
    parser.add_argument(
        "-section", required=True, help="Name of section to remove (e.g., prtouch_v3)"
    )
    parser.add_argument(
        "-input", default="~/printer_data/config/printer.cfg", help="Input config file (default: ~/printer_data/config/printer.cfg)"
    )
    parser.add_argument(
        "-backup", nargs="?", const="~/printer_data/config/custom", default=None, help="Backup directory (if specified with no value, uses ~/printer_data/config/custom)"
    )
    return parser.parse_args()

def main():
    args = parse_args()

    success, message = remove_section_from_cfg(
        input_file=args.input,
        section_to_remove=args.section,
        backup_dir=args.backup
    )

    print(message)
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()
