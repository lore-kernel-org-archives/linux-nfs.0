Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34265 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756400Ab3FMBzH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 21:55:07 -0400
Date: Thu, 13 Jun 2013 11:54:56 +1000
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130613115456.02e28f94@notabene.brown>
In-Reply-To: <61eb00$3oamkh@dgate20u.abg.fsc.net>
References: <61eb00$3oamkh@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/LpbEAz5Tp4Bg/1ioUaWuEw7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/LpbEAz5Tp4Bg/1ioUaWuEw7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 03 Jun 2013 16:27:06 +0200 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> On Fri, Apr 19, 2013 at 06:56:00PM +0200, Bodo Stroesser wrote:
> >=20
> > We started the test of the -SP2 (and mainline) series on Tue, 9th, but =
had no
> > success.
> > We did _not_ find a problem with the patches, but under -SP2 our test s=
cenario
> > has less than 40% of the throughput we saw under -SP1. With that low
> > performance, we had a 4 day run without any dropped RPC request. But we=
 don't
> > know the error rate without the patches under these conditions. So we c=
an't
> > give an o.k. for the patches yet.
> >=20
> > Currently we try to find the reason for the different behavior of SP1 a=
nd SP2
> >=20
>=20
> Hi,
>=20
> sorry for the delay. Meanwhile we found the reason for the small throughp=
ut
> with -SP2. The problem resulted from a change in our own software.
>=20
> Thus I could fix this and started a test on last Tuesday. I stopped the t=
est
> today after 6 days without any lost RPC. Without the patches I saw the fi=
rst
> dropped RPC after 3 hours. Thus, I think the patches for -SP2 are fine.=20
>=20
> @Neil: would patch 0006 of the -SP1 patchset be a good additional change =
for
> mainline?
>=20
> Bodo

Thanks for all the testing.

Bruce: where are you at with these?  Are you holding one to some that I sent
previously, or should I resend them all?


Bodo: no, I don't think that patch is appropriate for mainline.  It causes
sunrpc_cache_pipe_upcall to abort if ->expiry_time is zero.  There is
certainly no point in doing an upcall in that case, but the code in mainline
is quite different to the code in -SP1 against which that patch made sense.

For mainline an equivalent optimisation which probably makes the interesting
case more obvious would be:

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d01eb07..291cc47 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -262,7 +262,8 @@ int cache_check(struct cache_detail *detail,
 	if (rqstp =3D=3D NULL) {
 		if (rv =3D=3D -EAGAIN)
 			rv =3D -ENOENT;
-	} else if (rv =3D=3D -EAGAIN || age > refresh_age/2) {
+	} else if (rv =3D=3D -EAGAIN ||
+		   (refresh_age > 0 && age > refresh_age/2)) {
 		dprintk("RPC:       Want update, refage=3D%ld, age=3D%ld\n",
 				refresh_age, age);
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {


i.e. trap that case in cache_check.

NeilBrown

--Sig_/LpbEAz5Tp4Bg/1ioUaWuEw7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUbkmcDnsnt1WYoG5AQJWrg//dqW5iX+l5QuPBwGY7hW/0UMY/anpn95a
p4QVwe0IoH4+jwk9E41W282LAnRnOsB748O9cNrh875lS4Xg5VKucjNly8w2XyoR
jydICdtNE9PP/cYAU2F9ThOOtdnUxip7rSOFBTx7106rXEWemUZD+pcPinLa0CNa
VD4SXYhkEZe1yV/IBJAN0JTALumGUKVFHclZMUFkUe799vAjIerbANJZfubpGsry
ncYyVfq3bSiXDyhaG2PolLsKf9RwGv1joF72Dasw2ju7ehCHuMGqCzhDIcrZfPVq
ofXWyxW8k1M8fp4YxTDHGHqADnhpmlodc6VH7LFo+wIv6aTcAilTOcbw4iQvS9z7
G0BpOeEuM5G8pqQkL3PABIWShR4JhCGbyqmPRglgiKVxFsFnaXcVO4WfiNXC5QY8
L3ZO9IaPvufwoH+1KrP6tCR1Iz3xtMPg3xMmsv4Q5xCZW4KNDOQi+QQ88bCjQ+Ok
A/lcmd8CdOSCVUfsyXL5dtw6qFcki4/9Y83outaIXugTnU3ah6D7dKOTv2R41AcC
xVI4qi+eCtG5gsiXv0j/tDaQlhpPAG31xcXQtPvBEDxAn1XY8hXzwJMtxs3L6sNX
8Ng4nUdZMBwNr9U3MkWT4H5nfIYQt4uEaA5KcnIsVYgAZOyTN6shMm0YK7089Wu3
v9tVo+nGnLM=
=Jsji
-----END PGP SIGNATURE-----

--Sig_/LpbEAz5Tp4Bg/1ioUaWuEw7--
