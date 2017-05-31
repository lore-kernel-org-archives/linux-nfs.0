Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45036 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750902AbdEaEgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 May 2017 00:36:53 -0400
Date: Wed, 31 May 2017 07:36:50 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/17] ib_core: Enable and expose force_mr module
 parameter
Message-ID: <20170531043650.GI5406@mtr-leonro.local>
References: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
 <20170530181410.2992.90842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="dMdWWqg3F2Dv/qfw"
In-Reply-To: <20170530181410.2992.90842.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--dMdWWqg3F2Dv/qfw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 30, 2017 at 02:14:10PM -0400, Chuck Lever wrote:
> The fourth parameter of the module_param_named macro is a set of
> file permissions. Passing 0 there means that module parameter is
> not created and that adding "options ib_core force_mr=1" to a
> modprobe.conf file has no effect.
>
> The default setting of rdma_rw_force_mr continues to be 0, or false.
>
> Fixes: a060b5629ab0 ("IB/core: generic RDMA READ/WRITE API")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  drivers/infiniband/core/rw.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

I still would like to see this module parameter removed.
https://patchwork.kernel.org/patch/9727129/

There is no need to expose to user something which is used for one-time
debugging,

Thanks

> diff --git a/drivers/infiniband/core/rw.c b/drivers/infiniband/core/rw.c
> index dbfd854..1cc8f07 100644
> --- a/drivers/infiniband/core/rw.c
> +++ b/drivers/infiniband/core/rw.c
> @@ -23,7 +23,7 @@ enum {
>  };
>
>  static bool rdma_rw_force_mr;
> -module_param_named(force_mr, rdma_rw_force_mr, bool, 0);
> +module_param_named(force_mr, rdma_rw_force_mr, bool, 0644);
>  MODULE_PARM_DESC(force_mr, "Force usage of MRs for RDMA READ/WRITE operations");
>
>  /*
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--dMdWWqg3F2Dv/qfw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkuSGEACgkQ5GN7iDZy
WKfgNRAAiT2bfYmGDGiGN8PXsY6WT+L7cSzaVLFO3GsptkLiRb9PAScIUxj7v02a
IphwXqVEFc4uFk5k7wUOphydssTLRwjzBBFUHiU+FKjdtQ4s2FhMUf3VnekAm2qv
g3w5RCYUw8e440ADHa/jhVdg8/sj7DYndp8pIjlyRgqm6zY1OCYaYln1B0RPKyr8
7dPRZnyM3A7+Z78+lYba0i9hdMuhHSYozLgsFLCOvSFIgnHJFLYYqeeJZJm1nNie
WyWi2JZrZDgFKA/3oEKsGWi7mj/3c6QIpviYZPuJIcHkp7BvV+ztu1KlRqNOSrCM
H9CpSZwN7FDEdg85I0qu9HfyPtidPa0PQlKfinfpimrSoXkdv16+shIQl9acjKUs
IAqh71rGlUqDNWcjJ2GFsgM3UgK3Lqcny1qCGblLoJj54u7KP5XsDdNhvojAVZf1
4kbo1N+HnRBv46M3sae5LKfRBOnFJ/ebg4y1pZpmikjCv+Yrr0ODFdK7luqrezM1
xpG50Yke+tUDfrTRuYBzdNDItmgvYFDw3HLP/FKqRTLfFb7mKbZn5qjrYBQoAW4i
rkrYp+hWQxQy5eFHv6I58y9UCp/lPOlbBszOavOQ5Kzcj4RIfEKMxfv8JcrkiCJ/
mhh4KNv8tEndNcI/XJsOEx28vo0aWGXqr1KqlN85fk/cI7+6sGk=
=mRLW
-----END PGP SIGNATURE-----

--dMdWWqg3F2Dv/qfw--
