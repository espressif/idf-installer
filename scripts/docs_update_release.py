from os import path, environ
from sys import argv
import json
import re

from datetime import date

from jinja2 import Template, StrictUndefined

# Global constants with paths for files to be changed
RELEASES_JSON_PATH = "./src/Resources/download/releases.json"
INDEX_PATH = "./src/Resources/download/index.html"
INNO_SETUP_PATH = "./src/InnoSetup/IdfToolsSetup.iss"
INDEX_TEMPLATE_PATH = "./src/Resources/templates/template_index.html"

class AddedInstallers:
    """This class stores if all installer types for all supported versions have been added"""
    def __init__(self, supported_idf_versions):
        self.online = False
        self.offline = False
        self.espressif_ide = False

        self.supported_idf_versions = supported_idf_versions
        
    def all_added(self):
        """Check if all installer objects for buttons have been added"""
        return self.online and self.offline and self.espressif_ide and len(self.supported_idf_versions) == 0  


def update_index(releases, supported_idf_versions):
    """Update the index.html file with the new release of the installer"""
    added_installers = AddedInstallers(supported_idf_versions)
    
    online = None
    espressif_ide = None
    offline = []
    for release in releases:
        if added_installers.all_added():
            break
        
        if release['type'] == 'online' and not added_installers.online:
            online = release
            added_installers.online = True

        if release['type'] == 'espressif-ide' and not added_installers.espressif_ide:
            espressif_ide = release
            added_installers.espressif_ide = True

        if release['type'] == 'offline' and not added_installers.offline:
            for version in added_installers.supported_idf_versions:
                if version in release['version']:
                    offline.append(release)
                    added_installers.supported_idf_versions.remove(version)
                    break
            if len(added_installers.supported_idf_versions) == 0:
                added_installers.offline = True

    # sort for offline installer objects for buttons
    offline_sorted = sorted(offline, key=lambda item: item['version'], reverse=True)

    try:
        with open(INDEX_TEMPLATE_PATH, 'r') as f:
            template = f.read()
    except FileNotFoundError as e:
        raise SystemExit(f"Error reading file {INDEX_TEMPLATE_PATH} - {e}")

    # StrictUndefined will rise an error if any variable in template is not passed
    # (instead of silent replace as an empty string)
    j2_template = Template(template, undefined=StrictUndefined)

    # regex for finding IDE and IDF version in 'version' of espressif_ide object (PATCH part not mandatory)
    # "2.12.0-with-esp-idf-5.1" -> ['2.12.0', '5.1']
    pattern = r'\b(\d+\.\d+(?:\.\d+)?)\b'
    ide_version, ide_idf = re.findall(pattern, espressif_ide['version'])

    # variables to be changed in index.html
    variables = {
        "online":{
            "version": online['version'],
            "size": online['size'],
        },
        "espressif_ide":{
            "version": ide_version,
            "idf_version": ide_idf,
            "size": espressif_ide['size'],
        },
        "offline_buttons": offline_sorted
    }

    try:
        with open(path.abspath(INDEX_PATH), "w") as index_file:
            index_file.write(j2_template.render(variables))
    except FileNotFoundError as e:
        raise SystemExit(f"Error writing file {INDEX_PATH} - {e}")



def update_releases_json(new_idf_version: str, installer_type: str, online_installer_version: str, installer_size: str):
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
    
    return releases_json


def update_inno_setup(installer_type: str, online_installer_version: str, ide_version: str):
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
    if len(argv) < 2:
        raise SystemExit("ERROR: Installer size is not passed as an argument")
    
    # Environment variables from GitHub Actions (environmental variables of the runner)
    installer_type: str = environ.get('INSTALLER_TYPE', '')                  # espressif-ide, offline, online
    installer_size: str = argv[1]                                            # e.g. '1.69 GB'
    idf_version = environ.get('ESP_IDF_VERSION', '')                         # e.g. '4.4.7'
    ide_version = environ.get('ESPRESSIF_IDE_VERSION', '')                   # e.g. '2.13.69'
    online_installer_version = environ.get('ONLINE_INSTALLER_VERSION', '')   # e.g. '2.25'

    supported_idf_versions = eval(environ.get('SUPPORTED_IDF_VERSIONS', "('5.2', '4.4', '5.1', '5.0')"))    # e.g. ('5.2', '4.4', '5.1', '5.0')
    supported_idf_versions = list(supported_idf_versions)

    if not idf_version:
        raise SystemExit("ERROR: IDF version is not provided")
    
    # cast IDF version to list
    # regex parsing IDF version which should be in format 5.3 or 5.3.0 (The PATCH number is not mandatory just MAJOR and MINOR) 
    match = re.match(r'^(\d+)\.(\d+)(?:\.(\d+))?$', idf_version)
    if match:
        idf_version:list = [match.group(1),  match.group(2), match.group(3) if match.group(3) else None]
    else:
        raise SystemExit(f"ERROR: IDF version was not resolved correctly, expected format: MAJOR.MINOR(.PATCH) given string {idf_version}")

    print(f"IDF version: {idf_version}")

    new_idf_version = f"{idf_version[0]}.{idf_version[1]}{f'.{idf_version[2]}' if idf_version[2] else ''}"

    if ide_version and not re.match(r'(\d+\.\d+\.\d+)', ide_version):
        raise SystemExit(f"ERROR: IDE version is not in correct format (it should be 'X.Y.Z') which '{ide_version}' is not")
    
    if online_installer_version and not re.match(r'(\d+\.\d+)', online_installer_version):
        raise SystemExit(f"ERROR: Online installer version is not in correct format (it should be 'X.Y') which '{online_installer_version}' is not")
    
    if installer_type == 'online' and online_installer_version == '':
        raise SystemExit(f"ERROR: online_installer_version is not provided")
    
    if installer_type == 'espressif-ide' and ide_version == '':
        raise SystemExit(f"ERROR: esp_ide_version or espressif_ide_version is not provided")

    releases_json = update_releases_json(new_idf_version, installer_type, online_installer_version, installer_size)

    # Update App or IDE version if the installer type is not offline
    if installer_type != 'offline':
        update_inno_setup(installer_type, online_installer_version, ide_version)

    update_index(releases_json, supported_idf_versions)

    print("Files update done!")


if __name__ == "__main__":
    main()
