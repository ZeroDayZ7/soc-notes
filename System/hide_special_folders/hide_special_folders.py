import winreg

paths = [
    r"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace",
    r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace"
]

folders = {
    "Obiekty 3D": "{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
    "Muzyka": "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
    "Obrazy": "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
}

def rename_key(root, path, guid):
    try:
        with winreg.OpenKey(root, path, 0, winreg.KEY_ALL_ACCESS) as key:
            try:
                with winreg.OpenKey(key, guid, 0, winreg.KEY_ALL_ACCESS):
                    winreg.DeleteKey(key, guid + "_backup")
                    winreg.SaveKey(key, "temp_backup")
                    winreg.CreateKey(key, guid + "_backup")
                    print(f"[OK] Zmieniono {guid} → {guid}_backup w {path}")
            except FileNotFoundError:
                print(f"[INFO] {guid} nie znaleziony w {path} – może już został zmieniony.")
    except PermissionError:
        print("[ERROR] Uruchom ten skrypt jako administrator!")

for p in paths:
    for name, guid in folders.items():
        rename_key(winreg.HKEY_LOCAL_MACHINE, p, guid)

print("\n✅ Zakończono! Zrestartuj explorer.exe lub komputer, aby zmiany były widoczne.")
