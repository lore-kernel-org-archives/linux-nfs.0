Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:62074 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166Ab0DVUIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 16:08:07 -0400
Date: Fri, 23 Apr 2010 00:07:57 +0400
From: Vlad Glagolev <stealth@sourcemage.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org
Subject: Re: NFS and /dev/mdXpY
Message-Id: <20100423000757.c58e3dbe.stealth@sourcemage.org>
In-Reply-To: <1271966181.593.23.camel@localhost.localdomain>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	<20100422182543.GB8858@fieldses.org>
	<20100422225310.38e37038.stealth@sourcemage.org>
	<20100422193236.GA10302@fieldses.org>
	<1271965650.593.21.camel@localhost.localdomain>
	<20100422235100.0616ce1d.stealth@sourcemage.org>
	<1271966181.593.23.camel@localhost.localdomain>
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__23_Apr_2010_00_07_57_+0400_USk16Gh5L/n9i9hK"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Signature=_Fri__23_Apr_2010_00_07_57_+0400_USk16Gh5L/n9i9hK
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 22 Apr 2010 15:56:21 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2010-04-22 at 23:51 +0400, Vlad Glagolev wrote:=20
> > On Thu, 22 Apr 2010 15:47:30 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> >=20
> > > On Thu, 2010-04-22 at 15:32 -0400, J. Bruce Fields wrote:=20
> > > > On Thu, Apr 22, 2010 at 10:53:10PM +0400, Vlad Glagolev wrote:
> > > > > On Thu, 22 Apr 2010 14:25:43 -0400
> > > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > >=20
> > > > > > On Sat, Apr 17, 2010 at 07:57:47PM +0400, Vlad Glagolev wrote:
> > > > > > > Well, hello there,
> > > > > > >=20
> > > > > > > Posted it on linux-kernel ML also, and post it here, for more=
 specific analysis.
> > > > > > >=20
> > > > > > > I faced this problem today while trying to mount some NFS sha=
re on OpenBSD box.
> > > > > > > I mounted it successfully without any visible errors, but I w=
asn't able to cd there, the printed error was:
> > > > > > >=20
> > > > > > > ksh: cd: /storage - Stale NFS file handle
> > > > > > >=20
> > > > > > > Apropos, the partition is 5.5 TB. I tried another one on my b=
ox and it was mounted successfully. It was possible to manage files there t=
oo. Its size is ~3GB.
> > > > > > > That's why the first time I thought about some size limitatio=
ns of OpenBSD/Linux/NFS.
> > > > > > >=20
> > > > > > > While talking on #openbsd @ freenode, I discovered this via t=
cpdump on both sides:
> > > > > > >=20
> > > > > > > http://pastebin.ca/1864713
> > > > > > >=20
> > > > > > > Googling for 3 hours didn't help at all, some posts had simil=
iar issue but either with no answer at all or without any full description.
> > > > > > >=20
> > > > > > > Then I started to experiment with another Linux box to kill t=
he possible different variants.
> > > > > > >=20
> > > > > > > On another box I also have nfs-utils 1.1.6 and kernel 2.6.32.=
 Mounting that big partition was unsuccessful, it got just stuck. On tcpdum=
p I've seen this:
> > > > > >=20
> > > > > > I'm a bit confused.  What kernel and nfs-utils version is runni=
ng on the
> > > > > > problematic Linux server?
> > > > >=20
> > > > > same. nfs-utils 1.1.6 and kernel 2.6.32.
> > > >=20
> > > > Huh.  That should be new enough for it to be using uuid's.  I wonde=
r why
> > > > it isn't?
> > >=20
> > > What are the contents of /dev/disk/by-uuid?
> > >=20
> >=20
> > $ ls -1 /dev/disk/by-uuid/
> > 0e9742f6-44e3-431c-911f-4c914e4f81d5
> > 31ae89c6-dba6-4351-b3a9-e8b08be07c3d
> > 4429ba7a-afd2-4c61-83a0-900dae1bccdc
> > 463bbc42-c19b-4b9e-bae7-838ac0e2e5c6
> > 473b9320-88a4-44eb-b592-2ac98619bc9b
> > 53d16b07-d496-4f8f-ad59-ea34aaf169f4
> > 6adf1c55-405c-43cf-a84d-be5d2746d300
> > b35a7bca-12ad-4738-a895-52f20b7cc5d9
> > dc892f1f-0b83-41dd-bde7-0761295f33a3
> > f7ac4165-320f-4235-a78a-5fe1bd0aac24
> >=20
>=20
> So, when you do 'ls -l' on the above, you do indeed see all the
> partitions that are being exported via NFS?

