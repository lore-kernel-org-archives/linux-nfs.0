From: Vlad Glagolev <stealth-L+UJwxqiw56VyaH7bEyXVA@public.gmane.org>
Subject: Re: NFS and /dev/mdXpY
Date: Thu, 22 Apr 2010 22:53:10 +0400
Message-ID: <20100422225310.38e37038.stealth@sourcemage.org>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	<20100422182543.GB8858@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__22_Apr_2010_22_53_10_+0400_.dODum0/5BTJcxU2"
Cc: linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:50897 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab0DVSxW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 14:53:22 -0400
In-Reply-To: <20100422182543.GB8858@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Thu__22_Apr_2010_22_53_10_+0400_.dODum0/5BTJcxU2
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 22 Apr 2010 14:25:43 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Apr 17, 2010 at 07:57:47PM +0400, Vlad Glagolev wrote:
> > Well, hello there,
> >=20
> > Posted it on linux-kernel ML also, and post it here, for more specific =
analysis.
> >=20
> > I faced this problem today while trying to mount some NFS share on Open=
BSD box.
> > I mounted it successfully without any visible errors, but I wasn't able=
 to cd there, the printed error was:
> >=20
> > ksh: cd: /storage - Stale NFS file handle
> >=20
> > Apropos, the partition is 5.5 TB. I tried another one on my box and it =
was mounted successfully. It was possible to manage files there too. Its si=
ze is ~3GB.
> > That's why the first time I thought about some size limitations of Open=
BSD/Linux/NFS.
> >=20
> > While talking on #openbsd @ freenode, I discovered this via tcpdump on =
both sides:
> >=20
> > http://pastebin.ca/1864713
> >=20
> > Googling for 3 hours didn't help at all, some posts had similiar issue =
but either with no answer at all or without any full description.
> >=20
> > Then I started to experiment with another Linux box to kill the possibl=
e different variants.
> >=20
> > On another box I also have nfs-utils 1.1.6 and kernel 2.6.32. Mounting =
that big partition was unsuccessful, it got just stuck. On tcpdump I've see=
n this:
>=20
> I'm a bit confused.  What kernel and nfs-utils version is running on the
> problematic Linux server?

same. nfs-utils 1.1.6 and kernel 2.6.32.

>=20
> Also, what are the contents of /proc/net/rpc/nfsd.export/content and
> /proc/net/rpc/nfsd.content after you try to access the filesystem?

# cat /proc/net/rpc/nfsd.export/content
#path domain(flags)
/vault	172.17.2.5(ro,insecure,root_squash,sync,wdelay,no_subtree_check)

# cat /proc/net/rpc/nfsd.fh/content=20
#domain fsidtype fsid [path]
# 172.17.2.5 3 0x0001030500000803
172.17.2.5 0 0x0500030100000803 /vault

>=20
> --b.
>=20
> >=20
> > --
> >     172.17.2.5.884 > 172.17.2.2.2049: Flags [.], cksum 0x25e4 (correct)=
, seq 1, ack 1, win 92, options [nop,nop,TS val 1808029984 ecr 1618999], le=
ngth 0
> >     172.17.2.5.3565791363 > 172.17.2.2.2049: 40 null
> >     172.17.2.2.2049 > 172.17.2.5.884: Flags [.], cksum 0x25e6 (correct)=
, seq 1, ack 45, win 46, options [nop,nop,TS val 1618999 ecr 1808029984], l=
ength 0
> >     172.17.2.2.2049 > 172.17.2.5.3565791363: reply ok 24 null
> >     172.17.2.5.884 > 172.17.2.2.2049: Flags [.], cksum 0x259b (correct)=
, seq 45, ack 29, win 92, options [nop,nop,TS val 1808029985 ecr 1618999], =
length 0
> >     172.17.2.5.3582568579 > 172.17.2.2.2049: 40 null
> >     172.17.2.2.2049 > 172.17.2.5.3582568579: reply ok 24 null
> >     172.17.2.5.3599345795 > 172.17.2.2.2049: 92 fsinfo fh Unknown/01000=
30005030100000800000000000000000000000000000000000000000000
> >     172.17.2.2.2049 > 172.17.2.5.3599345795: reply ok 32 fsinfo ERROR: =
Stale NFS file handle POST:
> >     172.17.2.5.3616123011 > 172.17.2.2.2049: 92 fsinfo fh Unknown/01000=
30005030100000800000000000000000000000000000000000000000000
> >     172.17.2.2.2049 > 172.17.2.5.3616123011: reply ok 32 fsinfo ERROR: =
Stale NFS file handle POST:
> >     172.17.2.5.884 > 172.17.2.2.2049: Flags [F.], cksum 0x2449 (correct=
), seq 281, ack 129, win 92, options [nop,nop,TS val 1808029986 ecr 1618999=
], length 0
> >     172.17.2.2.2049 > 172.17.2.5.884: Flags [F.], cksum 0x2476 (correct=
), seq 129, ack 282, win 46, options [nop,nop,TS val 1618999 ecr 1808029986=
], length 0
> >     172.17.2.5.884 > 172.17.2.2.2049: Flags [.], cksum 0x2448 (correct)=
, seq 282, ack 130, win 92, options [nop,nop,TS val 1808029986 ecr 1618999]=
, length 0
> > --
> >=20
> > familiar messages, eh?
> >=20
> > Since that time I've solved that's not OpenBSD problem. So only NFS and=
 Linux left as the reasons of this.
