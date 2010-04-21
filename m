Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:50777 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459Ab0DURdW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:33:22 -0400
Date: Wed, 21 Apr 2010 21:32:01 +0400
From: Vlad Glagolev <stealth@sourcemage.org>
To: Roger Heflin <rogerheflin@gmail.com>
Cc: Steve Cousins <steve.cousins@maine.edu>, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org
Subject: Re: NFS and /dev/mdXpY
Message-Id: <20100421213201.67a4a7a2.stealth@sourcemage.org>
In-Reply-To: <q2zd3da20d01004211009jccd81479v83e2ef4b6d5db7bf@mail.gmail.com>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	<4BCF2A2C.7070407@maine.edu>
	<20100421204819.b86ee3f7.stealth@sourcemage.org>
	<q2zd3da20d01004211009jccd81479v83e2ef4b6d5db7bf@mail.gmail.com>
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__21_Apr_2010_21_32_01_+0400_k/faMsQ+HsTGsbhd"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Signature=_Wed__21_Apr_2010_21_32_01_+0400_k/faMsQ+HsTGsbhd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 21 Apr 2010 12:09:20 -0500
Roger Heflin <rogerheflin@gmail.com> wrote:

> On Wed, Apr 21, 2010 at 11:48 AM, Vlad Glagolev <stealth@sourcemage.org> =
wrote:
> > Thanks for reply, Steve!
> >
> > parameters are pretty trivial, (rw,insecure) for exports, and defaults =
while mounting via ``mount host:/path /path'' command.
> >
> > Yes. That sounds interesting, since XFS works fine with there partition=
s.
> > Also, I must say it's WD20EARS drives (with 4kb sector size, though par=
ted says it's 512b).
> >
> > I also tried another NFS daemon implementation (cvs version, not .22) -=
- unfsd (unfs3).
> > It mounts ok, but when I try to write any file to the server -- I get t=
he same error (Stale NFS file handle).
> >
> > And on the server side in dmesg I see this:
> >
> > --
> > NFS: server 172.17.2.2 error: fileid changed
> > fsid 0:f: expected fileid 0x2033, got 0xb6d1e05fa150ce09
> > NFS: server 172.17.2.2 error: fileid changed
> > fsid 0:f: expected fileid 0x2033, got 0x26550b0132c0b1
> > NFS: server 172.17.2.2 error: fileid changed
> > fsid 0:f: expected fileid 0x2033, got 0x8202a60053000020
> > NFS: server 172.17.2.2 error: fileid changed
> > fsid 0:f: expected fileid 0x2033, got 0xe542f93ebc8fe157
> > NFS: server 172.17.2.2 error: fileid changed
> > fsid 0:f: expected fileid 0x2033, got 0xc00cd74ea904301
> > --
> >
> > looks like NFS protocol doesn't like something in partitioned software =
RAID.
> >
>=20
>=20
> Try manually setting the fsid=3Dsomething in the exports file and
> reexport and remount on the target system, if there was a fsid
> collision of some sort then nfs would be hitting the wrong fs...
>=20
> NFS generates the fsid automatically based on the devices major minor,
> and it is possible there is something odd about the major minor
> numbers that make them not unique...and collide with someone else
> major minor.

BAH! How simple!

Thank you very much, Roger!

I've just added fsid=3D1 (yes, only these few chars) to exports, and it wor=
ked! Unbelievable, really :)
Of course I've checked it on OpenBSD and Linux under both nfsd and unfsd. W=
orks flawlessly.

Thanks a lot again.

But it seems to be a bug, right? If so, patches welcome.. I'll test it with=
 great pleasure.

--=20
Dont wait to die to find paradise...
--
Cheerz,
Vlad "Stealth" Glagolev

--Signature=_Wed__21_Apr_2010_21_32_01_+0400_k/faMsQ+HsTGsbhd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvPNpEACgkQ8Hg3cBKtRUlR7gCdFhzHh7PoZQU4KSKvxOYvRn8e
V2EAn0mz2TeyzqVfbrH7McV7d+f8Y0/P
=y0Gk
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Apr_2010_21_32_01_+0400_k/faMsQ+HsTGsbhd--
