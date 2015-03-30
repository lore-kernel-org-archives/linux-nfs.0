Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860AbbC3QQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 12:16:35 -0400
Message-ID: <1427732191.21101.201.camel@redhat.com>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
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
Date: Mon, 30 Mar 2015 12:16:31 -0400
In-Reply-To: <55157B43.6060507@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157B43.6060507@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-5ADd0vGoGV4ieV93aC5H"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-5ADd0vGoGV4ieV93aC5H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 16:46 +0100, Michael Wang wrote:
> Introduce helper has_sa() and cap_sa() to help us check if an IB device
> or it's port support Subnet Administrator.

There's no functional reason to have both rdma_transport_is_ib and
rdma_port_ll_is_ib, just use one.  Then there is also no reason for both
has_sa and cap_sa.  Just use one.

> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  drivers/infiniband/core/sa_query.c | 12 ++++++------
>  include/rdma/ib_verbs.h            | 28 ++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core=
/sa_query.c
> index d95d25f..89c27da 100644
> --- a/drivers/infiniband/core/sa_query.c
> +++ b/drivers/infiniband/core/sa_query.c
> @@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *hand=
ler, struct ib_event *event
>          struct ib_sa_port *port =3D
>              &sa_dev->port[event->element.port_num - sa_dev->start_port];
> =20
> -        if (!rdma_port_ll_is_ib(handler->device, port->port_num))
> +        if (!cap_sa(handler->device, port->port_num))
>              return;
> =20
>          spin_lock_irqsave(&port->ah_lock, flags);
> @@ -1154,7 +1154,7 @@ static void ib_sa_add_one(struct ib_device *device)
>      struct ib_sa_device *sa_dev;
>      int s, e, i;
> =20
> -    if (!rdma_transport_is_ib(device))
> +    if (!has_sa(device))
>          return;
> =20
>      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH)
> @@ -1175,7 +1175,7 @@ static void ib_sa_add_one(struct ib_device *device)
> =20
>      for (i =3D 0; i <=3D e - s; ++i) {
>          spin_lock_init(&sa_dev->port[i].ah_lock);
> -        if (!rdma_port_ll_is_ib(device, i + 1))
> +        if (!cap_sa(device, i + 1))
>              continue;
> =20
>          sa_dev->port[i].sm_ah    =3D NULL;
> @@ -1205,14 +1205,14 @@ static void ib_sa_add_one(struct ib_device *devic=
e)
>          goto err;
> =20
>      for (i =3D 0; i <=3D e - s; ++i)
> -        if (rdma_port_ll_is_ib(device, i + 1))
> +        if (cap_sa(device, i + 1))
>              update_sm_ah(&sa_dev->port[i].update_task);
> =20
>      return;
> =20
>  err:
>      while (--i >=3D 0)
> -        if (rdma_port_ll_is_ib(device, i + 1))
> +        if (cap_sa(device, i + 1))
>              ib_unregister_mad_agent(sa_dev->port[i].agent);
> =20
>      kfree(sa_dev);
> @@ -1233,7 +1233,7 @@ static void ib_sa_remove_one(struct ib_device *devi=
ce)
>      flush_workqueue(ib_wq);
> =20
>      for (i =3D 0; i <=3D sa_dev->end_port - sa_dev->start_port; ++i) {
> -        if (rdma_port_ll_is_ib(device, i + 1)) {
> +        if (cap_sa(device, i + 1)) {
>              ib_unregister_mad_agent(sa_dev->port[i].agent);
>              if (sa_dev->port[i].sm_ah)
>                  kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index c0a63f8..fa8ffa3 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1810,6 +1810,19 @@ static inline int has_cm(struct ib_device *device)
>  }
> =20
>  /**
> + * has_sa - Check if a device support Subnet Administrator.
> + *
> + * @device: Device to be checked
> + *
> + * Return 0 when a device has none port to support
> + * Subnet Administrator.
> + */
> +static inline int has_sa(struct ib_device *device)
> +{
> +    return rdma_transport_is_ib(device);
> +}
> +
> +/**
>   * cap_smi - Check if the port of device has the capability
>   * Subnet Management Interface.
>   *
> @@ -1824,6 +1837,21 @@ static inline int cap_smi(struct ib_device *device=
, u8 port_num)
>      return rdma_port_ll_is_ib(device, port_num);
>  }
> =20
> +/**
> + * cap_sa - Check if the port of device has the capability
> + * Subnet Administrator.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device don't support
> + * Subnet Administrator.
> + */
> +static inline int cap_sa(struct ib_device *device, u8 port_num)
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



--=-5ADd0vGoGV4ieV93aC5H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGXbfAAoJELgmozMOVy/dAgAP/1iMoOpy0bgbs5+3lbDuZmdD
w78Ilt3a4lmtxBLeUiSol0+EeCYwMD7grc0ynQkeYZ4Yj8ll69vJwZ27RvaE8XLl
Ivgaq8IfgugYICH5VBpAks7aFuBIuCIO5RSKu58D5B3CjSxl+H1X3taSCHSJhl9Y
Jqdep8JZSCQVhcvirJz03zmAv0Zr4LvXH0py6evGKA/b5wEmtTQHr5Z+Rs1K21CQ
OdTpRa/YC1VBAJVz8H8Y6ufssvVgRKGjuGB0rBabWY17We3VuQMLol4UOIE4wnhi
j07II8zZtlRchlRbtGpXs3FMKomsncMcY2ecg6ZZO7PomgNIjmsnCVKiSVHshiXz
BY2XQt1AOVqTH0Sp5LgOjTrjVGMT3E0FQ/dN2DVq86InJARiGcSCInJPxgg8EgT5
3md3H/qnXU4yTBAZTOLQI05ztgYSHigyH7O4xRaHtOpDydoa/xu7Sm3wo0GopU4r
y9g3/wPPCrGO/S76Zd39nC0JyYYxaid0bkSOXzEXoE5gRVVD7Pv70QHZxJs5Zimm
pLRYaDO58rHw8itwm6CBeSBWxT5topNTOMO3n+JXxlWhyy9oo5zIzI1pyc57folp
OsKPSeOJHJ3TKw96hAd0RlK1Cju4mcUsEr7wKDmYYhtvRUvkmVbagyN211NsiqII
viCxFvKGS9XcZCrxWpjv
=1wC6
-----END PGP SIGNATURE-----

--=-5ADd0vGoGV4ieV93aC5H--

