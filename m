Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604AbbDHSao (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 14:30:44 -0400
Message-ID: <1428517786.2980.180.camel@redhat.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
From: Doug Ledford <dledford@redhat.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
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
        Ira Weiny <ira.weiny@intel.com>,
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
Date: Wed, 08 Apr 2015 14:29:46 -0400
In-Reply-To: <5523D098.3020007@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-bu8jIKuK2uA3rB8lqRbS"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-bu8jIKuK2uA3rB8lqRbS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-04-07 at 14:42 +0200, Michael Wang wrote:
> Add new callback query_transport() and implement for each HW.

My response here is going to be a long email, but that's because it's
easier to respond to the various patches all in one response in order to
preserve context.  So, while I'm responding to patch 1 of 17, my
response will cover all 17 patches in whole.

> Mapping List:
> 		node-type	link-layer	old-transport	new-transport
> nes		RNIC		ETH		IWARP		IWARP
> amso1100	RNIC		ETH		IWARP		IWARP
> cxgb3   	RNIC		ETH		IWARP		IWARP
> cxgb4   	RNIC		ETH		IWARP		IWARP
> usnic   	USNIC_UDP	ETH		USNIC_UDP	USNIC_UDP
> ocrdma  	IB_CA		ETH		IB		IBOE
> mlx4    	IB_CA		IB/ETH		IB		IB/IBOE
> mlx5    	IB_CA		IB		IB		IB
> ehca    	IB_CA		IB		IB		IB
> ipath   	IB_CA		IB		IB		IB
> mthca   	IB_CA		IB		IB		IB
> qib     	IB_CA		IB		IB		IB
>=20
> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  drivers/infiniband/core/device.c             |  1 +
>  drivers/infiniband/core/verbs.c              |  4 +++-
>  drivers/infiniband/hw/amso1100/c2_provider.c |  7 +++++++
>  drivers/infiniband/hw/cxgb3/iwch_provider.c  |  7 +++++++
>  drivers/infiniband/hw/cxgb4/provider.c       |  7 +++++++
>  drivers/infiniband/hw/ehca/ehca_hca.c        |  6 ++++++
>  drivers/infiniband/hw/ehca/ehca_iverbs.h     |  3 +++
>  drivers/infiniband/hw/ehca/ehca_main.c       |  1 +
>  drivers/infiniband/hw/ipath/ipath_verbs.c    |  7 +++++++
>  drivers/infiniband/hw/mlx4/main.c            | 10 ++++++++++
>  drivers/infiniband/hw/mlx5/main.c            |  7 +++++++
>  drivers/infiniband/hw/mthca/mthca_provider.c |  7 +++++++
>  drivers/infiniband/hw/nes/nes_verbs.c        |  6 ++++++
>  drivers/infiniband/hw/ocrdma/ocrdma_main.c   |  1 +
>  drivers/infiniband/hw/ocrdma/ocrdma_verbs.c  |  6 ++++++
>  drivers/infiniband/hw/ocrdma/ocrdma_verbs.h  |  3 +++
>  drivers/infiniband/hw/qib/qib_verbs.c        |  7 +++++++
>  drivers/infiniband/hw/usnic/usnic_ib_main.c  |  1 +
>  drivers/infiniband/hw/usnic/usnic_ib_verbs.c |  6 ++++++
>  drivers/infiniband/hw/usnic/usnic_ib_verbs.h |  2 ++
>  include/rdma/ib_verbs.h                      |  7 ++++++-
>  21 files changed, 104 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/d=
evice.c
> index 18c1ece..a9587c4 100644
> --- a/drivers/infiniband/core/device.c
> +++ b/drivers/infiniband/core/device.c
> @@ -76,6 +76,7 @@ static int ib_device_check_mandatory(struct ib_device *=
device)
>  	} mandatory_table[] =3D {
>  		IB_MANDATORY_FUNC(query_device),
>  		IB_MANDATORY_FUNC(query_port),
> +		IB_MANDATORY_FUNC(query_transport),
>  		IB_MANDATORY_FUNC(query_pkey),
>  		IB_MANDATORY_FUNC(query_gid),
>  		IB_MANDATORY_FUNC(alloc_pd),

I'm concerned about the performance implications of this.  The size of
this patchset already points out just how many places in the code we
have to check for various aspects of the device transport in order to do
the right thing.  Without going through the entire list to see how many
are on critical hot paths, I'm sure some of them are on at least
partially critical hot paths (like creation of new connections).  I
would prefer to see this change be implemented via a device attribute,
not a functional call query.  That adds a needless function call in
these paths.

> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/ve=
rbs.c
> index f93eb8d..83370de 100644
> --- a/drivers/infiniband/core/verbs.c
> +++ b/drivers/infiniband/core/verbs.c
> @@ -133,14 +133,16 @@ enum rdma_link_layer rdma_port_get_link_layer(struc=
t ib_device *device, u8 port_
>  	if (device->get_link_layer)
>  		return device->get_link_layer(device, port_num);
> =20
> -	switch (rdma_node_get_transport(device->node_type)) {
> +	switch (device->query_transport(device, port_num)) {
>  	case RDMA_TRANSPORT_IB:
> +	case RDMA_TRANSPORT_IBOE:
>  		return IB_LINK_LAYER_INFINIBAND;

If we are perserving ABI, then this looks wrong.  Currently, IBOE
returnsi transport IB and link layer Ethernet.  It should not return
link layer IB, it does not support IB link layer operations (such as MAD
access).

>  	case RDMA_TRANSPORT_IWARP:
>  	case RDMA_TRANSPORT_USNIC:
>  	case RDMA_TRANSPORT_USNIC_UDP:
>  		return IB_LINK_LAYER_ETHERNET;
>  	default:
> +		BUG();
>  		return IB_LINK_LAYER_UNSPECIFIED;
>  	}
>  }

[ snip ]

> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index 65994a1..d54f91e 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -75,10 +75,13 @@ enum rdma_node_type {
>  };
> =20
>  enum rdma_transport_type {
> +	/* legacy for users */
>  	RDMA_TRANSPORT_IB,
>  	RDMA_TRANSPORT_IWARP,
>  	RDMA_TRANSPORT_USNIC,
> -	RDMA_TRANSPORT_USNIC_UDP
> +	RDMA_TRANSPORT_USNIC_UDP,
> +	/* new transport */
> +	RDMA_TRANSPORT_IBOE,
>  };

I'm also concerned about this.  I would like to see this enum
essentially turned into a bitmap.  One that is constructed in such a way
that we can always get the specific test we need with only one compare
against the overall value.  In order to do so, we need to break it down
into the essential elements that are part of each of the transports.
So, for instance, we can define the two link layers we have so far, plus
reserve one for OPA which we know is coming:

RDMA_LINK_LAYER_IB       =3D 0x00000001,
RDMA_LINK_LAYER_ETH      =3D 0x00000002,
RDMA_LINK_LAYER_OPA      =3D 0x00000004,
RDMA_LINK_LAYER_MASK     =3D 0x0000000f,

We can then define the currently known high level transport types:

RDMA_TRANSPORT_IB        =3D 0x00000010,
RDMA_TRANSPORT_IWARP     =3D 0x00000020,
RDMA_TRANSPORT_USNIC     =3D 0x00000040,
RDMA_TRANSPORT_USNIC_UDP =3D 0x00000080,
RDMA_TRANSPORT_MASK      =3D 0x000000f0,

We could then define bits for the IB management types:

RDMA_MGMT_IB             =3D 0x00000100,
RDMA_MGMT_OPA            =3D 0x00000200,
RDMA_MGMT_MASK           =3D 0x00000f00,

Then we have space to define specific quirks:

RDMA_SEPARATE_READ_SGE   =3D 0x00001000,
RDMA_QUIRKS_MASK         =3D 0xfffff000

Once those are defined, a few definitions for device drivers to use when
they initialize a device to set the bitmap to the right values:

#define IS_IWARP (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_IWARP |
RDMA_SEPARATE_READ_SGE)
#define IS_IB (RDMA_LINK_LAYER_IB | RDMA_TRANSPORT_IB | RDMA_MGMT_IB)
#define IS_IBOE (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_IB)
#define IS_USNIC (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_USNIC)
#define IS_OPA (RDMA_LINK_LAYER_OPA | RDMA_TRANSPORT_IB | RDMA_MGMT_IB |
RDMA_MGMT_OPA)

