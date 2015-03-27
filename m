Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbbC0TvW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 15:51:22 -0400
Message-ID: <1427485793.21101.135.camel@redhat.com>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
From: Doug Ledford <dledford@redhat.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org,
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
Date: Fri, 27 Mar 2015 15:49:53 -0400
In-Reply-To: <20150327164756.GA27862@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157B43.6060507@profitbricks.com>
	 <20150327164756.GA27862@phlsvsds.ph.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-5GKcvN7Ivd4FieuHmu4C"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-5GKcvN7Ivd4FieuHmu4C
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 12:47 -0400, ira.weiny wrote:
> On Fri, Mar 27, 2015 at 04:46:11PM +0100, Michael Wang wrote:
> >=20
> > Introduce helper has_sa() and cap_sa() to help us check if an IB device
> > or it's port support Subnet Administrator.
>=20
> I think these 2 should be combined.  The question is if a port requires t=
he use
> of the SA depending on the network it is connected to.
>=20
> Aren't some dual port Mellanox cards capable of doing IB on 1 port and Et=
h on
> the other?

Yes.

>   Do they show up as 2 devices?

No.  They are two ports of the same device with different link layers.
See here:

hca_id:	mlx4_1
	transport:			InfiniBand (0)
	fw_ver:				2.31.5050
	node_guid:			f452:1403:007b:cba0
	sys_image_guid:			f452:1403:007b:cba3
	vendor_id:			0x02c9
	vendor_part_id:			4099
	hw_ver:				0x0
	board_id:			MT_1090120019
	phys_port_cnt:			2
		port:	1
			state:			PORT_ACTIVE (4)
			max_mtu:		2048 (4)
			active_mtu:		2048 (4)
			sm_lid:			2
			port_lid:		2
			port_lmc:		0x01
			link_layer:		InfiniBand

		port:	2
			state:			PORT_ACTIVE (4)
			max_mtu:		4096 (5)
			active_mtu:		4096 (5)
			sm_lid:			0
			port_lid:		0
			port_lmc:		0x00
			link_layer:		Ethernet



> Regardless I think we should define the SA access on a per port basis.

Yes.

