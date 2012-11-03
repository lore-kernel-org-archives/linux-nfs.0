Return-Path: linux-nfs-owner@vger.kernel.org
Received: from karif.server-speed.net ([188.40.51.140]:53035 "EHLO
	karif.server-speed.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab2KCTgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Nov 2012 15:36:08 -0400
Received: from karif.server-speed.net (karif.server-speed.net [127.0.0.1])
	by karif.server-speed.net (Postfix) with ESMTP id 06F03138192
	for <linux-nfs@vger.kernel.org>; Sat,  3 Nov 2012 20:29:12 +0100 (CET)
Received: from [192.168.4.247] (h081217049118.dyn.cm.kabsi.at [81.217.49.118])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: flo)
	by karif.server-speed.net (Postfix) with ESMTPSA
	for <linux-nfs@vger.kernel.org>; Sat,  3 Nov 2012 20:29:11 +0100 (CET)
Message-ID: <50957087.6050008@xinu.at>
Date: Sat, 03 Nov 2012 20:29:11 +0100
From: Florian Pritz <bluewind@xinu.at>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS stalls when writing - linux 3.6.x
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3813964ED803AD5DDCA6B340"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3813964ED803AD5DDCA6B340
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

Long text ahead.


Since I have no idea what to look at/for, I tried to summarise all more
or less relevant information. If you need any more, please tell me.

I've been trying to debug this for days now and might have mixed
something up although I double checked as much as possible while writing
this mail.


# Overview

I've been experiencing stalls when trying to write big-ish files on my
nfs mount for some time (few months) now. Rsync is also somewhat slow,
transferring only like 1 file per second even if the files are only a
few kilobytes in size. Sometimes it also stalls for a few seconds
between files. I hardly run rsync over nfs so can't tell if this might
be normal.

Sadly I don't know when this started happening.

Server and client are both running Arch Linux with linux 3.6.5 and
nfs-utils 1.2.6.

The server is running on a striped raid10 array with 4 disks using the
deadline scheduler and connected via Gbit ethernet. The CPU is an Intel
i3-530 and it has 2GB RAM. The raid10 is part of an LVM which contains
the actual XFS file system exported by nfsd.

At first I assumed a problem with file system, but I switched from ext3
to XFS and still experience the issue. Transferring large amounts
(>80GB) of data over samba + cifs didn't cause any problems so I'm
ruling out network and disks.

# Description

dd if=3D/dev/zero of=3Dtest bs=3D1M count=3D8000 (writing a 1GB file is a=
lso
enough, sometimes)

Watch the network traffic (with "vnstat -l" or conky) and wait until it
drops from 110MB/s to 0-5MB/s (you might need to run dd multiple times,
wait a few minutes/hours or reboot the server)

top on the server now shows lots of nfsd threads in D state. iostat only
shows the 0-5MB/s of network traffic going to the disk.

A local dd job on the server manages to write 160MB/s while nfsd
continues to hang. Reading from the nfs share while nfsd is hanging is
possible, but has a delay of up to ~20-30 seconds.

After some time the client displays "nfs: server levant not responding,
still trying" in dmesg followed by a "nfs: server levant OK" 0 or more
seconds later (yes, zero). Both messages sometimes appear more than once
at the same time.

Apart from those messages dmesg is clean on either system even after
waiting for a few minutes.

# Environment

## Mount options (from /proc/mounts)

rw,nosuid,nodev,noexec,relatime,vers=3D4.0,rsize=3D65536,wsize=3D65536,
namlen=3D255,hard,proto=3Dtcp,port=3D0,timeo=3D14,retrans=3D2,sec=3Dsys,
clientaddr=3D192.168.4.247,local_lock=3Dnone,addr=3D192.168.4.103,user

## /etc/exportsfs -v

/mnt/data/nfs
192.168.4.1/24(rw,wdelay,crossmnt,root_squash,all_squash,no_subtree_check=
,anonuid=3D999,anongid=3D999)

## Programm versions

Those are all the same on both client and server.

acl 2.2.51-2
libgssglue 0.4-1
libevent 2.0.20-1
librpcsecgss 0.19-7
nfs-utils 1.2.6-2
util-linux 2.22.1-2

# Other notes

I tried reproducing the issue with a virtual machine and it somehow
worked, but I'm not really sure if I actually hit the same issue because
the vm sometimes locks up too.

The VM was set up in qemu with one virtio disk which was directly
partioned without the use of mdadm or lvm.


Thank you for reading.

--=20
Florian Pritz


--------------enig3813964ED803AD5DDCA6B340
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIbBAEBAgAGBQJQlXCHAAoJEG0WVcFM4cE+peoP+ME8fS8z7PYxBdLo6eD06L01
Va3WvwYQ+iyOA4aXqEIaT9UOMcGVap2CKJ3GpyO+lmC1Ium2M1SBLdbxYz8+Vd7Y
tJTufmhZo4r0ESjFphCaQ7xDv5p1mzUE2rm99N5nUfknhfMFp0fPnYem07QIRc7e
Wl5Ghm1YKEDtf+gTjqIODlmNh53kK/GnYV425G0CwHRIEqxWJWFpzfeb1DwrhgoX
IbetvZoKUJfZfFRLdCE01XyJbArHI+5OhqF4Nla2DQoci8I0pFzIfthjRSTyhJZV
ZhMXkWmlHtxctQsCnpCOq65x7xofTEMwpsXnfcYRdWe3rPo+0v3kegUlO62egKmH
lIra6brPpbf5cAbh9K0kNkOvQ9p43XWSQLBdCSOcdstA91tRBLYAdrWIqr1D90Ve
m39iRiAOZVtoK/vmPemotxNVPePxmQKqUyWp0WSmcYKqowm1IBWLUb5Wm8j9EU+3
jtULTq1Luz3DmSG8+pDtmgulHFH3aUJc35Bp1N7gaWuxV7zPzEwZO9qlS1AcsBbm
SAAdiFVybLSbJhkWe8bODFrsVIe+vDnKAqUDJdsVy/HC9TKqbHxtEFsfPkjJqLdJ
fGiyoXN2Oe+NZVz77I+K5eVgSFdeS9/+66eMwlKLN6+xB164mLRwUioWYDTsTuET
v1OWdxdSLHyatgnoV/A=
=/sOh
-----END PGP SIGNATURE-----

--------------enig3813964ED803AD5DDCA6B340--
