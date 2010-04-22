From: Vlad Glagolev <stealth@sourcemage.org>
Subject: Re: NFS and /dev/mdXpY
Date: Thu, 22 Apr 2010 23:51:00 +0400
Message-ID: <20100422235100.0616ce1d.stealth@sourcemage.org>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	<20100422182543.GB8858@fieldses.org>
	<20100422225310.38e37038.stealth@sourcemage.org>
	<20100422193236.GA10302@fieldses.org>
	<1271965650.593.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__22_Apr_2010_23_51_00_+0400_2bKlKeLGbH.GxWS7"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <1271965650.593.21.camel@localhost.localdomain>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Thu__22_Apr_2010_23_51_00_+0400_2bKlKeLGbH.GxWS7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 22 Apr 2010 15:47:30 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2010-04-22 at 15:32 -0400, J. Bruce Fields wrote:=20
> > On Thu, Apr 22, 2010 at 10:53:10PM +0400, Vlad Glagolev wrote:
> > > On Thu, 22 Apr 2010 14:25:43 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >=20
> > > > On Sat, Apr 17, 2010 at 07:57:47PM +0400, Vlad Glagolev wrote:
> > > > > Well, hello there,
> > > > >=20
> > > > > Posted it on linux-kernel ML also, and post it here, for more spe=
cific analysis.
> > > > >=20
> > > > > I faced this problem today while trying to mount some NFS share o=
n OpenBSD box.
> > > > > I mounted it successfully without any visible errors, but I wasn'=
t able to cd there, the printed error was:
> > > > >=20
> > > > > ksh: cd: /storage - Stale NFS file handle
> > > > >=20
> > > > > Apropos, the partition is 5.5 TB. I tried another one on my box a=
nd it was mounted successfully. It was possible to manage files there too. =
Its size is ~3GB.
> > > > > That's why the first time I thought about some size limitations o=
f OpenBSD/Linux/NFS.
> > > > >=20
> > > > > While talking on #openbsd @ freenode, I discovered this via tcpdu=
mp on both sides:
> > > > >=20
> > > > > http://pastebin.ca/1864713
> > > > >=20
> > > > > Googling for 3 hours didn't help at all, some posts had similiar =
issue but either with no answer at all or without any full description.
> > > > >=20
> > > > > Then I started to experiment with another Linux box to kill the p=
ossible different variants.
> > > > >=20
> > > > > On another box I also have nfs-utils 1.1.6 and kernel 2.6.32. Mou=
nting that big partition was unsuccessful, it got just stuck. On tcpdump I'=
ve seen this:
> > > >=20
> > > > I'm a bit confused.  What kernel and nfs-utils version is running o=
n the
> > > > problematic Linux server?
> > >=20
> > > same. nfs-utils 1.1.6 and kernel 2.6.32.
> >=20
> > Huh.  That should be new enough for it to be using uuid's.  I wonder why
> > it isn't?
>=20
> What are the contents of /dev/disk/by-uuid?
>=20

$ ls -1 /dev/disk/by-uuid/
0e9742f6-44e3-431c-911f-4c914e4f81d5
31ae89c6-dba6-4351-b3a9-e8b08be07c3d
4429ba7a-afd2-4c61-83a0-900dae1bccdc
463bbc42-c19b-4b9e-bae7-838ac0e2e5c6
473b9320-88a4-44eb-b592-2ac98619bc9b
53d16b07-d496-4f8f-ad59-ea34aaf169f4
6adf1c55-405c-43cf-a84d-be5d2746d300
b35a7bca-12ad-4738-a895-52f20b7cc5d9
dc892f1f-0b83-41dd-bde7-0761295f33a3
f7ac4165-320f-4235-a78a-5fe1bd0aac24

--=20
Dont wait to die to find paradise...
--
Cheerz,
Vlad "Stealth" Glagolev

--Signature=_Thu__22_Apr_2010_23_51_00_+0400_2bKlKeLGbH.GxWS7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvQqKQACgkQ8Hg3cBKtRUlInACgkVQend4qk97eZEYXht/Tmr06
3y8AoJQsjs6HfkfjeDtk0bBDLuQj84Um
=qW/S
-----END PGP SIGNATURE-----

--Signature=_Thu__22_Apr_2010_23_51_00_+0400_2bKlKeLGbH.GxWS7--
