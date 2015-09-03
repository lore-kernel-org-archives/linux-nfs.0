Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbbICUL6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2015 16:11:58 -0400
Subject: Re: [PATCH v2] xprtrdma: take HCA driver refcount at client
To: Devesh Sharma <devesh.sharma@avagotech.com>, linux-rdma@vger.kernel.org
References: <1438254018-2816-1-git-send-email-devesh.sharma@avagotech.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
From: Doug Ledford <dledford@redhat.com>
Message-ID: <55E8A98D.5060903@redhat.com>
Date: Thu, 3 Sep 2015 16:11:57 -0400
MIME-Version: 1.0
In-Reply-To: <1438254018-2816-1-git-send-email-devesh.sharma@avagotech.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="D8uehQBap84PGb1eLFTRrAdpkCQpR64lA"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--D8uehQBap84PGb1eLFTRrAdpkCQpR64lA
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/30/2015 07:00 AM, Devesh Sharma wrote:
> Thanks Chuck Lever for the valuable feedback and suggestions.
>=20
> This is a rework of the following patch sent almost a year back:
> http://www.mail-archive.com/linux-rdma%40vger.kernel.org/msg20730.html
>=20
> In presence of active mount if someone tries to rmmod vendor-driver, th=
e
> command remains stuck forever waiting for destruction of all rdma-cm-id=
=2E
> in worst case client can crash during shutdown with active mounts.
>=20
> The existing code assumes that ia->ri_id->device cannot change during
> the lifetime of a transport. xprtrdma do not have support for
> DEVICE_REMOVAL event either. Lifting that assumption and adding support=

> for DEVICE_REMOVAL event is a long chain of work, and is in plan.
>=20
> The community decided that preventing the hang right now is more
> important than waiting for architectural changes.
>=20
> Thus, this patch introduces a temporary workaround to acquire HCA drive=
r
> module reference count during the mount of a nfs-rdma mount point.
>=20
> Cc: chuck.lever@oracle.com
> Cc: linux-nfs@vger.kernel.org
> Signed-off-by: Devesh Sharma <devesh.sharma@avagotech.com>
> Reviewed-by: Sagi Grimberg <sagig@dev.mellanox.co.il>

Chuck, was this given final approval, and if so, who's tree is it
expected to go through?  Just trying to make sure I don't need to do
anything here as I don't see a rejection in my linux-rdma folder, but I
also didn't see it in the initial 4.3 nfs merge.

