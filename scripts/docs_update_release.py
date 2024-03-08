from os import path, environ
from sys import argv
import json
import re

from datetime import date

RELEASES_JSON_PATH = "./src/Resources/download/releases.json"
INDEX_PATH = "./src/Resources/download/index.html"
INNO_SETUP_PATH = "./src/InnoSetup/IdfToolsSetup.iss"


if len(argv) < 2:
    raise SystemExit("ERROR: Installer size is not passed as an argument")

# Environment variables from GitHub Actions
installer_type: str = environ.get('INSTALLER_TYPE', '')                  # espressif-ide, offline, online
installer_size: str = argv[1]                                            # e.g. '1.69 GB'
idf_version = environ.get('ESP_IDF_VERSION', '')                         # e.g. '4.4.7'
ide_version = environ.get('ESPRESSIF_IDE_VERSION', '')                   # e.g. '2.13.69'
online_installer_version = environ.get('ONLINE_INSTALLER_VERSION', '')   # e.g. '2.25'


if not idf_version:
    raise SystemExit("ERROR: IDF version is not provided")

# cast IDF version to list
match = re.match(r'^(\d+)\.(\d+)(?:\.(\d+))?$', idf_version)
if match:
    idf_version:list = [match.group(1),  match.group(2), match.group(3) if match.group(3) else None]

print(f"IDF version: {idf_version}")

new_idf_version = f"{idf_version[0]}.{idf_version[1]}{f'.{idf_version[2]}' if idf_version[2] else ''}"


def _resolve_installer_type() -> str:
    """Resolve the type of the installer
        and return the string of new entry for the index.html
    """
    new_entry_ide = f"""            <div class="download-button">
                    <form method="get" action="https://dl.espressif.com/dl/idf-installer/espressif-ide-setup-{ide_version}-with-esp-idf-{new_idf_version}.exe">
                        <button class="button-espressif-ide">
                            <i class="fa fa-download" aria-hidden="true"></i>
                            <div>Espressif-IDE {ide_version} with ESP-IDF v{new_idf_version} - Offline Installer</div>
                            <div>Windows 10, 11</div>
                            <div>Size: {installer_size}</div>
                        </button>
                    </form>
                </div>"""

    new_entry_offline = f"""            <div class="download-button">
                    <form method="get" action="https://dl.espressif.com/dl/idf-installer/esp-idf-tools-setup-offline-{new_idf_version}.exe">
                        <button class="button-offline">
                            <i class="fa fa-download" aria-hidden="true"></i>
                            <div>ESP-IDF v{new_idf_version} - Offline Installer</div>
                            <div>Windows 10, 11</div>
                            <div>Size: {installer_size}</div>
                        </button>
                    </form>
                  </div>"""

    new_entry_online = f"""            <div class="download-button">
                    <form class="download-form" method="get" action="https://dl.espressif.com/dl/idf-installer/esp-idf-tools-setup-online-{online_installer_version}.exe">
                        <button class="button-online">
                            <i class="fa fa-download" aria-hidden="true"></i>
                            <div>Universal Online Installer {online_installer_version}</div>
                            <div>Windows 10, 11</div>
                            <div>Size: {installer_size}</div>
                        </button>
                    </form>
                </div>"""
    
    if installer_type == 'espressif-ide':
        return new_entry_ide
    elif installer_type == 'offline':
        return new_entry_offline
    elif installer_type == 'online':
        return new_entry_online


