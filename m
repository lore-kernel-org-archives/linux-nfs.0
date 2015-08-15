Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33776 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbbHOBbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2015 21:31:34 -0400
Subject: Re: [PATCH] svcrdma: limit FRMR page list lengths to device max
To: Steve Wise <swise@opengridcomputing.com>
References: <20150807163539.EFDEFE0ACC@smtp.ogc.us>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
From: Doug Ledford <dledford@redhat.com>
Message-ID: <55CE9672.7040809@redhat.com>
Date: Fri, 14 Aug 2015 21:31:30 -0400
MIME-Version: 1.0
In-Reply-To: <20150807163539.EFDEFE0ACC@smtp.ogc.us>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="cwbkI6rhupXOD5lgh6ms6SIRCSxVl8RTj"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cwbkI6rhupXOD5lgh6ms6SIRCSxVl8RTj
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/07/2015 12:11 PM, Steve Wise wrote:
> Svcrdma was incorrectly allocating fastreg MRs and page lists using
> RPCSVC_MAXPAGES, which can exceed the device capabilities.  So limit
> the depth to the minimum of RPCSVC_MAXPAGES and xprt->sc_frmr_pg_list_l=
en.
>=20
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> Doug, this patch needs to be added after this commit:
>=20
> e20684a xprtrdma, svcrdma: Convert to ib_alloc_mr
>=20
> and before these commits:
>=20
> af78181 cxgb3: Support ib_alloc_mr verb
> b7e06cd iw_cxgb4: Support ib_alloc_mr verb

Done.

> This will avoid a bisect window where NFSRDMA over cxgb4 is broken.
>=20
> Bruce, please ACK if this commit looks good, and also if you're ok with=

> this flowing through Doug's rdma tree due to the dependencies.
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprt=
rdma/svc_rdma_transport.c
> index 8752a2d..11d5133 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -733,17 +733,19 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frm=
r(struct svcxprt_rdma *xprt)
>  	struct ib_mr *mr;
>  	struct ib_fast_reg_page_list *pl;
>  	struct svc_rdma_fastreg_mr *frmr;
> +	u32 num_sg;
> =20
>  	frmr =3D kmalloc(sizeof(*frmr), GFP_KERNEL);
>  	if (!frmr)
>  		goto err;
> =20
> -	mr =3D ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, RPCSVC_MAXPAGES);=

> +	num_sg =3D min_t(u32, RPCSVC_MAXPAGES, xprt->sc_frmr_pg_list_len);
> +	mr =3D ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, num_sg);
>  	if (IS_ERR(mr))
>  		goto err_free_frmr;
> =20
>  	pl =3D ib_alloc_fast_reg_page_list(xprt->sc_cm_id->device,
> -					 RPCSVC_MAXPAGES);
> +					 num_sg);
>  	if (IS_ERR(pl))
>  		goto err_free_mr;
> =20
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--cwbkI6rhupXOD5lgh6ms6SIRCSxVl8RTj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVzpZyAAoJELgmozMOVy/dlFcQALSu6hsuup9meZHhYm/TZ9eQ
75JAnmANpsTC6OvOJNLCc9G62EUmsTQuNifUKzfnCt3MyhFPcHMiNyE866PlKQk6
Od0Q0Ls3erzrj92D9jHQRNN1jd0uT7WJCyhUmjHEm+vvNJ+aUMJ7qri+th6sb7mT
Qfuu06A8tOcAKlh+SRkrRPQ8RHx7bny4kAhYbER2qe/8qy2KrHLw04m/jRC/7OAD
LQXlx4QaNA2OwIq4r8MBLLqaYphIWNXx76Og0jQHw94lHU5f0exe9ciXvFG6DT8S
zK9jZMLkp4r4Pb3IwelLD38kzelHvn47/Q+5CoWahliugvqbYBwDit6YohAJQnSU
4XZHwRk24WKerbY92aSXkkWgEW9iQGEvygyEf8oWzs2FdzFu6RMBzbw4/Oz+F02i
QAKwYoOg8Yo2PEjtAUwPoC2ThTlMZJZUMpYKFRzYc7kDHImtVt05jXap6rKklRyf
pKVf6bxVCzA6A5/2xvrj1fkUOr4L1L3ZTQFfMwVEFybhRPl0jVxWsX5UtGVGrTfm
Hilbc4R6MIz+G9ssAi+ksFynF7A7nqJ6tgq9twK1d44J8LB66yrka7EO5XCCo65a
X+JGyZnSYcNZbg1+4tesnwUdZx4/4WrwipIhW8xWHg2scoGKirrcYyFEqPf+KYxJ
6/MX4shnhv7YpUGCWMzG
=vWs6
-----END PGP SIGNATURE-----

--cwbkI6rhupXOD5lgh6ms6SIRCSxVl8RTj--
