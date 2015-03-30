Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739AbbC3QMi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 12:12:38 -0400
Message-ID: <1427731918.21101.198.camel@redhat.com>
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast()
 and, cap_mcast() for mcast-check
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
Date: Mon, 30 Mar 2015 12:11:58 -0400
In-Reply-To: <55157B71.6040505@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157B71.6040505@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-DxZVAR/SpBiGhZXnE7sN"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-DxZVAR/SpBiGhZXnE7sN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 16:46 +0100, Michael Wang wrote:
> Introduce helper has_mcast() and cap_mcast() to help us check if an
> IB device or it's port support Multicast.

This probably needs reworded or rethought.  In truth, *all* rdma devices
are multicast capable.  *BUT*, IB/OPA devices require multicast
registration done the IB way (including for sendonly multicast sends),
while Ethernet devices do multicast the Ethernet way.  These tests are
really just for IB specific multicast registration and deregistration.
Call it has_mcast() and cap_mcast() is incorrect.

> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  drivers/infiniband/core/cma.c       |  2 +-
>  drivers/infiniband/core/multicast.c |  8 ++++----
>  include/rdma/ib_verbs.h             | 28 ++++++++++++++++++++++++++++
>  3 files changed, 33 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.=
c
> index 276fb76..cbbc85b 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -3398,7 +3398,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, st=
ruct sockaddr *addr)
>                  ib_detach_mcast(id->qp,
>                          &mc->multicast.ib->rec.mgid,
>                          be16_to_cpu(mc->multicast.ib->rec.mlid));
> -            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
> +            if (has_mcast(id_priv->cma_dev->device)) {
>                  switch (rdma_port_get_link_layer(id->device, id->port_nu=
m)) {
>                  case IB_LINK_LAYER_INFINIBAND:
>                      ib_sa_free_multicast(mc->multicast.ib);
> diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/cor=
e/multicast.c
> index 17573ff..ffeaf27 100644
> --- a/drivers/infiniband/core/multicast.c
> +++ b/drivers/infiniband/core/multicast.c
> @@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handl=
er *handler,
>      int index;
> =20
>      dev =3D container_of(handler, struct mcast_device, event_handler);
> -    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
> +    if (!cap_mcast(dev->device, event->element.port_num))
>          return;
> =20
>      index =3D event->element.port_num - dev->start_port;
> @@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
>      int i;
>      int count =3D 0;
> =20
> -    if (!rdma_transport_is_ib(device))
> +    if (!has_mcast(device))
>          return;
> =20
>      dev =3D kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
> @@ -823,7 +823,7 @@ static void mcast_add_one(struct ib_device *device)
>      }
> =20
>      for (i =3D 0; i <=3D dev->end_port - dev->start_port; i++) {
> -        if (!rdma_port_ll_is_ib(device, dev->start_port + i))
> +        if (!cap_mcast(device, dev->start_port + i))
>              continue;
>          port =3D &dev->port[i];
>          port->dev =3D dev;
> @@ -861,7 +861,7 @@ static void mcast_remove_one(struct ib_device *device=
)
>      flush_workqueue(mcast_wq);
> =20
>      for (i =3D 0; i <=3D dev->end_port - dev->start_port; i++) {
> -        if (rdma_port_ll_is_ib(device, dev->start_port + i)) {
> +        if (cap_mcast(device, dev->start_port + i)) {
>              port =3D &dev->port[i];
>              deref_port(port);
>              wait_for_completion(&port->comp);
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index fa8ffa3..e796104 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1823,6 +1823,19 @@ static inline int has_sa(struct ib_device *device)
>  }
> =20
>  /**
> + * has_mcast - Check if a device support Multicast.
> + *
> + * @device: Device to be checked
> + *
> + * Return 0 when a device has none port to support
> + * Multicast.
> + */
> +static inline int has_mcast(struct ib_device *device)
> +{
> +    return rdma_transport_is_ib(device);
> +}
> +
> +/**
>   * cap_smi - Check if the port of device has the capability
>   * Subnet Management Interface.
>   *
> @@ -1852,6 +1865,21 @@ static inline int cap_sa(struct ib_device *device,=
 u8 port_num)
>      return rdma_port_ll_is_ib(device, port_num);
>  }
> =20
> +/**
> + * cap_mcast - Check if the port of device has the capability
> + * Multicast.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device don't support
> + * Multicast.
> + */
> +static inline int cap_mcast(struct ib_device *device, u8 port_num)
> +{
> +    return rdma_port_ll_is_ib(device, port_num);
> +}
> +
>  int ib_query_gid(struct ib_device *device,
>           u8 port_num, int index, union ib_gid *gid);
> =20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-DxZVAR/SpBiGhZXnE7sN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGXXOAAoJELgmozMOVy/dPN4P/jzpO1F9xOyPb53nRLYLq07f
A8f7pG8RFU7myKmaXnQbx+WSy0Puc8G2g6UGVysK393fVX9TsMy1Nhn2KdoSaqJl
nneh6qJRnv2nWnhDkn2J0LqIjrjyvXTeP7fnOPmRyDGov1LpPJnkSZtdyAP3CZAe
A8vJ8+zHWgEqOynMJUXC6AwFnrpyS+WaVpoly9fXjpA9vbEgyQel7NC2tpulkAsz
dbkfqYa63+3f5kzpT/3q8ayJGmY2lSlHgOclOYSDq7aImP4fUv1pioD9K7RlZX99
3iz83+aAHDXsBVWtSbzxipQSBgBcPYKnxw2eDn2klFJlWhtnijtw4Mh11MDCQJ/l
mipPP8Lb6z+ev2c2o2SiLQ58dRhoxNc8vnkP069PkJsGQJGd6Ak4o9wtkXTcv6yL
MAYRwZFTcRU5MSenPOpeebN4wFI14L9PbzsIuj6Liu9V3PneDzA2DEBEc16T/gE1
Ag+RovLRx1siFSe4k0vCwtE1CE48KFcP5K35+6XwKniuy4knSnV8o5JBSOmJVto2
zEZyHIkrNlDSLjXtEdFkLNPh3pTX5xCIYfki2Whe2kJO+3CPRTQd6plXXwZIxP5l
ZrR1wL6/S2LG6R2VP6GT4mSE80kQM+PGv5GUSt8KQOuoq8VU//BzOdXCItj/+eUC
nEtnSknhfgGSiysUjwR7
=ELot
-----END PGP SIGNATURE-----

--=-DxZVAR/SpBiGhZXnE7sN--