there's only one, and yes, you're right.. /dev/md2p6 isn't in the list.

According to blkid:

# blkid
/dev/sda1: UUID=3D"9a9beac0-d5fa-94d1-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sda2: UUID=3D"8327bc1c-3d13-ee78-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sda3: UUID=3D"01821f8d-da8e-fd6a-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdb1: UUID=3D"9a9beac0-d5fa-94d1-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdb2: UUID=3D"8327bc1c-3d13-ee78-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdb3: UUID=3D"01821f8d-da8e-fd6a-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdc1: UUID=3D"ed9c6039-5faf-d0ef-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdc2: UUID=3D"8327bc1c-3d13-ee78-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdc3: UUID=3D"01821f8d-da8e-fd6a-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdd1: UUID=3D"ed9c6039-5faf-d0ef-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdd2: UUID=3D"8327bc1c-3d13-ee78-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/sdd3: UUID=3D"01821f8d-da8e-fd6a-86df-b710391e5a7c" TYPE=3D"linux_raid=
_member"=20
/dev/md0: UUID=3D"53d16b07-d496-4f8f-ad59-ea34aaf169f4" TYPE=3D"xfs"=20
/dev/md2p1: UUID=3D"31ae89c6-dba6-4351-b3a9-e8b08be07c3d" TYPE=3D"swap"=20
/dev/md2p2: UUID=3D"dc892f1f-0b83-41dd-bde7-0761295f33a3" TYPE=3D"xfs"=20
/dev/md2p3: UUID=3D"f7ac4165-320f-4235-a78a-5fe1bd0aac24" TYPE=3D"xfs"=20
/dev/md2p4: UUID=3D"4429ba7a-afd2-4c61-83a0-900dae1bccdc" TYPE=3D"xfs"=20
/dev/md2p5: UUID=3D"b35a7bca-12ad-4738-a895-52f20b7cc5d9" TYPE=3D"xfs"=20
/dev/md2p6: UUID=3D"9f8d66e8-4b11-4ae7-8f90-b00ee9d204b1" TYPE=3D"xfs"=20
/dev/md1: UUID=3D"0e9742f6-44e3-431c-911f-4c914e4f81d5" TYPE=3D"xfs"=20
/dev/md3: UUID=3D"463bbc42-c19b-4b9e-bae7-838ac0e2e5c6" TYPE=3D"xfs"=20
/dev/sde1: UUID=3D"6adf1c55-405c-43cf-a84d-be5d2746d300" TYPE=3D"ext2"

and not all of them exist at /dev/disk/by-uuid:

# ls -1 /dev/disk/by-uuid
0e9742f6-44e3-431c-911f-4c914e4f81d5 <- /dev/md1
31ae89c6-dba6-4351-b3a9-e8b08be07c3d <- /dev/md2p1
4429ba7a-afd2-4c61-83a0-900dae1bccdc <- /dev/md2p4
463bbc42-c19b-4b9e-bae7-838ac0e2e5c6 <- /dev/md3
473b9320-88a4-44eb-b592-2ac98619bc9b <- ??
53d16b07-d496-4f8f-ad59-ea34aaf169f4 <- /dev/md0
6adf1c55-405c-43cf-a84d-be5d2746d300 <- /dev/sde1
b35a7bca-12ad-4738-a895-52f20b7cc5d9 <- /dev/md2p5
dc892f1f-0b83-41dd-bde7-0761295f33a3 <- /dev/md2p2
f7ac4165-320f-4235-a78a-5fe1bd0aac24 <- /dev/md2p3

Interesting. so 9f8d66e8-4b11-4ae7-8f90-b00ee9d204b1 !=3D 473b9320-88a4-44e=
b-b592-2ac98619bc9b.

Bug in udev?

--=20
Dont wait to die to find paradise...
--
Cheerz,
Vlad "Stealth" Glagolev

--Signature=_Fri__23_Apr_2010_00_07_57_+0400_USk16Gh5L/n9i9hK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvQrJ0ACgkQ8Hg3cBKtRUkeegCgwTe0Z9/kxHBly3ME8OpR1D+E
1fkAoJEkaS6lVnTe083p9fKRc+nt0KHN
=CRr/
-----END PGP SIGNATURE-----

--Signature=_Fri__23_Apr_2010_00_07_57_+0400_USk16Gh5L/n9i9hK--
