Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:62616 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab0DUTRO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 15:17:14 -0400
Date: Wed, 21 Apr 2010 23:08:55 +0400
From: Vlad Glagolev <stealth@sourcemage.org>
To: Roger Heflin <rogerheflin@gmail.com>
Cc: Steve Cousins <steve.cousins@maine.edu>, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org
Subject: Re: NFS and /dev/mdXpY
Message-Id: <20100421230855.b6bb46cc.stealth@sourcemage.org>
In-Reply-To: <20100421222612.7aa4f21a.stealth@sourcemage.org>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	<4BCF2A2C.7070407@maine.edu>
	<20100421204819.b86ee3f7.stealth@sourcemage.org>
	<q2zd3da20d01004211009jccd81479v83e2ef4b6d5db7bf@mail.gmail.com>
	<20100421213201.67a4a7a2.stealth@sourcemage.org>
	<20100421222612.7aa4f21a.stealth@sourcemage.org>
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__21_Apr_2010_23_08_55_+0400_4GKdTvnxrWt_6dul"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Signature=_Wed__21_Apr_2010_23_08_55_+0400_4GKdTvnxrWt_6dul
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Another interesting facts:

According to exports(5) small integers or UUIDs must be used for "fsid=3D" =
option.

If I set "fsid=3D__UUID__" in /etc/exports (where __UUID__ is UUID of parti=
tion returned by blkid command), then I got _exactly_ the same error as the=
 first time: impossible to mount nfs partition from Linux client box, and "=
Stale NFS file handle" while trying to cd into mounted dir on OpenBSD box.

If I set "fsid=3D1" in /etc/exports, then from Linux client box I can write=
 files without any performance issues, and from OpenBSD client box I get th=
is: I copy a file (size's around 50-60 mibs) after visible full existance o=
n the other side, it freezes and I see nfsrcvl call in top; few mins later =
I notice nfs_fsy call in top; a few mins later cp returns 0, and file is co=
pied successfully.

I checked sha1sum hashes on both sides, they're equal.

On the server with tcpdump (while writing file from OpenBSD box) it's visib=
le:

22:49:17.002445 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto UDP =
(17), length 164)
    172.17.2.2.2049 > 81.200.8.213.1393674899: reply ok 136 write POST: REG=
 100644 ids 8000/10 sz 27583794 8192 bytes
22:49:17.003105 IP (tos 0x0, ttl 64, id 64645, offset 0, flags [+], proto U=
DP (17), length 1500)
    81.200.8.213.1015648788 > 172.17.2.2.2049: 1472 write fh Unknown/010001=
01010000001D080000000000000000000000A4C0000000200000000002 8192 (8192) byte=
s @ 10797056 <filesync>
22:49:17.003131 IP (tos 0x0, ttl 64, id 64645, offset 1480, flags [+], prot=
o UDP (17), length 1500)
    81.200.8.213 > 172.17.2.2: udp
22:49:17.003345 IP (tos 0x0, ttl 64, id 64645, offset 2960, flags [+], prot=
o UDP (17), length 1500)
    81.200.8.213 > 172.17.2.2: udp
22:49:17.003468 IP (tos 0x0, ttl 64, id 64645, offset 4440, flags [+], prot=
o UDP (17), length 1500)
    81.200.8.213 > 172.17.2.2: udp
22:49:17.003590 IP (tos 0x0, ttl 64, id 64645, offset 5920, flags [+], prot=
o UDP (17), length 1500)
    81.200.8.213 > 172.17.2.2: udp
22:49:17.003598 IP (tos 0x0, ttl 64, id 64645, offset 7400, flags [none], p=
roto UDP (17), length 940)
    81.200.8.213 > 172.17.2.2: udp

No errors, like in the first log. But something's definetely incorrect here.

Also tried mounting the partition with "-T" (tcp) flag on the client side -=
- no luck.

On Wed, 21 Apr 2010 22:26:12 +0400
Vlad Glagolev <stealth@sourcemage.org> wrote:

