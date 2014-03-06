Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46945 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbaCFGDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 01:03:37 -0500
Date: Thu, 6 Mar 2014 17:03:29 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 8/8] NFS: allow lockless access to access_cache
Message-ID: <20140306170329.39e0c8c9@notabene.brown>
In-Reply-To: <305B5E2C-33BE-4268-87A9-22FD19EF8E1A@primarydata.com>
References: <20140305025813.27421.23871.stgit@notabene.brown>
	<20140305030028.27421.87633.stgit@notabene.brown>
	<305B5E2C-33BE-4268-87A9-22FD19EF8E1A@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ucNAPrk=9mTl/X1wJyg_roC"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ucNAPrk=9mTl/X1wJyg_roC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 10:11:02 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

>=20
> On Mar 4, 2014, at 22:00, NeilBrown <neilb@suse.de> wrote:
>=20
> > The access cache is used during RCU-walk path lookups, so it is best
> > to avoid locking if possible as taking a lock kills concurrency.
> >=20
> > The rbtree is not rcu-safe and cannot easily be made so.
> > Instead we simply check the last (i.e. most recent) entry on the LRU
> > list.  If this doesn't match, then we return -ECHILD and retry in
> > lock/refcount mode.
> >=20
> > This requires freeing the nfs_access_entry struct with rcu, and
> > requires using rcu access primates when adding entries to the lru, and
> > when examining the last entry.
> >=20
> > Calling put_rpccred before kfree_rcu looks a bit odd, but as
> > put_rpccred already provide rcu protection, we know that the cred will
> > not actually be freed until the next grace period, so any concurrent
> > access will be safe.
> >=20
> > This patch provides about 5% performance improvement on a stat-heavy
> > synthetic work load with 4 threads on a 2-core CPU.
> >=20
>=20
> Have you looked at converting the rb-tree into something a little more RC=
U-friendly? Since our lookup key is just a pointer value, couldn=E2=80=99t =
we use a radix-tree?
>=20

Interesting idea.  The radix tree would be fairly sparse unless we divided
the address by the size of the structure ... would that hit alignment issue=
s?
But we don't know real size of the structure (it can depend on auth scheme)
so I doubt that would work.  So I think a radix tree would waste a lot of
space.

Skip lists might work https://lwn.net/Articles/551896/ but they don't appear
to be in the kernel yet.

I think my current approach is no worse the existing code and while there is
room for further improvement, that should probably wait until a suitable da=
ta
structure is available.

Thanks,
NeilBrown

--Sig_/ucNAPrk=9mTl/X1wJyg_roC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxgPsTnsnt1WYoG5AQIhmg//Yd5g9hz1o/SgikVArpkkVw4oure0WMTR
yVvRHEpn3AflgMoqTIU5QAeQCpElcmkCVMnckpS6RqB/0OmcOjEEn2y2Od/YrDQ0
d/kGRAZAEhEsTEXT0WEMVu04uDp+zKROgDywc2oBIGqdYn7c8jHU5AfrEC8Fzw64
k87OVIiYwf8dXj1O7MxEUNeGMcZMozyErD707p48ACn91mHiTp5I/MKSsobztU/X
xmPmcGCOmy5sFKpUs0Ed2ltsc2s4FjxsTD1CnxhTlYCbM+zRDH/JeFomYiiVMDUl
I33WkOMBDG4n0O1krLJe65TxPVPfYaK9/5X0Qvu8Iw2r6eyFc312LcD3Uq9ztiHO
PB0+Kt9U5y3lxA283OS9+8F1XMha5YlUOVBmY+KYr9HuhHXrzuAkHZxWeLddWheE
u2Ab/O84P6+owTDLSI85dQvTz7dPkaiJgLNfbIWiYPgsG7HbRST5PN/+00siKTps
ug6wLtVw+E42zcKwajKUy1Lj5TBGhY0j7LiVjoaSyRx+fggfeHO54utR9lvYC3qB
XCztbFvP5uadxDPUkFrPiCxEnR+aNuVf8ePDFzGXrhRBvVE/LXjjlosWa/NkVbKr
0RyboFpyC9SM0KNBVDkq1gkQnWErNSyc5VJQMa1NcFN/vxywN27hj1EuEsw/ySLs
tSymhnEqPYQ=
=TkYm
-----END PGP SIGNATURE-----

--Sig_/ucNAPrk=9mTl/X1wJyg_roC--