> ---
>  net/sunrpc/xprtrdma/verbs.c |   38 ++++++++++++++++++++++++++++++-----=
---
>  1 files changed, 30 insertions(+), 8 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 891c4ed..1c3c420 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -52,6 +52,7 @@
>  #include <linux/prefetch.h>
>  #include <linux/sunrpc/addr.h>
>  #include <asm/bitops.h>
> +#include <linux/module.h> /* try_module_get()/module_put() */
> =20
>  #include "xprt_rdma.h"
> =20
> @@ -414,6 +415,14 @@ connected:
>  	return 0;
>  }
> =20
> +static void rpcrdma_destroy_id(struct rdma_cm_id *id)
> +{
> +	if (id) {
> +		module_put(id->device->owner);
> +		rdma_destroy_id(id);
> +	}
> +}
> +
>  static struct rdma_cm_id *
>  rpcrdma_create_id(struct rpcrdma_xprt *xprt,
>  			struct rpcrdma_ia *ia, struct sockaddr *addr)
> @@ -440,6 +449,18 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
>  	}
>  	wait_for_completion_interruptible_timeout(&ia->ri_done,
>  				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
> +
> +	/* FIXME: We hate to break the notion of ULP<-->Core<-->Provider
> +	 * by calling try_module_get() on HCA driver. This is to prevent a
> +	 * system hang or a possible crash during reboot with active nfs-rdma=

> +	 * mount. We will keep this workaround until xprtrdma comes back with=
 a
> +	 * massive architectural changes to have proper fix.
> +	 */
> +	if (!ia->ri_async_rc && !try_module_get(id->device->owner)) {
> +		dprintk("RPC:       %s: Failed to get device module\n",
> +			__func__);
> +		ia->ri_async_rc =3D -ENODEV;
> +	}
>  	rc =3D ia->ri_async_rc;
>  	if (rc)
>  		goto out;
> @@ -449,16 +470,17 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
>  	if (rc) {
>  		dprintk("RPC:       %s: rdma_resolve_route() failed %i\n",
>  			__func__, rc);
> -		goto out;
> +		goto put;
>  	}
>  	wait_for_completion_interruptible_timeout(&ia->ri_done,
>  				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
>  	rc =3D ia->ri_async_rc;
>  	if (rc)
> -		goto out;
> +		goto put;
> =20
>  	return id;
> -
> +put:
> +	module_put(id->device->owner);
>  out:
>  	rdma_destroy_id(id);
>  	return ERR_PTR(rc);
> @@ -592,7 +614,7 @@ out3:
>  	ib_dealloc_pd(ia->ri_pd);
>  	ia->ri_pd =3D NULL;
>  out2:
> -	rdma_destroy_id(ia->ri_id);
> +	rpcrdma_destroy_id(ia->ri_id);
>  	ia->ri_id =3D NULL;
>  out1:
>  	return rc;
> @@ -618,7 +640,7 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>  	if (ia->ri_id !=3D NULL && !IS_ERR(ia->ri_id)) {
>  		if (ia->ri_id->qp)
>  			rdma_destroy_qp(ia->ri_id);
> -		rdma_destroy_id(ia->ri_id);
> +		rpcrdma_destroy_id(ia->ri_id);
>  		ia->ri_id =3D NULL;
>  	}
> =20
> @@ -825,7 +847,7 @@ retry:
>  		if (ia->ri_device !=3D id->device) {
>  			printk("RPC:       %s: can't reconnect on "
>  				"different device!\n", __func__);
> -			rdma_destroy_id(id);
> +			rpcrdma_destroy_id(id);
>  			rc =3D -ENETUNREACH;
>  			goto out;
>  		}
> @@ -834,7 +856,7 @@ retry:
>  		if (rc) {
>  			dprintk("RPC:       %s: rdma_create_qp failed %i\n",
>  				__func__, rc);
> -			rdma_destroy_id(id);
> +			rpcrdma_destroy_id(id);
>  			rc =3D -ENETUNREACH;
>  			goto out;
>  		}
> @@ -845,7 +867,7 @@ retry:
>  		write_unlock(&ia->ri_qplock);
> =20
>  		rdma_destroy_qp(old);
> -		rdma_destroy_id(old);
> +		rpcrdma_destroy_id(old);
>  	} else {
>  		dprintk("RPC:       %s: connecting...\n", __func__);
>  		rc =3D rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--D8uehQBap84PGb1eLFTRrAdpkCQpR64lA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJV6KmNAAoJELgmozMOVy/d2mkP/2Wb7q2dpRQOObrNKaPzXhnC
RLWgXsfQKZtbBLCeAE3wD/ebtFsOSVCx1aLaS5xpJLkFibuQKPEdmTsj7wirAjrM
D8LqFETWmmwxbNjFcfO4mxZ3mKfVrNqBFXPKnePc7L0X05Jmu9DU+Y+mrp6FmESg
2eXganIa5zyBcF/FHb0SRkU4oLPDWbFvhrPm4HPh8xUVEPqU+w94WdC3HpivDTq7
tMDGELbxk7mg8QpE4eFeYhXlW+HEcCzTu2UkmmZUCvo8q72JORmgpfHQhmD/6pyT
NhlWiXMz/ydzRAOXzIe+rqY9uTZ6V94VWcGWUz1gnJgLCGeDj6WlzExaXGGcBVa0
CJj24GW20u/Sxw8lBN3hk6PeS7XT8r+S2xcMty8HNmK3X0WGXcmTCHPtzwGxo3Ib
Ove9U+xv5YsZlvSL9ljAm2IyBTXnZmt7oPTb3Hqr1eRgiTMM+QJjJmM5cwYlwx43
Sp1y8X8l0LpVoQLRuq4e7ho7jOuxa+qr8j54woPleGDOXzURkNEknwCgZdzbSC3w
+0eKBXCx1Mv6DpcRSNkbThI8lZ1Rjpe8YxsgULdDXSNqer9mdrN2bgnm5sqHmgmg
xQp9d2Ea7jph1yIreleQBOOKcABJtHxwijBGRfI6w3I9W4z7BOrtrGnBYsjp0lGw
VVhwSojfuK7e3I0ryAG8
=mk7c
-----END PGP SIGNATURE-----

--D8uehQBap84PGb1eLFTRrAdpkCQpR64lA--
