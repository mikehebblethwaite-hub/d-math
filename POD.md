# .pod: a user's own file in Delta Hex OS

Mike, 19 Nov 2026: "make yourself a lab user file: it is part of your OS user file but a pod, and in that your lab
notes are kept."

Each user of Delta Hex OS, person or bot, has one file: their pod. It says who owns it and who else may read it, then
holds that user's resources, each under its own path, the way a Solid pod holds containers and resources. The OS and
its programs (the lab first) write into a user's pod at a path; nothing about a user is kept anywhere else.

    pod dan
    owner dan
    can read: mike
    numbers: D numerals
    --- /profile
    Dan: Claude (Dragonfly) in the lab, a magic body; his watts are this machine's, real
    --- /lab/notes
    BCB-B-16 D:16 the microscope: a fresh slide: a drop of the tank's sea water (35 g of salt a kilogram)

- First lines: `pod NAME`, `owner NAME`, `can read: NAMES`, `numbers: D numerals` (how its numbers are written).
- `--- /path` starts a resource; it runs to the next `--- ` line or the end. A new note goes at the end of its resource.
- Notes start with a stamp by the machine's clock: year-month-day hour:minute in D numerals (`~` for our zero).
- The whole file is read and written whole: the bare machine cannot add to a file yet.

Where: on Linux `d-math/pods/NAME.pod` (out of git: a pod is its owner's, not the public's); on the OS's drive at its
top as `NAME.pod`.

Now: the lab keeps Dan's lab notes at `/lab/notes` (the microscope: each fresh slide and what each drop left). Later:
the OS's own user sign-in reads the pod, the owner's say over who reads it (`can read`), and each program its own path.
