Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.21]:64983 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbaDDV5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 17:57:22 -0400
Received: from [192.168.178.21] ([78.54.130.84]) by mail.gmx.com (mrgmx002)
 with ESMTPSA (Nemesis) id 0LvENG-1XDoJu2QhW-010Nie for
 <linux-nfs@vger.kernel.org>; Fri, 04 Apr 2014 23:57:20 +0200
Message-ID: <533F2ABF.2030107@gmx.de>
Date: Fri, 04 Apr 2014 23:57:19 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: NFSv2 directory cannot longer be exported in 3.14, 3.13 works fine
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

At a user mode linux image (32 bit Gentoo Linux) the recent kernel gives this error while trying to mount a NFSv2 directory:
mount.nfs: mount point /mnt/nfsv2 is not a directory      


The hostname is n22stab4, contents of the files follows.


/etc/fstab:
tmpfs                   /mnt/ramdisk    tmpfs   auto,size=300M
n22stab4:/mnt/ramdisk   /mnt/nfsv2      nfs     auto,bg,intr,soft,nfsvers=2


/etc/exports:
/mnt/ramdisk    192.168.0.0/16(rw,fsid=0,insecure,no_subtree_check,async,no_root_squash)


/var/log/messages:
Apr  4 23:55:45 n22stab4 kernel: init_special_inode: bogus i_mode (1777) for inode 0:24:818

- -- 
MfG/Sincerely
Toralf Förster
pgp finger print:1A37 6F99 4A9D 026F 13E2 4DCF C4EA CDDE 0076 E94E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iF4EAREIAAYFAlM/Kr8ACgkQxOrN3gB26U4PSgD9EhS86BoFwdVOpBU3dkw9CDwL
HeIby5M2zFkzVHCuv6MA/iYKV/PkjrS6lxvIDLDpIuAEWRyx097ueE0ugaQ0J/ls
=vQ3c
-----END PGP SIGNATURE-----
