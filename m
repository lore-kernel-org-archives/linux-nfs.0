Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889AbbDJRKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 13:10:49 -0400
Message-ID: <1428685843.2980.353.camel@redhat.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
From: Doug Ledford <dledford@redhat.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 10 Apr 2015 13:10:43 -0400
In-Reply-To: <20150410074805.GA11855@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
	 <20150410074805.GA11855@phlsvsds.ph.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-wGHibIKtPtE3dHuVjn9e"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-wGHibIKtPtE3dHuVjn9e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 03:48 -0400, ira.weiny wrote:
> > > diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/co=
re/device.c
> > > index 18c1ece..a9587c4 100644
> > > --- a/drivers/infiniband/core/device.c
> > > +++ b/drivers/infiniband/core/device.c
> > > @@ -76,6 +76,7 @@ static int ib_device_check_mandatory(struct ib_devi=
ce *device)
> > >  	} mandatory_table[] =3D {
> > >  		IB_MANDATORY_FUNC(query_device),
> > >  		IB_MANDATORY_FUNC(query_port),
> > > +		IB_MANDATORY_FUNC(query_transport),
> > >  		IB_MANDATORY_FUNC(query_pkey),
> > >  		IB_MANDATORY_FUNC(query_gid),
> > >  		IB_MANDATORY_FUNC(alloc_pd),
> >=20
> > I'm concerned about the performance implications of this.  The size of
> > this patchset already points out just how many places in the code we
> > have to check for various aspects of the device transport in order to d=
o
> > the right thing.  Without going through the entire list to see how many
> > are on critical hot paths, I'm sure some of them are on at least
> > partially critical hot paths (like creation of new connections).  I
> > would prefer to see this change be implemented via a device attribute,
> > not a functional call query.  That adds a needless function call in
> > these paths.
>=20
> I like the idea of a query_transport but at the same time would like to s=
ee the
> use of "transport" reduced.  A reduction in the use of this call could
> eliminate most performance concerns.
>=20
> So can we keep this abstraction if at the end of the series we limit its =
use?

The reason I don't like a query is because the transport type isn't
changing.  It's a static device attribute.  The only devices that *can*
change their transport are mlx4 or mlx5 devices, and they tear down and
deregister their current device and bring up a new one when they need to
change transports or link layers.  So, this really isn't something we
should query, this should be part of our static device attributes.
Every other query in the list above is for something that changes.  This
is not.

> >=20
> > > diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/cor=
e/verbs.c
> > > index f93eb8d..83370de 100644
> > > --- a/drivers/infiniband/core/verbs.c
> > > +++ b/drivers/infiniband/core/verbs.c
> > > @@ -133,14 +133,16 @@ enum rdma_link_layer rdma_port_get_link_layer(s=
truct ib_device *device, u8 port_
> > >  	if (device->get_link_layer)
> > >  		return device->get_link_layer(device, port_num);
> > > =20
> > > -	switch (rdma_node_get_transport(device->node_type)) {
> > > +	switch (device->query_transport(device, port_num)) {
> > >  	case RDMA_TRANSPORT_IB:
> > > +	case RDMA_TRANSPORT_IBOE:
> > >  		return IB_LINK_LAYER_INFINIBAND;
> >=20
> > If we are perserving ABI, then this looks wrong.  Currently, IBOE
> > returnsi transport IB and link layer Ethernet.  It should not return
> > link layer IB, it does not support IB link layer operations (such as MA=
D
> > access).
>=20
> I think the original code has the bug.
>=20
> IBoE devices currently return a transport of IB but they probably never g=
et
> here because they support the get_link_layer callback used a few lines ab=
ove.
> So this "bug" was probably never hit.
>=20
> >=20
> > >  	case RDMA_TRANSPORT_IWARP:
> > >  	case RDMA_TRANSPORT_USNIC:
> > >  	case RDMA_TRANSPORT_USNIC_UDP:
> > >  		return IB_LINK_LAYER_ETHERNET;
> > >  	default:
> > > +		BUG();
> > >  		return IB_LINK_LAYER_UNSPECIFIED;
> > >  	}
> > >  }
> >=20
> > [ snip ]
> >=20
> > > diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> > > index 65994a1..d54f91e 100644
> > > --- a/include/rdma/ib_verbs.h
> > > +++ b/include/rdma/ib_verbs.h
> > > @@ -75,10 +75,13 @@ enum rdma_node_type {
> > >  };
> > > =20
> > >  enum rdma_transport_type {
> > > +	/* legacy for users */
> > >  	RDMA_TRANSPORT_IB,
> > >  	RDMA_TRANSPORT_IWARP,
> > >  	RDMA_TRANSPORT_USNIC,
> > > -	RDMA_TRANSPORT_USNIC_UDP
> > > +	RDMA_TRANSPORT_USNIC_UDP,
> > > +	/* new transport */
> > > +	RDMA_TRANSPORT_IBOE,
> > >  };
> >=20
> > I'm also concerned about this.  I would like to see this enum
> > essentially turned into a bitmap.  One that is constructed in such a wa=
y
> > that we can always get the specific test we need with only one compare
> > against the overall value.  In order to do so, we need to break it down
> > into the essential elements that are part of each of the transports.
> > So, for instance, we can define the two link layers we have so far, plu=
s
> > reserve one for OPA which we know is coming:
> >=20
> > RDMA_LINK_LAYER_IB       =3D 0x00000001,
> > RDMA_LINK_LAYER_ETH      =3D 0x00000002,
> > RDMA_LINK_LAYER_OPA      =3D 0x00000004,
> > RDMA_LINK_LAYER_MASK     =3D 0x0000000f,
>=20
> I would reserve more bits here.

Sure.  I didn't mean to imply that this was as large is these bit fields
would ever need to be, I just typed it up quickly at the time.

> >=20
> > We can then define the currently known high level transport types:
> >=20
> > RDMA_TRANSPORT_IB        =3D 0x00000010,
> > RDMA_TRANSPORT_IWARP     =3D 0x00000020,
> > RDMA_TRANSPORT_USNIC     =3D 0x00000040,
> > RDMA_TRANSPORT_USNIC_UDP =3D 0x00000080,
> > RDMA_TRANSPORT_MASK      =3D 0x000000f0,
>=20
> I would reserve more bits here.
>=20
> >=20
> > We could then define bits for the IB management types:
> >=20
> > RDMA_MGMT_IB             =3D 0x00000100,
> > RDMA_MGMT_OPA            =3D 0x00000200,
> > RDMA_MGMT_MASK           =3D 0x00000f00,
>=20
> We at least need bits for SA / CM support.
>=20
> I said previously all device types support QP1  I was wrong...  I forgot =
about
> USNIC devices.  So the full management bit mask is.
>=20
>=20
> RDMA_MGMT_IB_MAD         =3D 0x00000100,
> RDMA_MGMT_QP0            =3D 0x00000200,
> RDMA_MGMT_SA             =3D 0x00000400,
> RDMA_MGMT_CM             =3D 0x00000800,
> RDMA_MGMT_OPA_MAD        =3D 0x00001000,
> RDMA_MGMT_MASK           =3D 0x000fff00,
>=20
> With a couple of spares.
>=20
> The MAD stack is pretty agnostic to the types of MADs passing through it =
so we
> don't really need PM flags etc.
>=20
> >=20
> > Then we have space to define specific quirks:
> >=20
> > RDMA_SEPARATE_READ_SGE   =3D 0x00001000,
> > RDMA_QUIRKS_MASK         =3D 0xfffff000
>=20
> shift for spares...
>=20
> RDMA_SEPARATE_READ_SGE   =3D 0x00100000,
> RDMA_QUIRKS_MASK         =3D 0xfff00000
>=20
> >=20
> > Once those are defined, a few definitions for device drivers to use whe=
n
> > they initialize a device to set the bitmap to the right values:
> >=20
> > #define IS_IWARP (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_IWARP |
> > RDMA_SEPARATE_READ_SGE)
> > #define IS_IB (RDMA_LINK_LAYER_IB | RDMA_TRANSPORT_IB | RDMA_MGMT_IB)
> > #define IS_IBOE (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_IB)
> > #define IS_USNIC (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_USNIC)
> > #define IS_OPA (RDMA_LINK_LAYER_OPA | RDMA_TRANSPORT_IB | RDMA_MGMT_IB =
|
> > RDMA_MGMT_OPA)
> >=20
> > Then you need to define the tests:
> >=20
> > static inline bool
> > rdma_transport_is_iwarp(struct ib_device *dev, u8 port)
> > {
> > 	return dev->port[port]->transport & RDMA_TRANSPORT_IWARP;
> > }
> >=20
> > /* Note: this intentionally covers IB, IBOE, and OPA...use
> >    rdma_dev_is_ib if you want to only get physical IB devices */
> > static inline bool
> > rdma_transport_is_ib(struct ibdev *dev)
> > {
> > 	return dev->port[port]->transport & RDMA_TRANSPORT_IB;
> > }
> >=20
> > rdma_port_is_ib(struct ib_device *dev, u8 port)
>=20
> I prefer
>=20
> rdma_port_link_layer_is_ib
> rdma_port_link_layer_is_eth