Then you need to define the tests:

static inline bool
rdma_transport_is_iwarp(struct ib_device *dev, u8 port)
{
	return dev->port[port]->transport & RDMA_TRANSPORT_IWARP;
}

/* Note: this intentionally covers IB, IBOE, and OPA...use
   rdma_dev_is_ib if you want to only get physical IB devices */
static inline bool
rdma_transport_is_ib(struct ibdev *dev)
{
	return dev->port[port]->transport & RDMA_TRANSPORT_IB;
}

rdma_port_is_ib(struct ib_device *dev, u8 port)
{
	return dev->port[port]->transport & RDMA_LINK_LAYER_IB;
}

rdma_port_is_iboe(struct ib_device *dev, u8 port)
{
	return dev->port[port]->transport & IS_IBOE =3D=3D IS_IBOE;
}

rdma_port_is_usnic(struct ib_device *dev, u8 port)
{
	return dev->port[port]->transport & RDMA_TRANSPORT_USNIC;
}

rdma_port_is_opa(struct ib_device *dev, u8 port)
{
	return dev->port[port]->transport & RDMA_LINK_LAYER_OPA;
}

rdma_port_is_iwarp(struct ib_device *dev, u8 port)
{
	return rdma_transport_is_iwarp(dev, port);
}

rdma_port_ib_fabric_mgmt(struct ibdev *dev, u8 port)
{
	return dev->port[port]->transport & RDMA_MGMT_IB;
}

