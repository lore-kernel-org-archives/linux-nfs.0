Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40570 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753258AbdGCIzO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 04:55:14 -0400
Date: Mon, 3 Jul 2017 09:55:06 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 01/12] mount: don't use IPPROTO_UDP for
 address resolution
Message-ID: <20170703085506.GB22607@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-2-stefanha@redhat.com>
 <0983a632-3f1d-06eb-2ffc-e04536c6c34c@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="l76fUT7nc3MelDdI"
In-Reply-To: <0983a632-3f1d-06eb-2ffc-e04536c6c34c@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30, 2017 at 10:34:54AM -0400, Steve Dickson wrote:
>=20
>=20
> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> > Although getaddrinfo(3) with IPPROTO_UDP works fine for AF_INET and
> > AF_INET6, the AF_VSOCK address family does not support IPPROTO_UDP and
> > produces an error.
> >=20
> > Drop IPPROTO_UDP and use the 0 default (TCP) which works for all address
> > families.  Modern NFS uses TCP anyway so it's strange to specify UDP.
> >=20
> > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> > Reviewed-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  utils/mount/stropts.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> >=20
> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> > index c2a739b..99656dd 100644
> > --- a/utils/mount/stropts.c
> > +++ b/utils/mount/stropts.c
> > @@ -909,9 +909,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
> >  	int result =3D 0;
> > =20
> >  	if (mi->address =3D=3D NULL) {
> > -		struct addrinfo hint =3D {
> > -			.ai_protocol	=3D (int)IPPROTO_UDP,
> > -		};
> > +		struct addrinfo hint =3D {};
> Just curious as to why not simply pass a NULL hints parameter=20
> verses an empty hints structure?

It's not clear from the surrounding unified diff context but the code
does set .ai_family later on:

  hint.ai_family =3D (int)mi->family;

Would you prefer it if I move that up into the variable definition?

  struct addrinfo hint =3D {
          .ai_family =3D (int)mi->family,
  };

--l76fUT7nc3MelDdI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZWgZpAAoJEJykq7OBq3PIFA4IALx1b4pFRL2PMRFomVnHEqf5
/P+Du9doFX+hCaQxXMErazCj0YNObTalBA0z8OeSEzUelEMxK1lglYQUKbmihjWQ
hkKrDXNYz2AKWYA/CTxUmtVo0uQVCa3aw/0IYTHmbS3LUXqZx0oTSSkX3QEtyQQF
F1/d25djF/nSjbz0rTLrmzWuIUnGS3cGJ8lcPIz8/Ql+OsmZY2v+CgPTlOcxa87k
IcLxwi7PWsbzKbSa9NQ1zaXFiE0wp3qLTkkmOH9s/M1gnRAz4rq4OljKSLN0s3Qf
MlLjoP1nh8zRop4I6zbyA3hMEJjCI6OXrVPWXT2zkZb0IS7FhPTpP8jA7mY3ydg=
=GerE
-----END PGP SIGNATURE-----

--l76fUT7nc3MelDdI--