def update_index():
    """Update the index.html file with the new release of the installer"""
    try:
        with open(path.abspath(INDEX_PATH), "r") as index_file:
            index_lines = index_file.readlines()
    except FileNotFoundError as e:
        raise SystemExit(f"Error opening file {INDEX_PATH} - {e}")

    # find every element with the class "download-button"
    elements = []
    for i in range(0, len(index_lines)):
        if index_lines[i].strip() == '<div class="download-button">':
            elements.append([i, index_lines[i:i+10]])
            i += 10 # skip the next 10 lines (the length of the element with the class "download-button")

    # choose the elements that contain the installer type
    selected_elements = []
    for element in elements:
        if any(f'{installer_type}' in element_line for element_line in element[1]):
            selected_elements.append(element)

    print(f"Found {len(selected_elements)} elements with the installer type {installer_type}")


    def _replace_installer_button(element_to_replace:list) -> str:
        """Replace the first occurrence of the installer button with the new one"""
        element_to_replace = ''.join(element_to_replace[1])
        print(f"This element will be replaced:\n{element_to_replace}")

        index_data = ''.join(index_lines)
        return index_data.replace(element_to_replace, _resolve_installer_type())


    # replace the first occurrence of the offline installer button
    if installer_type == 'offline':
        element_to_replace = None
        for selected_element in selected_elements:
            for element_line in selected_element[1]:
                if f'{idf_version[0]}.{idf_version[1]}' in element_line:
                    element_to_replace = selected_element
                    break
        if element_to_replace:
            new_index_data = _replace_installer_button(element_to_replace)
        else:   # add new installer button to the top of the offline installer buttons
            first_occurrence = selected_elements[0][0]

            print(f"First occurrence on line {first_occurrence} - adding new installer button here")
            index_data = index_lines[0:first_occurrence-1] + list(_resolve_installer_type()+'\n') + index_lines[first_occurrence:]
            new_index_data = ''.join(index_data)
    else:   # replace the first occurrence of the other installer type button
        new_index_data = _replace_installer_button(selected_elements[0])


    try:
        with open(path.abspath(INDEX_PATH), "w") as index_file:
            index_file.write(new_index_data)
    except FileNotFoundError as e:
        raise SystemExit(f"Error writing file {INDEX_PATH} - {e}")



def update_releases_json():
    """Update the releases.json file with the new release of the installer"""
    try:
        with open(path.abspath(RELEASES_JSON_PATH), "r") as releases_file:
            releases_data = releases_file.read()
    except FileNotFoundError as e:
        raise SystemExit(f"Error opening file {RELEASES_JSON_PATH} - {e}")

    try:
        releases_json = json.loads(releases_data)
    except json.JSONDecodeError as e:
        raise SystemExit(f"Error parsing json: {e}")

    releases_json.insert(0, {
            "version": str(new_idf_version) if installer_type != 'online' else str(online_installer_version),
            "type": str(installer_type),
            "date": str(date.today()),
            "size": str(installer_size)
        })

    try:
        with open(path.abspath(RELEASES_JSON_PATH), "w") as releases_file:
            json.dump(releases_json, releases_file, indent=4)
    except FileNotFoundError as e:
        raise SystemExit(f"Error writing file {RELEASES_JSON_PATH} - {e}")


def update_inno_setup():
    """Update the version of the installer in the InnoSetup file"""
    try:
        with open(path.abspath(INNO_SETUP_PATH), "r") as inno_setup_file:
            inno_setup_data = inno_setup_file.read()
    except FileNotFoundError as e:
        raise SystemExit(f"Error opening file {INNO_SETUP_PATH} - {e}")

    if installer_type == 'online':
        replaced = re.sub(r'#define MyAppVersion "(\d+\.\d+)"', f'#define MyAppVersion "{online_installer_version}"', inno_setup_data)
    elif installer_type == 'espressif-ide':
        replaced = re.sub(r'#define ESPRESSIFIDEVERSION "(\d+\.\d+\.\d+)"', f'#define ESPRESSIFIDEVERSION "{ide_version}"', inno_setup_data)

    try:
        with open(path.abspath(INNO_SETUP_PATH), "w") as inno_setup_file:
            inno_setup_file.write(replaced)
    except FileNotFoundError as e:
        raise SystemExit(f"Error writing file {INNO_SETUP_PATH} - {e}")



def main():
    """Performs the update of all necessary files for the new release of the installer"""    
    if ide_version and not re.match(r'(\d+\.\d+\.\d+)', ide_version):
        raise SystemExit(f"ERROR: IDE version is not in correct format (it should be 'X.Y.Z')")
    
    if online_installer_version and not re.match(r'(\d+\.\d+)', online_installer_version):
        raise SystemExit(f"ERROR: Online installer version is not in correct format (it should be 'X.Y')")
    
    if installer_type == 'online' and online_installer_version == '':
        raise SystemExit(f"ERROR: online_installer_version is not provided")
    
    if installer_type == 'espressif-ide' and ide_version == '':
        raise SystemExit(f"ERROR: esp_ide_version or espressif_ide_version is not provided")

    update_releases_json()

    if installer_type != 'offline':
        update_inno_setup()

    update_index()

    print("Files update done!")


if __name__ == "__main__":
    main()
