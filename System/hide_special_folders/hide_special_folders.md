## ✅ **Jak ukryć np. „Obiekty 3D” z panelu nawigacyjnego?**

1. **Otwórz Edytor rejestru**

   * Naciśnij `Win + R`, wpisz `regedit`, Enter.

2. **Przejdź do klucza:**

   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace
   ```

   oraz

   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace
   ```

3. **Znajdź podklucz odpowiadający folderowi „Obiekty 3D”**

   * Dla **Obiekty 3D** GUID to:

     ```
     {0DB7E03F-FC29-4DC6-9020-FF41B59E513A}
     ```
   * Usuń ten klucz lub zmień jego nazwę (np. dopisz `_backup` na końcu).

* **Obrazy** – `{24ad3ad4-a569-4530-98e1-ab02f9417aa8}`
* **Muzyka** – `{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}`
* **Dokumenty** – `{d3162b92-9365-467a-956b-92703aca08af}`
* **Wideo** – `{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}`
