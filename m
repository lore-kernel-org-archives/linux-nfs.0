Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40628 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S943310AbdEZCqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 22:46:53 -0400
From: NeilBrown <neilb@suse.com>
To: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
Date: Fri, 26 May 2017 12:46:43 +1000
Subject: systemd and NFS "bg" mounts.
Message-ID: <87lgpkgwrw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi all,
 it appears that systemd doesn't play well with NFS "bg" mounts.
 I can see a few options for how to address this and wonder if anyone
 has any opinions.

 "bg" mounts will try to mount the filesystem just like normal, but
 if the server cannot be contacted before a "major timeout" (4.5 minutes
 by default for TCP), mount.nfs will fork and continue in the
 background.  Meanwhile the original mount process reports success (even
 though the filesystem wasn't mounted).  This allows the boot process to
 continue and succeed.

 Currently if you specify the "bg" option in /etc/fstab and are using
 systemd, the "bg" has no useful effect.
 systemd imposes its own timeout of 90 seconds (which is less than 4.5
 minutes).
 After 90 seconds, systemd will kill the mount process and decide that
 the mount failed.  This will lead to remote-fs.target not being reached,
 and boot not completing.

 If you set TimeoutSec=3D0 (aka "infinity") for the mount unit, either by
 hacking fstab-generator or adding "x-systemd.mount-timeout=3Dinfinity"
 if you have systemd 233 or later, then systemd won't kill the mount
 process, and after 4.5 minutes it will exit.
 (to quote a comment in systemd/src/core/mount.c
    " /bin/mount lies to us and is broken"
  :-)

 This is better, but the background mount.nfs can persist for a long
 time.  I don't think it persists forever, but at least half an hour I
 think.

 When the foo.mount unit is stopped, the mount.nfs process isn't killed.
 I don't think this is a major problem, but it is unfortunate and could
 be confusing.  During testing I've had multiple mount.nfs background
 processes all attached to the one .mount unit.

 What should we do about bg NFS mounts with systemd?
 Some options:
   - declare "bg" to be not-supported.  If you don't need the filesystem
     to be present for boot, then use x-systemd.automount, or some other
     automount scheme.
     If we did this, we probably need to make it very obvious that "bg"
     mounts aren't supported - maybe a log message that appears when
     you do "systemctl status ..." ??

   - decide that "bg" is really just a lame attempt at automounting, and
     that now we have real automounting, "bg" can be translated to that.
     So systemd-fstab-generator would treat "bg" like
     "x-systemd.automount" and otherwise strip it  from the list of
     options.

   - do our best to really support "bg".  That means, at least, applying
     a much larger timeout to "bg" mounts, and preferably killing any
     background processes when a mount unit is stopped.  Below is a
     little patch which does this last bit, but I'm not sure it is generally
     safe.

 A side question is: should this knowledge about NFS be encoded in
 systemd, or should nfs-utils add the necessary knowledge?

 i.e. we could add an nfs-fstab-generator to nfs-utils which creates
 drop-ins to modify the behaviour of the drop-ins provided by
 systemd-fstab-generator.
 Adding the TimeoutSec=3D would be easy.  Stripping the "bg" would be
 possible.
 Changing the remote-fs.target.requires/foo.mount symlink to be
 remote-fs.target.requires/foo.automount would be problematic though.
=20=20=20=20=20
 Could we teach systemd-fstab-generator to ignore $TYPE filesystems
 if TYPE-fstab-generator existed?

 Or should we just build all this filesystem-specific knowledge into
 systemd?

Thanks for your thoughts,
NeilBrown


hackish patch to kill backgrounded mount.nfs processes:

diff --git a/src/core/mount.c b/src/core/mount.c
index ca0c4b0d5eed..91939b48d11a 100644
=2D-- a/src/core/mount.c
+++ b/src/core/mount.c
@@ -883,6 +883,18 @@ static void mount_enter_unmounting(Mount *m) {
                     MOUNT_UNMOUNTING_SIGKILL))
                 m->n_retry_umount =3D 0;
=20
+        if (m->result =3D=3D MOUNT_SUCCESS &&
+            !m->from_proc_self_mountinfo) {
+                /* There is no mountpoint, but mount seemed to succeed.
+                 * Could be a bg mount.nfs.
+                 * In any case, kill any processes that might be hanging
+                 * around, they cannot be doing anything useful.
+                 */
+                sd_bus_error error =3D SD_BUS_ERROR_NULL;
+                unit_kill_common(UNIT(m), KILL_ALL, SIGTERM, -1, -1, &erro=
r);
+        }
+
+
         m->control_command_id =3D MOUNT_EXEC_UNMOUNT;
         m->control_command =3D m->exec_command + MOUNT_EXEC_UNMOUNT;
=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlknlxUACgkQOeye3VZi
gblDbhAAtLrg9WUbIFzHMh9Itsywcefi52fg2Lo2fOxO3P3PYOJL7ljWxL+7eyyV
Nq8EZsUFTeIUkdq+IDO/FiocZOgHXvA58JWZg31+OnAEEcNFOJ18xUs5tFjDzWIJ
54NVtXXBQtJcp9V+PR8Ers+bn89BeYIHTZzqXbkJxlQTvLmQfaJavFh13zuyZUCX
GXNBZ/GdzNvrV7k6MZEz7kgjZbqTK+H0xX952DUn9UNcBYAwNurf7je/ohp9XZyM
eTTUjwenZwrFsU5U1U5qiwafQZ0BqueX6YfeZzHF5Tz+irEL9Q2O1/lQXjw2noa3
ilxDOckdf4j2RRBrZLIuLT1EhgAnFPiQVSyIA6yOLW98b7nauScj2jbd48nDjTP6
epwaxwoNdLH9d7zylp0vDK/LLVkcYYHMVl+hvSg3Gd96qD9kqzAuz+tjGzC6vJY0
uqzsXXhTNPpn9qmvsrp7Llws87OwsXyQ9AKgM06UdChphqdDl3M1THo5FNc5aXxg
i56T6nmGefzmuKXC/wnfSfxyyYP4VCYB34K9SFl+KLnsdCmuxOu386U8HszPr/nZ
z3xPlT6iUWG4ZMjz4wz5LSAJ84zeShDSSTI5T5UKrPy3K0P9ncS3dc31ZuAsBEdA
r1XHygy0EVT/a0MAJ6j2iZ0cs4YHunK1xUogroUXkn09YPLeQko=
=itRf
-----END PGP SIGNATURE-----
--=-=-=--