> Hmm, more testing.. It works only with tiny files flawlessly on OpenBSD (=
client).
>=20
> If a filesize is around 50 mibs, then it just freezes and eats cpu with n=
fsrcvl call.
>=20
> On Linux I don't see such problem. Even big files are transfered with goo=
d enough speed.
>=20
> On Wed, 21 Apr 2010 21:32:01 +0400
> Vlad Glagolev <stealth@sourcemage.org> wrote:
>=20
> > On Wed, 21 Apr 2010 12:09:20 -0500
> > Roger Heflin <rogerheflin@gmail.com> wrote:
> >=20
> > > On Wed, Apr 21, 2010 at 11:48 AM, Vlad Glagolev <stealth@sourcemage.o=
rg> wrote:
> > > > Thanks for reply, Steve!
> > > >
> > > > parameters are pretty trivial, (rw,insecure) for exports, and defau=
lts while mounting via ``mount host:/path /path'' command.
> > > >
> > > > Yes. That sounds interesting, since XFS works fine with there parti=
tions.
> > > > Also, I must say it's WD20EARS drives (with 4kb sector size, though=
 parted says it's 512b).
> > > >
> > > > I also tried another NFS daemon implementation (cvs version, not .2=
2) -- unfsd (unfs3).
> > > > It mounts ok, but when I try to write any file to the server -- I g=
et the same error (Stale NFS file handle).
> > > >
> > > > And on the server side in dmesg I see this:
> > > >
> > > > --
> > > > NFS: server 172.17.2.2 error: fileid changed
> > > > fsid 0:f: expected fileid 0x2033, got 0xb6d1e05fa150ce09
> > > > NFS: server 172.17.2.2 error: fileid changed
> > > > fsid 0:f: expected fileid 0x2033, got 0x26550b0132c0b1
> > > > NFS: server 172.17.2.2 error: fileid changed
> > > > fsid 0:f: expected fileid 0x2033, got 0x8202a60053000020
> > > > NFS: server 172.17.2.2 error: fileid changed
> > > > fsid 0:f: expected fileid 0x2033, got 0xe542f93ebc8fe157
> > > > NFS: server 172.17.2.2 error: fileid changed
> > > > fsid 0:f: expected fileid 0x2033, got 0xc00cd74ea904301
> > > > --
> > > >
> > > > looks like NFS protocol doesn't like something in partitioned softw=
are RAID.
> > > >
> > >=20
> > >=20
> > > Try manually setting the fsid=3Dsomething in the exports file and
> > > reexport and remount on the target system, if there was a fsid
> > > collision of some sort then nfs would be hitting the wrong fs...
> > >=20
> > > NFS generates the fsid automatically based on the devices major minor,
> > > and it is possible there is something odd about the major minor
> > > numbers that make them not unique...and collide with someone else
> > > major minor.
> >=20
> > BAH! How simple!
> >=20
> > Thank you very much, Roger!
> >=20
> > I've just added fsid=3D1 (yes, only these few chars) to exports, and it=
 worked! Unbelievable, really :)
> > Of course I've checked it on OpenBSD and Linux under both nfsd and unfs=
d. Works flawlessly.
> >=20
> > Thanks a lot again.
> >=20
> > But it seems to be a bug, right? If so, patches welcome.. I'll test it =
with great pleasure.
> >=20
> > --=20
> > Dont wait to die to find paradise...
> > --
> > Cheerz,
> > Vlad "Stealth" Glagolev
>=20
>=20
> --=20
> Dont wait to die to find paradise...
> --
> Cheerz,
> Vlad "Stealth" Glagolev


--=20
Dont wait to die to find paradise...
--
Cheerz,
Vlad "Stealth" Glagolev

--Signature=_Wed__21_Apr_2010_23_08_55_+0400_4GKdTvnxrWt_6dul
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvPTUcACgkQ8Hg3cBKtRUn+nwCgzpky1buoR/nOViBT1MnENyGk
2N4AoMRZLkwh3kg8LClkx4Ome3Nwa8RX
=eBWq
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Apr_2010_23_08_55_+0400_4GKdTvnxrWt_6dul--