rdma_port_opa_mgmt(struct ibdev *dev, u8 port)
{
	return dev->port[port]->transport & RDMA_MGMT_OPA;
}

Other things can be changed too.  Like rdma_port_get_link_layer can
become this:

{
	return dev->transport & RDMA_LINK_LAYER_MASK;
}

=46rom patch 2/17:


> +static inline int rdma_ib_mgmt(struct ib_device *device, u8 port_num)
> +{
> +       enum rdma_transport_type tp =3D device->query_transport(device,
> port_num);
> +
> +       return (tp =3D=3D RDMA_TRANSPORT_IB || tp =3D=3D RDMA_TRANSPORT_I=
BOE);
> +}

This looks wrong.  IBOE doesn't have IB management.  At least it doesn't
have subnet management.

Actually, reading through the remainder of the patches, there is some
serious confusion taking place here.  In later patches, you use this as
a surrogate for cap_cm, which implies you are talking about connection
management.  This is very different than the rdma_dev_ib_mgmt() test
that I create above, which specifically refers to IB management tasks
unique to IB/OPA: MAD, SM, multicast.

The kernel connection management code is not really limited.  It
supports IB, IBOE, iWARP, and in the future it will support OPA.  There
are some places in the CM code were we test for just IB/IBOE currently,
but that's only because we split iWARP out higher up in the abstraction
hierarchy.  So, calling something rdma_ib_mgmt and meaning a rather
specialized tested in the CM is probably misleading.

To straighten all this out, lets break management out into the two
distinct types:

rdma_port_ib_fabric_mgmt() <- fabric specific management tasks: MAD, SM,
multicast.  The proper test for this with my bitmap above is a simple
transport & RDMA_MGMT_IB test.  If will be true for IB and OPA fabrics.

rdma_port_conn_mgmt() <- connection management, which we currently
support everything except USNIC (correct Sean?), so a test would be
something like !(transport & RDMA_TRANSPORT_USNIC).  This is then split
out into two subgroups, IB style and iWARP stype connection management
(aka, rdma_port_iw_conn_mgmt() and rdma_port_ib_conn_mgmt()).  In my
above bitmap, since I didn't give IBOE its own transport type, these
subgroups still boil down to the simple tests transport & iWARP and
transport & IB like they do today.

=46rom patch 3/17:


> +/**
> + * cap_ib_mad - Check if the port of device has the capability
> Infiniband
> + * Management Datagrams.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device don't support Infiniband
> + * Management Datagrams.
> + */
> +static inline int cap_ib_mad(struct ib_device *device, u8 port_num)
> +{
> +       return rdma_ib_mgmt(device, port_num);
> +}
> +

Why add cap_ib_mad?  It's nothing more than rdma_port_ib_fabric_mgmt
with a new name.  Just use rdma_port_ib_fabric_mgmt() everywhere you
have cap_ib_mad.

=46rom patch 4/17:


> +/**
> + * cap_ib_smi - Check if the port of device has the capability
> Infiniband
> + * Subnet Management Interface.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device don't support Infiniband
> + * Subnet Management Interface.
> + */
> +static inline int cap_ib_smi(struct ib_device *device, u8 port_num)
> +{
> +       return rdma_transport_ib(device, port_num);
> +}
> +

Same as the previous patch.  This is needless indirection.  Just use
rdma_port_ib_fabric_mgmt directly.

Patch 5/17:

Again, just use rdma_port_ib_conn_mgmt() directly.

Patch 6/17:

Again, just use rdma_port_ib_fabric_mgmt() directly.

Patch 7/17:

Again, just use rdma_port_ib_fabric_mgmt() directly.  It's perfectly
applicable to the IB mcast registration requirements.

