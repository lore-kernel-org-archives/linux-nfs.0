Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767AbbC3QRe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 12:17:34 -0400
Message-ID: <1427732250.21101.202.camel@redhat.com>
Subject: Re: [RFC PATCH 02/11] IB/Verbs: Use management helper tech_iboe()
 for iboe-check
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
Date: Mon, 30 Mar 2015 12:17:30 -0400
In-Reply-To: <55157A4F.1090301@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157A4F.1090301@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/0N6b25DvOTNJA4/Cn5h"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-/0N6b25DvOTNJA4/Cn5h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 16:42 +0100, Michael Wang wrote:
> Introduce helper tech_iboe() to help us check if the port of an IB
> device is using RoCE/IBoE technology.

Just use rdma_transport_is_roce() instead.

> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  drivers/infiniband/core/cma.c |  6 ++----
>  include/rdma/ib_verbs.h       | 16 ++++++++++++++++
>  2 files changed, 18 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.=
c
> index 668e955..280cfe3 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -375,8 +375,7 @@ static int cma_acquire_dev(struct rdma_id_private *id=
_priv,
>                       listen_id_priv->id.port_num) =3D=3D dev_ll) {
>          cma_dev =3D listen_id_priv->cma_dev;
>          port =3D listen_id_priv->id.port_num;
> -        if (rdma_transport_is_ib(cma_dev->device) &&
> -            rdma_port_ll_is_eth(cma_dev->device, port))
> +        if (tech_iboe(cma_dev->device, port))
>              ret =3D ib_find_cached_gid(cma_dev->device, &iboe_gid,
>                           &found_port, NULL);
>          else
> @@ -395,8 +394,7 @@ static int cma_acquire_dev(struct rdma_id_private *id=
_priv,
>                  listen_id_priv->id.port_num =3D=3D port)
>                  continue;
>              if (rdma_port_get_link_layer(cma_dev->device, port) =3D=3D d=
ev_ll) {
> -                if (rdma_transport_is_ib(cma_dev->device) &&
> -                    rdma_port_ll_is_eth(cma_dev->device, port))
> +                if (tech_iboe(cma_dev->device, port))
>                      ret =3D ib_find_cached_gid(cma_dev->device, &iboe_gi=
d, &found_port, NULL);
>                  else
>                      ret =3D ib_find_cached_gid(cma_dev->device, &gid, &f=
ound_port, NULL);
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index 2bf9094..ca6d6bc 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1767,6 +1767,22 @@ static inline int rdma_port_ll_is_eth(struct ib_de=
vice *device, u8 port_num)
>              =3D=3D IB_LINK_LAYER_ETHERNET;
>  }
> =20
> +/**
> + * tech_iboe - Check if the port of device using technology
> + * RoCE/IBoE.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device is not using technology
> + * RoCE/IBoE.
> + */
> +static inline int tech_iboe(struct ib_device *device, u8 port_num)
> +{
> +    return rdma_transport_is_ib(device) &&
> +            rdma_port_ll_is_eth(device, port_num);
> +}
> +
>  int ib_query_gid(struct ib_device *device,
>           u8 port_num, int index, union ib_gid *gid);
> =20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-/0N6b25DvOTNJA4/Cn5h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGXcaAAoJELgmozMOVy/dfOsP/1qrdA8/BgOwJ1r5SBQCRsPE
KVMzguH1Mbg6r/0xy2mx5JPDTdkZcaHtDg9dq/ZXu+cmBPNhgxsgZcktGc+2U364
2WEFSioUSHBQ61WVTNLLOXACgqdG3ZVSNSwU8u1MuMqTO0vgUQWIEbY56U6nfgSw
VEtZ/jINz7Uh29xFyzrgG+saG9x5NKzThi9OuP7p8mebvvemF0dheogB0hMko9xq
w8gcn0c0j0QQ9Y/Excbre1Tq7RvnsfY2Akk6G2IFjuOPsjmWo29DtztTahQQH399
ov+JKCa674jJpowbXSzL7sqfuB/oBTWgvh3vmr9EcCPLqulKP9FPuz9gjGZGBFxS
B4Zl2ENfu1t3Ji6wC+VXXza3eh+948DRUSqn0+YzOj9R3opLrDq7w+qmxvXH26Kj
W8YNaBebUsT6/3JM4/v5vxuGgDrmckVpgTBaEpt7YBMuhFgT/gdcfKhqxSt5erOl
LPJ73tYohejnjqS1L0jVnbPbNNXLTbfZXKgtCQZ+WwrEaxVpJUjDFUxbKy4hTwVE
wUdeGI9HSA9NEHx+0HYGC19fkBOToHCNQiVNkge7rc0v9tAVH+LboyqPooLIy8+w
iSAnNg+HzpH4+klD6eW0wO7ogt54Kacf+6p1NmNOZB/dp2qqdqVuvxC+fGsmGbfS
NxjfJ5ezm+Nv0fp42r+G
=oiy4
-----END PGP SIGNATURE-----

--=-/0N6b25DvOTNJA4/Cn5h--

