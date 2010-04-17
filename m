From: Vlad Glagolev <stealth-L+UJwxqiw56VyaH7bEyXVA@public.gmane.org>
Subject: NFS and /dev/mdXpY
Date: Sat, 17 Apr 2010 19:57:47 +0400
Message-ID: <20100417195747.5fae8834.stealth@sourcemage.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__17_Apr_2010_19_57_47_+0400_XTMSWfUWGO99GZIR"
Cc: linux-raid@vger.kernel.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:54544 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab0DQP5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Apr 2010 11:57:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Sat__17_Apr_2010_19_57_47_+0400_XTMSWfUWGO99GZIR
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Well, hello there,

Posted it on linux-kernel ML also, and post it here, for more specific anal=
ysis.

I faced this problem today while trying to mount some NFS share on OpenBSD =
box.
I mounted it successfully without any visible errors, but I wasn't able to =
cd there, the printed error was:

ksh: cd: /storage - Stale NFS file handle

Apropos, the partition is 5.5 TB. I tried another one on my box and it was =
mounted successfully. It was possible to manage files there too. Its size i=
s ~3GB.
That's why the first time I thought about some size limitations of OpenBSD/=
Linux/NFS.

While talking on #openbsd @ freenode, I discovered this via tcpdump on both=
 sides:

http://pastebin.ca/1864713

Googling for 3 hours didn't help at all, some posts had similiar issue but =
either with no answer at all or without any full description.

Then I started to experiment with another Linux box to kill the possible di=
fferent variants.

On another box I also have nfs-utils 1.1.6 and kernel 2.6.32. Mounting that=
 big partition was unsuccessful, it got just stuck. On tcpdump I've seen th=
is:

--
    172.17.2.5.884 > 172.17.2.2.2049: Flags [.], cksum 0x25e4 (correct), se=
q 1, ack 1, win 92, options [nop,nop,TS val 1808029984 ecr 1618999], length=
 0
    172.17.2.5.3565791363 > 172.17.2.2.2049: 40 null
    172.17.2.2.2049 > 172.17.2.5.884: Flags [.], cksum 0x25e6 (correct), se=
q 1, ack 45, win 46, options [nop,nop,TS val 1618999 ecr 1808029984], lengt=
h 0
    172.17.2.2.2049 > 172.17.2.5.3565791363: reply ok 24 null
    172.17.2.5.884 > 172.17.2.2.2049: Flags [.], cksum 0x259b (correct), se=
q 45, ack 29, win 92, options [nop,nop,TS val 1808029985 ecr 1618999], leng=
th 0
    172.17.2.5.3582568579 > 172.17.2.2.2049: 40 null
    172.17.2.2.2049 > 172.17.2.5.3582568579: reply ok 24 null
    172.17.2.5.3599345795 > 172.17.2.2.2049: 92 fsinfo fh Unknown/010003000=
5030100000800000000000000000000000000000000000000000000
    172.17.2.2.2049 > 172.17.2.5.3599345795: reply ok 32 fsinfo ERROR: Stal=
e NFS file handle POST:
    172.17.2.5.3616123011 > 172.17.2.2.2049: 92 fsinfo fh Unknown/010003000=
5030100000800000000000000000000000000000000000000000000
    172.17.2.2.2049 > 172.17.2.5.3616123011: reply ok 32 fsinfo ERROR: Stal=
e NFS file handle POST:
    172.17.2.5.884 > 172.17.2.2.2049: Flags [F.], cksum 0x2449 (correct), s=
eq 281, ack 129, win 92, options [nop,nop,TS val 1808029986 ecr 1618999], l=
ength 0
    172.17.2.2.2049 > 172.17.2.5.884: Flags [F.], cksum 0x2476 (correct), s=
eq 129, ack 282, win 46, options [nop,nop,TS val 1618999 ecr 1808029986], l=
ength 0
    172.17.2.5.884 > 172.17.2.2.2049: Flags [.], cksum 0x2448 (correct), se=
q 282, ack 130, win 92, options [nop,nop,TS val 1808029986 ecr 1618999], le=
ngth 0
--

familiar messages, eh?

Since that time I've solved that's not OpenBSD problem. So only NFS and Lin=
ux left as the reasons of this.
It was possible to mount that small partition on Linux box too, the same as=
 on OpenBSD.

But afterthat I recongnized an interesting issue: I have different sw raid =
setups on my storage server.
I tried to mount a small partition on the same md device where 5.5TB partit=
ion is located, and got the same
error message! Now I'm sure it's about NFS <-> MDADM setup, that's why I ca=
lled the topic like this.

A bit about my setup:

# cat /proc/mdstat=20
Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [multipath=
]=20
md3 : active raid1 sdc1[0] sdd1[1]
      61376 blocks [2/2] [UU]
     =20
md1 : active raid5 sdc2[2] sdd2[3] sdb2[1] sda2[0]
      3153408 blocks level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
     =20
md2 : active raid5 sdc3[2] sdd3[3] sdb3[1] sda3[0]
      5857199616 blocks level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
     =20
md0 : active raid1 sdb1[1] sda1[0]
      61376 blocks [2/2] [UU]
     =20
unused devices: <none>

md0, md1, and md3 aren't so interesting, since fs is created directly on th=
em, and that's a _problem device_:

# parted /dev/md2
GNU Parted 2.2
Using /dev/md2
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) p free                                                          =20
p free
Model: Unknown (unknown)
Disk /dev/md2: 5998GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End     Size    File system     Name   Flags
        17.4kB  1049kB  1031kB  Free Space
 1      1049kB  2147MB  2146MB  linux-swap(v1)  swap
 2      2147MB  23.6GB  21.5GB  xfs             home
 3      23.6GB  24.7GB  1074MB  xfs             temp
 4      24.7GB  35.4GB  10.7GB  xfs             user
 5      35.4GB  51.5GB  16.1GB  xfs             var
 6      51.5GB  5998GB  5946GB  xfs             vault
        5998GB  5998GB  507kB   Free Space

# ls /dev/md?*
/dev/md0  /dev/md1  /dev/md2  /dev/md2p1  /dev/md2p2  /dev/md2p3  /dev/md2p=
4  /dev/md2p5  /dev/md2p6  /dev/md3

It's very handy partitioning scheme where I can extend (grow 5th raid) with=
 more hdds only /vault partition while "loosing" (a.k.a. not using for this=
 partition) only ~1gb of space from every 2TB drive.

System boots ok and xfs_check passes with no problems, etc.
The only problem: it's not possible to use NFS shares on any partition of /=
dev/md2 device.

Finally, my question to NFS and MDADM developers: any idea?

--=20
Dont wait to die to find paradise...
--
Cheerz,
Vlad "Stealth" Glagolev

--Signature=_Sat__17_Apr_2010_19_57_47_+0400_XTMSWfUWGO99GZIR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvJ2nsACgkQ8Hg3cBKtRUkdQwCglsgfEP11qexuKudeLqbkUGzi
bzIAoK6wmJcaEoNFkLsA7jhbkOUz4YrU
=OIiM
-----END PGP SIGNATURE-----

--Signature=_Sat__17_Apr_2010_19_57_47_+0400_XTMSWfUWGO99GZIR--
