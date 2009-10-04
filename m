From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#549002: [PATCH] nfs: Avoid overrun when copying client IP
 address string
Date: Mon, 05 Oct 2009 00:24:48 +0100
Message-ID: <1254698688.27417.10.camel@localhost>
References: <1254662749.2395.68.camel@localhost>
	 <1254695596.30515.75.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-nb+kD4y6qdC3B1Dg1aeM"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	549002@bugs.debian.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53764 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751371AbZJDXZe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Oct 2009 19:25:34 -0400
In-Reply-To: <1254695596.30515.75.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-nb+kD4y6qdC3B1Dg1aeM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-10-04 at 18:33 -0400, Trond Myklebust wrote:
> On Sun, 2009-10-04 at 14:25 +0100, Ben Hutchings wrote:
> > As seen in <http://bugs.debian.org/549002>, nfs4_init_client() can
> > overrun the source string when copying the client IP address from
> > nfs_parsed_mount_data::client_address to nfs_client::cl_ipaddr.  Since
> > these are both treated as null-terminated strings elsewhere, the copy
> > should be done with strlcpy() not memcpy().
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > ---
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 75c9cd2..f525a2f 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -1073,7 +1073,7 @@ static int nfs4_init_client(struct nfs_client *cl=
p,
> >  				      1, flags & NFS_MOUNT_NORESVPORT);
> >  	if (error < 0)
> >  		goto error;
> > -	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
> > +	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
> > =20
> >  	error =3D nfs_idmap_new(clp);
> >  	if (error < 0) {
>=20
> It looks good, so I'll push it upstream. I assume the bug report also
> applies to stable@kernel.org?

This bug appears to have been present "forever", though I think it has
become a practical problem since nfs_client::cl_ipaddr was enlarged to
48 bytes in v2.6.25.  So yes, the bug and fix are applicable to every
stable series.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-nb+kD4y6qdC3B1Dg1aeM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASskuu+e/yOyVhhEJAQI06A/9HFXZuUCm0PtF/Kt0N6SsO6czbLU/ZgFc
S78ZE1FGbqZ6agOjk7cyoto1q+REmEWOBr7kByfvfDCZIJuVmgpctsRnm5H3yBM9
lRY1hiy+ivVP08V8Oyr566XieL/nKJBRPjp2Wkm/zWEH2P8+PRTlIPSfajrFQ/jw
FJOgjNlZzD0skv5MxHrgZGItp5klzeYkaZgiMAMvk5CY/Lf/BIs8Q+AhbztXRgf3
Wi/Lr+dCLrhdJwXrB2LlkxYiscJWpWbClWPbKAZIsz35cbvUHZr6uAmR01RjGvWM
9qP4AcMUDtESrL+VeO4UFLCp/+RcIyLANXOlM8kguvoK/ou+IUz8yhgQJDRerL1H
Dnx2h81K7tW+ioYuafaBYP+A+U5E/tke62QQeST3ddp2VG4RoWCLrbx2VyEffbQn
30Wm88H+D4xy8pZAzWsOdLp4hy24Qi7bFyqdAhhWYxJtFJ6AhTrWsZYinr+PqgOi
OFlonewVK/s9fO1mg8wPGkq+a7Bq+zXLB0A/339C8+P7gbWeRyOWkTaVjT8ifnwA
18meGh0js527I8c+qifPDRpw9c4lva9WpHOFOnoQDQiPte0nKJ3v3ycTD5STy7Yf
rwbSeBKgmmNIVYY0Yae0cIYN+/6jkIhIjFJ3dcq1rpEi2SMUOwqJ/Cr23R4rtopk
6of5q1Bar4A=
=U/OW
-----END PGP SIGNATURE-----

--=-nb+kD4y6qdC3B1Dg1aeM--