> >=20
> > Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> > Cc: Doug Ledford <dledford@redhat.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Sean Hefty <sean.hefty@intel.com>
> > Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> > ---
> >  drivers/infiniband/core/sa_query.c | 12 ++++++------
> >  include/rdma/ib_verbs.h            | 28 ++++++++++++++++++++++++++++
> >  2 files changed, 34 insertions(+), 6 deletions(-)
> >=20
> > diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/co=
re/sa_query.c
> > index d95d25f..89c27da 100644
> > --- a/drivers/infiniband/core/sa_query.c
> > +++ b/drivers/infiniband/core/sa_query.c
> > @@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *ha=
ndler, struct ib_event *event
> >          struct ib_sa_port *port =3D
> >              &sa_dev->port[event->element.port_num - sa_dev->start_port=
];
> > =20
> > -        if (!rdma_port_ll_is_ib(handler->device, port->port_num))
> > +        if (!cap_sa(handler->device, port->port_num))
> >              return;
> > =20
> >          spin_lock_irqsave(&port->ah_lock, flags);
> > @@ -1154,7 +1154,7 @@ static void ib_sa_add_one(struct ib_device *devic=
e)
> >      struct ib_sa_device *sa_dev;
> >      int s, e, i;
> > =20
> > -    if (!rdma_transport_is_ib(device))
> > +    if (!has_sa(device))
>=20
> The logic here should be:
>=20
> if (no ports of this device need sa access)
> 	return;
>=20
> So why not eliminate this check and allow the cap_sa(s) to handle the sup=
port?
>=20
> -- Ira
>=20
> >          return;
> > =20
> >      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH)
> > @@ -1175,7 +1175,7 @@ static void ib_sa_add_one(struct ib_device *devic=
e)
> > =20
> >      for (i =3D 0; i <=3D e - s; ++i) {
> >          spin_lock_init(&sa_dev->port[i].ah_lock);
> > -        if (!rdma_port_ll_is_ib(device, i + 1))
> > +        if (!cap_sa(device, i + 1))
> >              continue;
> > =20
> >          sa_dev->port[i].sm_ah    =3D NULL;
> > @@ -1205,14 +1205,14 @@ static void ib_sa_add_one(struct ib_device *dev=
ice)
> >          goto err;
> > =20
> >      for (i =3D 0; i <=3D e - s; ++i)
> > -        if (rdma_port_ll_is_ib(device, i + 1))
> > +        if (cap_sa(device, i + 1))
> >              update_sm_ah(&sa_dev->port[i].update_task);
> > =20
> >      return;
> > =20
> >  err:
> >      while (--i >=3D 0)
> > -        if (rdma_port_ll_is_ib(device, i + 1))
> > +        if (cap_sa(device, i + 1))
> >              ib_unregister_mad_agent(sa_dev->port[i].agent);
> > =20
> >      kfree(sa_dev);
> > @@ -1233,7 +1233,7 @@ static void ib_sa_remove_one(struct ib_device *de=
vice)
> >      flush_workqueue(ib_wq);
> > =20
> >      for (i =3D 0; i <=3D sa_dev->end_port - sa_dev->start_port; ++i) {
> > -        if (rdma_port_ll_is_ib(device, i + 1)) {
> > +        if (cap_sa(device, i + 1)) {
> >              ib_unregister_mad_agent(sa_dev->port[i].agent);
> >              if (sa_dev->port[i].sm_ah)
> >                  kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
> > diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> > index c0a63f8..fa8ffa3 100644
> > --- a/include/rdma/ib_verbs.h
> > +++ b/include/rdma/ib_verbs.h
> > @@ -1810,6 +1810,19 @@ static inline int has_cm(struct ib_device *devic=
e)
> >  }
> > =20
> >  /**
> > + * has_sa - Check if a device support Subnet Administrator.
> > + *
> > + * @device: Device to be checked
> > + *
> > + * Return 0 when a device has none port to support
> > + * Subnet Administrator.
> > + */
> > +static inline int has_sa(struct ib_device *device)
> > +{
> > +    return rdma_transport_is_ib(device);
> > +}
> > +
> > +/**
> >   * cap_smi - Check if the port of device has the capability
> >   * Subnet Management Interface.
> >   *
> > @@ -1824,6 +1837,21 @@ static inline int cap_smi(struct ib_device *devi=
ce, u8 port_num)
> >      return rdma_port_ll_is_ib(device, port_num);
> >  }
> > =20
> > +/**
> > + * cap_sa - Check if the port of device has the capability
> > + * Subnet Administrator.
> > + *
> > + * @device: Device to be checked
> > + * @port_num: Port number of the device
> > + *
> > + * Return 0 when port of the device don't support
> > + * Subnet Administrator.
> > + */
> > +static inline int cap_sa(struct ib_device *device, u8 port_num)
> > +{
> > +    return rdma_port_ll_is_ib(device, port_num);
> > +}
> > +
> >  int ib_query_gid(struct ib_device *device,
> >           u8 port_num, int index, union ib_gid *gid);
> > =20
> > --=20
> > 2.1.0
> >=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-5GKcvN7Ivd4FieuHmu4C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVFbRhAAoJELgmozMOVy/dEeQP/iaILcLhfC55U2sHBzBOnWn3
13QyNOPi2SE87pOVqjTlcwAKSyAWy8sYwVXznhjePNhWjaWF7g/ZpVlESShfOSQg
yLhPhHqNtW+gDIsJasj/YHA+7ix0ZbssQpzZpqEkqXsl10mP0VM8tx043LZ/L355
dsK90LK5lhdWrsfCk+Kd9jTqOZwKwQzkm8kls+RzKM+6I4KlMpAoIr4EgHbX9MCy
GK+NI6KqBU2VNCpsbUDehvkwefNWJDjSGumiq4op5PSKB1c0VVFVIm/jae6PAfc9
yctau+/9FF6aDqBikFxEshRIZviKzP9s3JvsVUzSpyhjosxwpsM9TJ/nbrnu/5f4
1wuvx1DAFpxyszdH+iZRqVh6YdVyW7hRkIMS7Oh1CaUKJ5C1ugDkBawymymCcvYL
HZD8XZaYvg1sb933DIDwLYiOb0p8YVywBGkM/CLh6wZ+Ki7D0ztnILxd2lNmVN/g
KGfm3StnUAyChkif2jdAxSu/dXyJKv3ITkAY3GhnKtC+tF2e716Z/rH6rIZJyr1u
5t8NRW2XOk6bXXe+SbvMFmGaWNf2IBFP2/zgyx0xMtcOoR8Psea+yGBeRl8bpD6a
yiIixAVXS8mFIZaA6AjNJWK5veJvMiIgqc1rjEaXJiWiQ+fpd/j0dar6YKoilhFV
SrcDRqKqWtwXS0hgy14q
=EWPW
-----END PGP SIGNATURE-----

--=-5GKcvN7Ivd4FieuHmu4C--