Patch 8/17:

Here we can create a new test if we are using the bitmap I created
above:

rdma_port_ipoib(struct ib_device *dev, u8 port)
{
	return !(dev->port[port]->transport & RDMA_LINK_LAYER_ETH);
}

This is presuming that OPA will need ipoib devices.  This will cause all
non-Ethernet link layer devices to return true, and right now, that is
all IB and all OPA devices.

Patch 9/17:

Most of the other comments on this patch stand as they are.  I would add
the test:

rdma_port_separate_read_sge(dev, port)
{
	return dev->port[port]->transport & RDMA_SEPERATE_READ_SGE;
}

and add the helper function:

rdma_port_get_read_sge(dev, port)
{
	if (rdma_transport_is_iwarp)
		return 1;
	return dev->port[port]->max_sge;
}

Then, as Jason points out, if at some point in the future the kernel is
modified to support devices with assymetrical read/write SGE sizes, this
function can be modified to support those devices.

Patch 10/17:

As Sean pointed out, force_grh should be rdma_dev_is_iboe().  The cm
handles iw devices, but you notice all of the functions you modify here
start with ib_.  The iwarp connections are funneled through iw_ specific
function variants, and so even though the cm handles iwarp, ib, and roce
devices, you never see anything other than ib/iboe (and opa in the
future) get to the ib_ variants of the functions.  So, they wrote the
original tests as tests against the link layer being ethernet and used
that to differentiate between ib and iboe devices.  It works, but can
confuse people.  So, everyplace that has !rdma_transport_ib should
really be rdma_dev_is_iboe instead.  If we ever merge the iw_ and ib_
functions in the future, having this right will help avoid problems.

Patch 11/17:

I wouldn't reform the link_layer_show except to make it compile with the
new defines I used above. =20

Patch 12/17:

Go ahead and add a helper to check all ports on a dev, just make it
rdma_hca_ib_conn_mgmt() and have it loop through
rdma_port_ib_conn_mgmt() return codes.

Patch 13/17:

This patch is largely unneeded if we reworked the bitmap like I have
above.  A lot of the changes you made to switch from case statements to
multiple if statements can go back to being case statements because in
the bitmap IB and IBOE are still both transport IB, so you just do the
case on the transport bits and not on the link layer bits.

Patch 14/17:

Seems ok.

Patch 15/17:

If you implement the bitmap like I list above, then this code will need
fixed up to use the bitmap.  Otherwise it looks OK.

Patch 16/17:

OK.

Patch 17/17:

I would drop this patch.  In the future, the mlx5 driver will support
both Ethernet and IB like mlx4 does, and we would just need to pull this
code back to core instead of only in mlx4.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-bu8jIKuK2uA3rB8lqRbS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVJXOaAAoJELgmozMOVy/d3DMQAKRfIzOYpUaOXGGoeUdL6m8K
zTG1NB1XeQfGNCGP2Nc9UZPgt7+O7Tfv4zeH96qciq0obXeJitFR963sWJbR9lHh
kLb+fqoNGTwh0BZMbUMbu7r683btxwYBZmlCCVtD8/zqLX0zKf7y3fkBE43nOEmV
aCgb4ZODaazJhMVMnmZqIc0zH9My4yYb6tN34D2kGeNlJqX3r8lIwEjl2ZnMseuq
OJqLbtLNwARrqOB5iVd03rqPsWI492YHolFjPMu63zCQ565SqqM1mC3ZWcDqEBmG
sLYnjEvnXAldgidnIwogaWHfABE0Fz4pa3Mt70lEc8beoNWI7M5me9tb5eG2zhOC
MgoQjwlLuzefOjd/qZE6ngGnpjh6haGBEiQF3/R65cMbe4k2X6ljjVM+h7It6SPM
ObK6LGS16Nl5MEde7YvpxVQJI4bDhquJbAvh9Z4hsZC6BudYx4mpzOQmak759pN5
XIqc5Hv+kLsDL/9n1udbAWMSUHdukfbpCiZBZ4rMKcRO57Ut1A7dJPcwu1gygTJg
J4l8R2ssGHuXynPD8fXBXE6aa/SFAmA+NSUmWMspG/ITKK12ep/VrEUjhlrVj74Y
03VGN037D6FMeFM2JQ96wOgKmnHekuEYTfNdhrpTyh7R739JEHhX1xhwRCl6fuxH
pJ7QNQjftkEYqPrvJjwf
=yYCq
-----END PGP SIGNATURE-----

--=-bu8jIKuK2uA3rB8lqRbS--

