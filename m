Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49054 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbcEDGhr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2016 02:37:47 -0400
Date: Wed, 4 May 2016 09:37:21 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 20/20] xprtrdma: Faster server reboot recovery
Message-ID: <20160504063721.GG29160@leon.nu>
Reply-To: leon@kernel.org
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
 <20160502184303.10798.4709.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GdbWtwDHkcXqP16f"
In-Reply-To: <20160502184303.10798.4709.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--GdbWtwDHkcXqP16f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 02, 2016 at 02:43:03PM -0400, Chuck Lever wrote:
> In a cluster failover scenario, it is desirable for the client to
> attempt to reconnect quickly, as an alternate NFS server is already
> waiting to take over for the down server. The client can't see that
> a server IP address has moved to a new server until the existing
> connection is gone.
>=20
> For fabrics and devices where it is meaningful, set a definite upper
> bound on the amount of time before it is determined that a
> connection is no longer valid. This allows the RPC client to detect
> connection loss in a timely matter, then perform a fresh resolution
> of the server GUID in case it has changed (cluster failover).
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: Steve Wise <swise@opengridcomputing.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index b7a5bc1..be66f65 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -554,6 +554,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrd=
ma_ia *ia,
>  	ep->rep_attr.recv_cq =3D recvcq;
> =20
>  	/* Initialize cma parameters */
> +	memset(&ep->rep_remote_cma, 0, sizeof(ep->rep_remote_cma));
> =20
>  	/* RPC/RDMA does not use private data */
>  	ep->rep_remote_cma.private_data =3D NULL;
> @@ -567,7 +568,16 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcr=
dma_ia *ia,
>  		ep->rep_remote_cma.responder_resources =3D
>  						ia->ri_device->attrs.max_qp_rd_atom;
> =20
> -	ep->rep_remote_cma.retry_count =3D 7;
> +	/* Limit transport retries so client can detect server
> +	 * GID changes quickly. RPC layer handles re-establishing
> +	 * transport connection and retransmission.
> +	 */
> +	ep->rep_remote_cma.retry_count =3D 6;

Out of curiosity,
Do you know how much time take this retry cycle?
I understand why lowering retry count will cause to faster reconnect,
but I wonder will it be really visible.

> +
> +	/* RPC-over-RDMA handles its own flow control. In addition,
> +	 * make all RNR NAKs visible so we know that RPC-over-RDMA
> +	 * flow control is working correctly (no NAKs should be seen).
> +	 */
>  	ep->rep_remote_cma.flow_control =3D 0;
>  	ep->rep_remote_cma.rnr_retry_count =3D 0;
> =20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--GdbWtwDHkcXqP16f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXKZihAAoJEORje4g2clinF7kQAI4c3nfvY6LhL0fxX4sZD7sF
CSEFPljv/4CcV5tBsdfdD3jFQqriydSsdkZ44DDa88jF0CIr5gMnSrY1Hu3b4LT1
rU3tZ0yBR+9FL0IpWVrYdtHQNuLkY3d7Hzb1Y6fvSllBs7VVb2kArlzht5OCJNQ9
pjCIxN3bvpVdK32Eqp7dQvv2rEVZZZaOOxIuE5ULpBoaww+m78F8zpg67OSPlzZn
KJNGJlTlKBDqry6KAR1IR9PI2uIeCkV923svfGqkAF6eeSUjDeGiloP9vPGN9Wqs
EFZ3l93Zy3nQLM1GmkcSMVzy2FSjddIabtG14bNrsk2/CTe0s5oGrjK0AeVBAKIN
S+V/wuFVXBXv/4pghvB08k8wXpGyqUu+3F7B6yNZupgrcDpPubidrLOJa7MvmkuQ
JM7QY/U1ESqdqYW1ohKpijGmKOPbxjqFlf5DvF5P7o1H9sEc8KU5LYRmJQ/bC75k
cqzQtNWilyGb/HLcyhZlMCs7Pa7OLACA9sCGGqp0u0Kov18q18KnSBiElmWZw2Ko
APO1Lm/uhW/CBlTVCRVxblP5enPZTc9UyKIkwqIybY2d9ITtdKiDRdgE1QspATsd
E3QJ56HCtfIOaDq15fVDmXvuMuLA0jNVuRwNOSq5D4awegEKNZqevuQOItK4CHa+
VSgq9W9tbTg/GBbh/Eqo
=HDcN
-----END PGP SIGNATURE-----

--GdbWtwDHkcXqP16f--
