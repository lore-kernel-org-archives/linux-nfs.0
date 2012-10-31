Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39819 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754524Ab2JaUW7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Oct 2012 16:22:59 -0400
Date: Thu, 1 Nov 2012 07:23:22 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: fix bug in legacy DNS resolver.
Message-ID: <20121101072322.47bcb34a@notabene.brown>
In-Reply-To: <06657F3E-5812-4680-929E-DE0FAED5601E@oracle.com>
References: <20121031121601.5de16a5b@notabene.brown>
	<06657F3E-5812-4680-929E-DE0FAED5601E@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZSXA3/=+1zvgStvrEUhvx8D"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZSXA3/=+1zvgStvrEUhvx8D
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 31 Oct 2012 11:09:27 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Thanks, Neil!
>=20
> On Oct 30, 2012, at 9:16 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> > The DNS resolver's use of the sunrpc cache involves a 'ttl' number
> > (relative) rather that a timeout (absolute).  This confused me when
> > I wrote
> >  commit c5b29f885afe890f953f7f23424045cdad31d3e4
> >     "sunrpc: use seconds since boot in expiry cache"
> >=20
> > and I managed to break it.  The effect is that any TTL is interpreted
> > as 0, and nothing useful gets into the cache.
> >=20
> > This patch removes the use of get_expiry() - which really expects an
> > expiry time - and uses get_uint() instead, treating the int correctly
> > as a ttl.
>=20
> Nit: The description says "get_uint()" but the patch uses "get_int()."  S=
hould we change the patch?
>=20

Yes, change the patch.  I remember looking at that issue and deciding that
get_uint() was the right thing to use as 'ttl' is already unsigned.
And I wrote the description based on the memory.  But it seems I didn't
change the code.  Weird.

> > This fixes a regression that has been present since 2.6.37, causing
> > certain NFS accesses in certain environments to incorrectly fail.
>=20
> In particular, when the legacy DNS resolver is in use, this regression pr=
events the NFS client from following any NFSv4 referral which contains a DN=
S hostname.

Thanks.  Updated patch below.

NeilBrown



=46rom e0b382c5b880017853f6a4cc0eda472cf6fef0e4 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Wed, 31 Oct 2012 12:10:48 +1100
Subject: [PATCH] NFS: fix bug in legacy DNS resolver.

The DNS resolver's use of the sunrpc cache involves a 'ttl' number
(relative) rather that a timeout (absolute).  This confused me when
I wrote
  commit c5b29f885afe890f953f7f23424045cdad31d3e4
     "sunrpc: use seconds since boot in expiry cache"

and I managed to break it.  The effect is that any TTL is interpreted
as 0, and nothing useful gets into the cache.

This patch removes the use of get_expiry() - which really expects an
expiry time - and uses get_uint() instead, treating the int correctly
as a ttl.

This fixes a regression that has been present since 2.6.37, causing
certain NFS accesses in certain environments to incorrectly fail.

In particular, when the legacy DNS resolver is in use, this regression
prevents the NFS client from following any NFSv4 referral which
contains a DNS hostname.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 31c26c4..ca4b11e 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -217,7 +217,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 {
 	char buf1[NFS_DNS_HOSTNAME_MAXLEN+1];
 	struct nfs_dns_ent key, *item;
-	unsigned long ttl;
+	unsigned int ttl;
 	ssize_t len;
 	int ret =3D -EINVAL;
=20
@@ -240,7 +240,8 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 	key.namelen =3D len;
 	memset(&key.h, 0, sizeof(key.h));
=20
-	ttl =3D get_expiry(&buf);
+	if (get_uint(&buf, &ttl) < 0)
+		goto out;
 	if (ttl =3D=3D 0)
 		goto out;
 	key.h.expiry_time =3D ttl + seconds_since_boot();



--Sig_/ZSXA3/=+1zvgStvrEUhvx8D
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUJGIujnsnt1WYoG5AQL8pBAAnOuj5qVqmLUMkqg1P/MtS+eSpM3Hru8t
bI1VWfCgu4S/ne5zdcvpygmcNHtc1OkLY4eV9odpVXNk8gUm/5/g0hWHyazTL1PP
dpIGwoZbPxrhO1z39C6sFDCP2/1aIDaJpXqwP8VsBLAO5GTYxFSiUjy6ySaT5xzk
K4mTdql/YsDx8M+WEXvVguM5ICv9SQFW282om83UO2kuPbN8Po4UyZ+3Spn6qNRm
O3VKGu8f950Sa0PT4lW4Q4dPdz8T0hefP7lF7Ocx/WGhSi7ZdxEs3pipXqctgK0y
OZ9YDv1mVuigMa3U81u5yJih3mCrrdP4utSr9ij8mmPKvpQsl+tkymSkUwr4xAJY
Bkro1196hbCyRIv2ItnzYOgMt9m3PwMErdExFNzll1/bWaOdEK7lfXSrRJlYWQy0
YCssshJzfsAajDrJwFmMFGYaRUAh/EVjhoW56s4/iDrIju98iNB+elAqAP7nl27x
4jGoAAQdxGtxmTvZUxL5k7XplKffL1EK3u8+0Fg+cnTu0IshJ91xtdQibFOhEDC1
+oHhviW2zYYaK3VY4GU3JoDqU/i7VRv8bRajGztQzZVjjfrA3B8rNzWLKR9K2NAx
lMpJ4N9wScyzAp+CRdhkGJJrPSC64iNjXn0lFI8pG7ph47Tbsqxi7x0rwbkto31E
IpcbB84HfFw=
=z9NC
-----END PGP SIGNATURE-----

--Sig_/ZSXA3/=+1zvgStvrEUhvx8D--
