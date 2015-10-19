Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38343 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001AbbJSBIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 Oct 2015 21:08:49 -0400
From: Neil Brown <neilb@suse.com>
To: util-linux@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 19 Oct 2015 12:08:41 +1100
Subject: mount does not accurately identify existing NFS mounts, and shouldn't try.
Message-ID: <87twpnll5y.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


When I run "mount -a" (and possibly in other circumstances) mount
attempts to determine if the requested filesystem is already mounted.
It seems to have some handling for various special cases, but doesn't
handle all cases properly.

For example, if I have
  server:/export /import nfs ....
  192.168.1.1:/private private nfs ....

in /etc/fstab and the IP address of 'server' is 192.168.1.1,
then both entries will appear in /proc/mounts with the same host name
(depending on which order there were mounted).

When I run "mount -a" a second time it will detect that one of these is
already correctly mounted, and will ignore it.
The other will not be detected as already being mounted (as the hostname
appears different) and "mount -a" will try to mount it again.

This will fail with "EBUSY" and mount will report an error
   .... is busy or already mounted.

So while both filesystems are already mounted, we only get an error for
one of them.

The irony here is that while it is hard for user-space to determine
if the mounted filesystem matches the requested filesystem it is trivial
for the kernel.
For NFS we could try canonicalizing the server name, but undoubtedly
other issues would arrive.  I believe there are similar issues with
btrfs and submount, though I have looked closely.

For the kernel, it is as simple as

	/* Refuse the same filesystem on the same mount point */
	err = -EBUSY;
	if (path->mnt->mnt_sb == newmnt->mnt.mnt_sb &&
	    path->mnt->mnt_root == path->dentry)
		goto unlock;

This is the *only* time that the kernel returns EBUSY for a "mount a new
filesystem" request (remount can return EBUSY for other reasons I
think).

So in the case where "mount" thinks it should check if the filesystem is
already mounted and ignore the request if it is, the best thing it can
do is to just try the mount and ignore any "EBUSY" error status - treat
that the same as success.

So all that code for "is this the same mountpoint" can probably be
discarded.

Did I miss any important consideration there?

Unfortunately this change could be awkward to implement as /sbin/mount
decides whether to try the mount and (for NFS), /sbin/mount.nfs gives an
error message if EBUSY is returned.  Would we need to pass a "noebusy"
flag, but only if mount.nfs were willing to accept it....

Any suggestions?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWJEKZAAoJEDnsnt1WYoG5Dd4QAKMlLVdfC7ndMIAMc4Rob442
bmBFgu3wuoQSG6JlxXTJZEQp7qpJ6G33BTA1U4lkYgdLaXB9l4EtE5THaQHNEzZv
ulVU/m/ZPn7swezA+HtK/ShhEOlIOtMKFGsSGuxDw9H8IB5TYQw9oEm031y7fE2o
ffLYOCec922/JYv+Don6efL/QA0ue0nkEOxghN6N2Wq14/i5SqZvMEwEuO3uFiR0
OeTB+krwc9wdbJlr183EVxh01OIY6Pf6THQe4EFVuHS6Gj0rqUjD971jGTxj1Hyo
9PHmhCXFBOsFTVLb6bO4M5kkp6QsMGlmct+KTb0QyevNVyBYpgmIVYBEeTLhrDvV
hdSD/ncsG+liir75t+MvwBjhMMK/ouERtg16yCgvO9s6Gb/8X8LT1r2VBRQwIfzs
0QMS+O2xV9LgyDrwQnuML8XB+EPfi0LBJIajB9qXUlDynVB+lgmH4jmgBz1pD9P/
f+VAINL/lElU5YSOEHEwNYGn+WYrZRZ2Hd/Nrr6jHy7gQ9Q+8X99RwqunTOClqMm
yQBsY+XLOxhsvXvLt8sIxk/T6a1v/VrO4JyEYe9Pf2py+V4rcZvpgmkI+9ZiMaGW
WY6xLUt3ErVzLFZGxhp+cCpcKRxHxhnuXp+r8xsJuV9x1Su1h9W3QA1kz94D5zfZ
74oKZkBAn5nCC5oVyDdG
=JepF
-----END PGP SIGNATURE-----
--=-=-=--