In my quick example, anything that started with rdma_transport* was
testing the high level transport attribute of any given port of any
given device, and anything that started with rdma_port* was testing the
link layer on a specific port of any given device.

>=20
> > {
> > 	return dev->port[port]->transport & RDMA_LINK_LAYER_IB;
> > }
> >=20
> > rdma_port_is_iboe(struct ib_device *dev, u8 port)
>=20
> I'm not sure what this means.
>=20
> rdma_port_req_iboe_addr seems more appropriate because what we really nee=
d to
> know is that this device requires an IBoE address format.  (PKey is "fake=
",
> PathRecord is fabricated rather than queried, GRH is required in the AH
> conversion.)

TomAto, Tomato...port_is_ib implicity means port_req_iboe_addr.
>=20
> > {
> > 	return dev->port[port]->transport & IS_IBOE =3D=3D IS_IBOE;
> > }
> >=20
> > rdma_port_is_usnic(struct ib_device *dev, u8 port)
>=20
> rdma_transport_is_usnic
>=20
> > {
> > 	return dev->port[port]->transport & RDMA_TRANSPORT_USNIC;
> > }
> >=20
> > rdma_port_is_opa(struct ib_device *dev, u8 port)
>=20
> rdma_port_link_layer_is_opa
>=20
> > {
> > 	return dev->port[port]->transport & RDMA_LINK_LAYER_OPA;
> > }
> >=20
> > rdma_port_is_iwarp(struct ib_device *dev, u8 port)
> > {
> > 	return rdma_transport_is_iwarp(dev, port);
>=20
> Why not call rdma_transport_is_iwarp?

As per my above statement, rdma_transport* tests were testing the high
level transport type, rdma_port* types were testing link layers.  iWARP
has an Eth link layer, so technically port_is_iwarp makes no sense.  But
since all the other types had a check too, I included port_is_iwarp just
to be complete, and if you are going to ask if a specific port is iwarp
as a link layer, it makes sense to say yes if the transport is iwarp,
not if the link layer is eth.

[ snip lots of stuff that is all correct ]

> > Patch 8/17:
> >=20
> > Here we can create a new test if we are using the bitmap I created
> > above:
> >=20
> > rdma_port_ipoib(struct ib_device *dev, u8 port)
> > {
> > 	return !(dev->port[port]->transport & RDMA_LINK_LAYER_ETH);
>=20
> I would prefer a link layer (or generic) bit mask rather than '&' of
> "transport" and "link layer".  That just seems wrong.

I kept the name transport, but it's really a device attribute bitmap.
And of all the link layer types, eth is the only one for which IPoIB
makes no sense (even if it's possible to do).  So, as long as the ETH
bit isn't set, we're good to go.  But, calling it
dev->port[port]->attributes instead of transport would make it more
clear what it is.

> I guess rdma_dev_is_iboe is ok.  But it seems like we are keying off the
> addresses not necessarily the devices.

They're one and the same.  The addresses go with the device, the device
goes with the addresses.  You never have one without the other.  The
name of the check is not really important, just as long as it's clearly
documented.  I get why you link the address variant, because it pops out
all the things that are special about IBoE addressing and calls out that
the issues need to be handled.  However, saying requires_iboe_addr(),
while foreshadowing the work that needs done, doesn't actually document
the work that needs done.  Whether we call is dev_is_iboe() or
requires_iboe_addr(), it would be good if the documentation spelled out
those specific requirements for reference sake.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-wGHibIKtPtE3dHuVjn9e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVKAQTAAoJELgmozMOVy/dvAgQAKJD7wxQGhs45JApn1AQYezD
vTzBzIYlMRCD2BJfglJvTXE1USJhJN5GCGLd9J4WuwUmAf2J7kzhkT+1nqyB1chv
v9MXzewJAZ48RQ9HezWJb9xREoenHl887wvKIRz1EntzxdEzZsyjoEbp/qDO1b+T
1aeVX/wQ2cjQCiFRwbMhpomE4huB0uPOR5ELEgEw26e/sJ14j5j+S4g22OWWf2cr
RRSFNXhaJ5UZHJJtw+QAbId9G5dmALG2sdJ2y7s+4mUSx3b2bXdNJh4seDB9nVaY
ijFwMt4ThAxSSZ6v6YuGXOuCNJlbiJZjr+cO3a0o0wIXmgMv/muFrhZNyxGYWwET
abMJC/TmQIg9G1uId8r+s8fGfPV8cOZf4nxPXvOS5iz2mhKzVoHTpcuFFefF0xwQ
XGcs/Hqyjvb8U+/TpSPMTB9tCZ6DGu+GfW0PmutOWpQiE5EYNAqMUBOrdnyxhooN
2sPI3k74XG75/gcBgU4kiGWAiHnCesLzvh0R4bdHtNQZZ7zc1rOjSKekJyY4tPqe
cviVncFOT+QKXrFy3uZz17hsT6JKpPCsWeHD9DKvA+GVqg5Mskb8WfVJ9yiCLbnE
iDWt8ikcwh6zhp1zIzfUngXsI6GYNpaf+ufnUUO3tXFybORyCaca9NWze5a7gjlp
mW91sK/uEGMehg+OgSz0
=60Te
-----END PGP SIGNATURE-----

--=-wGHibIKtPtE3dHuVjn9e--