> > It was possible to mount that small partition on Linux box too, the sam=
e as on OpenBSD.
> >=20
> > But afterthat I recongnized an interesting issue: I have different sw r=
aid setups on my storage server.
> > I tried to mount a small partition on the same md device where 5.5TB pa=
rtition is located, and got the same
> > error message! Now I'm sure it's about NFS <-> MDADM setup, that's why =
I called the topic like this.
> >=20
> > A bit about my setup:
> >=20
> > # cat /proc/mdstat=20
> > Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [multi=
path]=20
> > md3 : active raid1 sdc1[0] sdd1[1]
> >       61376 blocks [2/2] [UU]
> >      =20
> > md1 : active raid5 sdc2[2] sdd2[3] sdb2[1] sda2[0]
> >       3153408 blocks level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
> >      =20
> > md2 : active raid5 sdc3[2] sdd3[3] sdb3[1] sda3[0]
> >       5857199616 blocks level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
> >      =20
> > md0 : active raid1 sdb1[1] sda1[0]
> >       61376 blocks [2/2] [UU]
> >      =20
> > unused devices: <none>
> >=20
> > md0, md1, and md3 aren't so interesting, since fs is created directly o=
n them, and that's a _problem device_:
> >=20
> > # parted /dev/md2
> > GNU Parted 2.2
> > Using /dev/md2
> > Welcome to GNU Parted! Type 'help' to view a list of commands.
> > (parted) p free                                                        =
  =20
> > p free
> > Model: Unknown (unknown)
> > Disk /dev/md2: 5998GB
> > Sector size (logical/physical): 512B/512B
> > Partition Table: gpt
> >=20
> > Number  Start   End     Size    File system     Name   Flags
> >         17.4kB  1049kB  1031kB  Free Space
> >  1      1049kB  2147MB  2146MB  linux-swap(v1)  swap
> >  2      2147MB  23.6GB  21.5GB  xfs             home
> >  3      23.6GB  24.7GB  1074MB  xfs             temp
> >  4      24.7GB  35.4GB  10.7GB  xfs             user
> >  5      35.4GB  51.5GB  16.1GB  xfs             var
> >  6      51.5GB  5998GB  5946GB  xfs             vault
> >         5998GB  5998GB  507kB   Free Space
> >=20
> > # ls /dev/md?*
> > /dev/md0  /dev/md1  /dev/md2  /dev/md2p1  /dev/md2p2  /dev/md2p3  /dev/=
md2p4  /dev/md2p5  /dev/md2p6  /dev/md3
> >=20
> > It's very handy partitioning scheme where I can extend (grow 5th raid) =
with more hdds only /vault partition while "loosing" (a.k.a. not using for =
this partition) only ~1gb of space from every 2TB drive.
> >=20
> > System boots ok and xfs_check passes with no problems, etc.
> > The only problem: it's not possible to use NFS shares on any partition =
of /dev/md2 device.
> >=20
> > Finally, my question to NFS and MDADM developers: any idea?
> >=20
> > --=20
> > Dont wait to die to find paradise...
> > --
> > Cheerz,
> > Vlad "Stealth" Glagolev
>=20
>=20


--=20
Dont wait to die to find paradise...
--
Cheerz,
Vlad "Stealth" Glagolev

--Signature=_Thu__22_Apr_2010_22_53_10_+0400_.dODum0/5BTJcxU2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvQmxYACgkQ8Hg3cBKtRUl+XACfSBQZ8mxtZww29uIcNioMdcj+
8HEAoJN7lNvvu7XkCP847HiU1vazI6Aq
=OHPF
-----END PGP SIGNATURE-----

--Signature=_Thu__22_Apr_2010_22_53_10_+0400_.dODum0/5BTJcxU2--
