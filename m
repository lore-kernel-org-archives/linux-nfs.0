Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbbC3QNf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 12:13:35 -0400
Message-ID: <1427731980.21101.199.camel@redhat.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
From: Doug Ledford <dledford@redhat.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Majd Dibbiny <majd@mellanox.com>, Jiri Kosina <jkosina@suse.cz>,
        Matan Barak <matanb@mellanox.com>, Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 30 Mar 2015 12:13:00 -0400
In-Reply-To: <55157B98.1060103@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157B98.1060103@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-nkvnD6JO2Bf9VXiW0B1W"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-nkvnD6JO2Bf9VXiW0B1W
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 16:47 +0100, Michael Wang wrote:
> Introduce helper has_iwarp() to help us check if an IB device
> support IWARP protocol.

This is a needless redirection.  Just stick with the original
rdma_transport_is_iwarp().

> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  include/rdma/ib_verbs.h                 | 13 +++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |  2 +-
>  2 files changed, 14 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index e796104..0ef9cd7 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1836,6 +1836,19 @@ static inline int has_mcast(struct ib_device *devi=
ce)
>  }
> =20
>  /**
> + * has_iwarp - Check if a device support IWARP protocol.
> + *
> + * @device: Device to be checked
> + *
> + * Return 0 when a device has none port to support
> + * IWARP protocol.
> + */
> +static inline int has_iwarp(struct ib_device *device)
> +{
> +    return rdma_transport_is_iwarp(device);
> +}
> +
> +/**
>   * cap_smi - Check if the port of device has the capability
>   * Subnet Management Interface.
>   *
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdm=
a/svc_rdma_recvfrom.c
> index a7b5891..48aeb5e 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -118,7 +118,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp=
,
> =20
>  static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
>  {
> -    if (rdma_transport_is_iwarp(xprt->sc_cm_id->device))
> +    if (has_iwarp(xprt->sc_cm_id->device))
>          return 1;
>      else
>          return min_t(int, sge_count, xprt->sc_max_sge);


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-nkvnD6JO2Bf9VXiW0B1W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGXYMAAoJELgmozMOVy/dRK8P/RFutKZQuNVHsSJ6eDIChhvh
G+rkQ7Vq0L6Uuk1/Kqe308ls2WYkqLPe+IJYIG2ZXZZoEIyGHrG0Q4MMFg1Eq0B7
e39YkXjrWFuhSuqk3QkvULZks1oFkHdVaojq8aJEpaNov32wZ5y8xM79SBIVTwr4
qrLuobzk0JzhICzuSU/WtARJy8VUltQMKGjnliwW9vu+dbbXsUeED6DXRECqnw3z
lWlOgg7VEhSwJbUHi0TBu4wUU4iHueK+5T+xr8VzbHBTvzkNC9izDshG5oEgGZeR
8uSu1e0Dvux03l6toAZ67g60vcsFIzt5azxHuAbJaxg+uZcuOta1kDziPhblExS+
dLaFnoCY+RWaOQtP9Rf+KCeMUke01X5pAhBEI1gZLqFeu46Iut7SlibVXVxpxcec
pN5uXF+F1m/SIyBotDQ7jDa/tjs5/HblpcEBCHYpKddHvfCqFhOTcqPLEg86BFnM
3J5jHVyBWmbcOZs4iA24cz9WKvwcyVGPfKkS3o7KjkOTsQ3GvWtjip/NifkwGh45
phEnZktUzaiKTRcnr5AV52DYhfY7zSI0yKgLehCpjWv8KaqS3YTzf84EUWvUk35j
syaD4uCA0Wyn9PL8QvMI1h62xGZUdYaOODxpEX0URfBXeHoan0ZYr3vH8gVEU2W9
epeoMBDSVy2obV5f/vaW
=mdsr
-----END PGP SIGNATURE-----

--=-nkvnD6JO2Bf9VXiW0B1W--

