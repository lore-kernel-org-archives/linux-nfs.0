Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12945 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615AbbDJHsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 03:48:18 -0400
Date: Fri, 10 Apr 2015 03:48:06 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Doug Ledford <dledford@redhat.com>
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
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport() for each HW
Message-ID: <20150410074805.GA11855@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428517786.2980.180.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
> > index 18c1ece..a9587c4 100644
> > --- a/drivers/infiniband/core/device.c
> > +++ b/drivers/infiniband/core/device.c
> > @@ -76,6 +76,7 @@ static int ib_device_check_mandatory(struct ib_device *device)
> >  	} mandatory_table[] = {
> >  		IB_MANDATORY_FUNC(query_device),
> >  		IB_MANDATORY_FUNC(query_port),
> > +		IB_MANDATORY_FUNC(query_transport),
> >  		IB_MANDATORY_FUNC(query_pkey),
> >  		IB_MANDATORY_FUNC(query_gid),
> >  		IB_MANDATORY_FUNC(alloc_pd),
> 
> I'm concerned about the performance implications of this.  The size of
> this patchset already points out just how many places in the code we
> have to check for various aspects of the device transport in order to do
> the right thing.  Without going through the entire list to see how many
> are on critical hot paths, I'm sure some of them are on at least
> partially critical hot paths (like creation of new connections).  I
> would prefer to see this change be implemented via a device attribute,
> not a functional call query.  That adds a needless function call in
> these paths.

I like the idea of a query_transport but at the same time would like to see the
use of "transport" reduced.  A reduction in the use of this call could
eliminate most performance concerns.

So can we keep this abstraction if at the end of the series we limit its use?

> 
> > diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
> > index f93eb8d..83370de 100644
> > --- a/drivers/infiniband/core/verbs.c
> > +++ b/drivers/infiniband/core/verbs.c
> > @@ -133,14 +133,16 @@ enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device, u8 port_
> >  	if (device->get_link_layer)
> >  		return device->get_link_layer(device, port_num);
> >  
> > -	switch (rdma_node_get_transport(device->node_type)) {
> > +	switch (device->query_transport(device, port_num)) {
> >  	case RDMA_TRANSPORT_IB:
> > +	case RDMA_TRANSPORT_IBOE:
> >  		return IB_LINK_LAYER_INFINIBAND;
> 
> If we are perserving ABI, then this looks wrong.  Currently, IBOE
> returnsi transport IB and link layer Ethernet.  It should not return
> link layer IB, it does not support IB link layer operations (such as MAD
> access).

I think the original code has the bug.

IBoE devices currently return a transport of IB but they probably never get
here because they support the get_link_layer callback used a few lines above.
So this "bug" was probably never hit.

> 
> >  	case RDMA_TRANSPORT_IWARP:
> >  	case RDMA_TRANSPORT_USNIC:
> >  	case RDMA_TRANSPORT_USNIC_UDP:
> >  		return IB_LINK_LAYER_ETHERNET;
> >  	default:
> > +		BUG();
> >  		return IB_LINK_LAYER_UNSPECIFIED;
> >  	}
> >  }
> 
> [ snip ]
> 
> > diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> > index 65994a1..d54f91e 100644
> > --- a/include/rdma/ib_verbs.h
> > +++ b/include/rdma/ib_verbs.h
> > @@ -75,10 +75,13 @@ enum rdma_node_type {
> >  };
> >  
> >  enum rdma_transport_type {
> > +	/* legacy for users */
> >  	RDMA_TRANSPORT_IB,
> >  	RDMA_TRANSPORT_IWARP,
> >  	RDMA_TRANSPORT_USNIC,
> > -	RDMA_TRANSPORT_USNIC_UDP
> > +	RDMA_TRANSPORT_USNIC_UDP,
> > +	/* new transport */
> > +	RDMA_TRANSPORT_IBOE,
> >  };
> 
> I'm also concerned about this.  I would like to see this enum
> essentially turned into a bitmap.  One that is constructed in such a way
> that we can always get the specific test we need with only one compare
> against the overall value.  In order to do so, we need to break it down
> into the essential elements that are part of each of the transports.
> So, for instance, we can define the two link layers we have so far, plus
> reserve one for OPA which we know is coming:
> 
> RDMA_LINK_LAYER_IB       = 0x00000001,
> RDMA_LINK_LAYER_ETH      = 0x00000002,
> RDMA_LINK_LAYER_OPA      = 0x00000004,
> RDMA_LINK_LAYER_MASK     = 0x0000000f,

I would reserve more bits here.

> 
> We can then define the currently known high level transport types:
> 
> RDMA_TRANSPORT_IB        = 0x00000010,
> RDMA_TRANSPORT_IWARP     = 0x00000020,
> RDMA_TRANSPORT_USNIC     = 0x00000040,
> RDMA_TRANSPORT_USNIC_UDP = 0x00000080,
> RDMA_TRANSPORT_MASK      = 0x000000f0,

I would reserve more bits here.

> 
> We could then define bits for the IB management types:
> 
> RDMA_MGMT_IB             = 0x00000100,
> RDMA_MGMT_OPA            = 0x00000200,
> RDMA_MGMT_MASK           = 0x00000f00,

We at least need bits for SA / CM support.

I said previously all device types support QP1  I was wrong...  I forgot about
USNIC devices.  So the full management bit mask is.


RDMA_MGMT_IB_MAD         = 0x00000100,
RDMA_MGMT_QP0            = 0x00000200,
RDMA_MGMT_SA             = 0x00000400,
RDMA_MGMT_CM             = 0x00000800,
RDMA_MGMT_OPA_MAD        = 0x00001000,
RDMA_MGMT_MASK           = 0x000fff00,

With a couple of spares.

The MAD stack is pretty agnostic to the types of MADs passing through it so we
don't really need PM flags etc.

> 
> Then we have space to define specific quirks:
> 
> RDMA_SEPARATE_READ_SGE   = 0x00001000,
> RDMA_QUIRKS_MASK         = 0xfffff000

shift for spares...

RDMA_SEPARATE_READ_SGE   = 0x00100000,
RDMA_QUIRKS_MASK         = 0xfff00000

> 
> Once those are defined, a few definitions for device drivers to use when
> they initialize a device to set the bitmap to the right values:
> 
> #define IS_IWARP (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_IWARP |
> RDMA_SEPARATE_READ_SGE)
> #define IS_IB (RDMA_LINK_LAYER_IB | RDMA_TRANSPORT_IB | RDMA_MGMT_IB)
> #define IS_IBOE (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_IB)
> #define IS_USNIC (RDMA_LINK_LAYER_ETH | RDMA_TRANSPORT_USNIC)
> #define IS_OPA (RDMA_LINK_LAYER_OPA | RDMA_TRANSPORT_IB | RDMA_MGMT_IB |
> RDMA_MGMT_OPA)
> 
> Then you need to define the tests:
> 
> static inline bool
> rdma_transport_is_iwarp(struct ib_device *dev, u8 port)
> {
> 	return dev->port[port]->transport & RDMA_TRANSPORT_IWARP;
> }
> 
> /* Note: this intentionally covers IB, IBOE, and OPA...use
>    rdma_dev_is_ib if you want to only get physical IB devices */
> static inline bool
> rdma_transport_is_ib(struct ibdev *dev)
> {
> 	return dev->port[port]->transport & RDMA_TRANSPORT_IB;
> }
> 
> rdma_port_is_ib(struct ib_device *dev, u8 port)

I prefer

rdma_port_link_layer_is_ib
rdma_port_link_layer_is_eth


> {
> 	return dev->port[port]->transport & RDMA_LINK_LAYER_IB;
> }
> 
> rdma_port_is_iboe(struct ib_device *dev, u8 port)

I'm not sure what this means.

rdma_port_req_iboe_addr seems more appropriate because what we really need to
know is that this device requires an IBoE address format.  (PKey is "fake",
PathRecord is fabricated rather than queried, GRH is required in the AH
conversion.)

> {
> 	return dev->port[port]->transport & IS_IBOE == IS_IBOE;
> }
> 
> rdma_port_is_usnic(struct ib_device *dev, u8 port)

rdma_transport_is_usnic

> {
> 	return dev->port[port]->transport & RDMA_TRANSPORT_USNIC;
> }
> 
> rdma_port_is_opa(struct ib_device *dev, u8 port)

rdma_port_link_layer_is_opa

> {
> 	return dev->port[port]->transport & RDMA_LINK_LAYER_OPA;
> }
> 
> rdma_port_is_iwarp(struct ib_device *dev, u8 port)
> {
> 	return rdma_transport_is_iwarp(dev, port);

Why not call rdma_transport_is_iwarp?

> }
> 
> rdma_port_ib_fabric_mgmt(struct ibdev *dev, u8 port)
> {
> 	return dev->port[port]->transport & RDMA_MGMT_IB;

I agree with Jason that this does not adequately describe the functionality we
are looking for.

> }
> 
> rdma_port_opa_mgmt(struct ibdev *dev, u8 port)

Agree.

> {
> 	return dev->port[port]->transport & RDMA_MGMT_OPA;
> }
> 
> Other things can be changed too.  Like rdma_port_get_link_layer can
> become this:
> 
> {
> 	return dev->transport & RDMA_LINK_LAYER_MASK;
> }
> 
> From patch 2/17:
> 
> 
> > +static inline int rdma_ib_mgmt(struct ib_device *device, u8 port_num)
> > +{
> > +       enum rdma_transport_type tp = device->query_transport(device,
> > port_num);
> > +
> > +       return (tp == RDMA_TRANSPORT_IB || tp == RDMA_TRANSPORT_IBOE);
> > +}
> 
> This looks wrong.  IBOE doesn't have IB management.  At least it doesn't
> have subnet management.

Right that is why we need a bit for CM vs SA capability.

> 
> Actually, reading through the remainder of the patches, there is some
> serious confusion taking place here.  In later patches, you use this as
> a surrogate for cap_cm, which implies you are talking about connection
> management.  This is very different than the rdma_dev_ib_mgmt() test
> that I create above, which specifically refers to IB management tasks
> unique to IB/OPA: MAD, SM, multicast.

multicast is part of SA so should be covered by the SA capability.

> 
> The kernel connection management code is not really limited.  It
> supports IB, IBOE, iWARP, and in the future it will support OPA.  There
> are some places in the CM code were we test for just IB/IBOE currently,
> but that's only because we split iWARP out higher up in the abstraction
> hierarchy.  So, calling something rdma_ib_mgmt and meaning a rather
> specialized tested in the CM is probably misleading.

Right!  So we should have a CM capability.

> 
> To straighten all this out, lets break management out into the two
> distinct types:
> 
> rdma_port_ib_fabric_mgmt() <- fabric specific management tasks: MAD, SM,
> multicast.  The proper test for this with my bitmap above is a simple
> transport & RDMA_MGMT_IB test.  If will be true for IB and OPA fabrics.

General management is covered by

RDMA_MGMT_IB_MAD         = 0x00000100,
RDMA_MGMT_QP0            = 0x00000200,
...
RDMA_MGMT_OPA_MAD        = 0x00001000,


> 
> rdma_port_conn_mgmt() <- connection management, which we currently
> support everything except USNIC (correct Sean?), so a test would be
> something like !(transport & RDMA_TRANSPORT_USNIC).  This is then split
> out into two subgroups, IB style and iWARP stype connection management
> (aka, rdma_port_iw_conn_mgmt() and rdma_port_ib_conn_mgmt()).  In my
> above bitmap, since I didn't give IBOE its own transport type, these
> subgroups still boil down to the simple tests transport & iWARP and
> transport & IB like they do today.

Specific management features CM, route resolution (SA), and special Multicast
management requirements (SA) are covered by:

RDMA_MGMT_SA             = 0x00000400,
RDMA_MGMT_CM             = 0x00000800,


> 
> From patch 3/17:
> 
> 
> > +/**
> > + * cap_ib_mad - Check if the port of device has the capability
> > Infiniband
> > + * Management Datagrams.
> > + *
> > + * @device: Device to be checked
> > + * @port_num: Port number of the device
> > + *
> > + * Return 0 when port of the device don't support Infiniband
> > + * Management Datagrams.
> > + */
> > +static inline int cap_ib_mad(struct ib_device *device, u8 port_num)
> > +{
> > +       return rdma_ib_mgmt(device, port_num);
> > +}
> > +
> 
> Why add cap_ib_mad?  It's nothing more than rdma_port_ib_fabric_mgmt
> with a new name.  Just use rdma_port_ib_fabric_mgmt() everywhere you
> have cap_ib_mad.

Because USNIC apparently does not support MADs at all.  So we end up needing a
"big flag" to turn on/off ib_mad.

RDMA_MGMT_IB_MAD         = 0x00000100,

> 
> From patch 4/17:
> 
> 
> > +/**
> > + * cap_ib_smi - Check if the port of device has the capability
> > Infiniband
> > + * Subnet Management Interface.
> > + *
> > + * @device: Device to be checked
> > + * @port_num: Port number of the device
> > + *
> > + * Return 0 when port of the device don't support Infiniband
> > + * Subnet Management Interface.
> > + */
> > +static inline int cap_ib_smi(struct ib_device *device, u8 port_num)
> > +{
> > +       return rdma_transport_ib(device, port_num);
> > +}
> > +
> 
> Same as the previous patch.  This is needless indirection.  Just use
> rdma_port_ib_fabric_mgmt directly.

No this is not the same...  You said:

<quote>
   rdma_port_ib_fabric_mgmt() <- fabric specific management tasks: MAD, SM,
   multicast.  The proper test for this with my bitmap above is a simple
   transport & RDMA_MGMT_IB test.  If will be true for IB and OPA fabrics.
</quote>

But what we are looking for here is "does the port support QP0"  Previously
flagged as "smi".  Cover this with this flag.

RDMA_MGMT_QP0            = 0x00000200,

So the optimized version of the above is:

static inline int cap_ib_smi(struct ib_device *device, u8 port_num)
{
       return [<device> <port>]->flags & RDMA_MGMT_QP0;
}


> 
> Patch 5/17:
> 
> Again, just use rdma_port_ib_conn_mgmt() directly.

Agreed.

> 
> Patch 6/17:
> 
> Again, just use rdma_port_ib_fabric_mgmt() directly.

No this needs to be

rdma_port_requires_sa()

or something...

> 
> Patch 7/17:
> 
> Again, just use rdma_port_ib_fabric_mgmt() directly.  It's perfectly
> applicable to the IB mcast registration requirements.

No this needs to be

rdma_port_requires_sa()

or something...

> 
> Patch 8/17:
> 
> Here we can create a new test if we are using the bitmap I created
> above:
> 
> rdma_port_ipoib(struct ib_device *dev, u8 port)
> {
> 	return !(dev->port[port]->transport & RDMA_LINK_LAYER_ETH);

I would prefer a link layer (or generic) bit mask rather than '&' of
"transport" and "link layer".  That just seems wrong.

> }
> 
> This is presuming that OPA will need ipoib devices.  This will cause all
> non-Ethernet link layer devices to return true, and right now, that is
> all IB and all OPA devices.

Agreed.

> 
> Patch 9/17:
> 
> Most of the other comments on this patch stand as they are.  I would add
> the test:
> 
> rdma_port_separate_read_sge(dev, port)
> {
> 	return dev->port[port]->transport & RDMA_SEPERATE_READ_SGE;
> }
> 
> and add the helper function:
> 
> rdma_port_get_read_sge(dev, port)
> {
> 	if (rdma_transport_is_iwarp)
> 		return 1;
> 	return dev->port[port]->max_sge;
> }
> 
> Then, as Jason points out, if at some point in the future the kernel is
> modified to support devices with assymetrical read/write SGE sizes, this
> function can be modified to support those devices.
> 
> Patch 10/17:
> 
> As Sean pointed out, force_grh should be rdma_dev_is_iboe().  The cm
> handles iw devices, but you notice all of the functions you modify here
> start with ib_.  The iwarp connections are funneled through iw_ specific
> function variants, and so even though the cm handles iwarp, ib, and roce
> devices, you never see anything other than ib/iboe (and opa in the
> future) get to the ib_ variants of the functions.  So, they wrote the
> original tests as tests against the link layer being ethernet and used
> that to differentiate between ib and iboe devices.  It works, but can
> confuse people.  So, everyplace that has !rdma_transport_ib should
> really be rdma_dev_is_iboe instead.  If we ever merge the iw_ and ib_
> functions in the future, having this right will help avoid problems.

I guess rdma_dev_is_iboe is ok.  But it seems like we are keying off the
addresses not necessarily the devices.

> 
> Patch 11/17:
> 
> I wouldn't reform the link_layer_show except to make it compile with the
> new defines I used above.  
> 
> Patch 12/17:
> 
> Go ahead and add a helper to check all ports on a dev, just make it
> rdma_hca_ib_conn_mgmt() and have it loop through
> rdma_port_ib_conn_mgmt() return codes.
> 
> Patch 13/17:
> 
> This patch is largely unneeded if we reworked the bitmap like I have
> above.  A lot of the changes you made to switch from case statements to
> multiple if statements can go back to being case statements because in
> the bitmap IB and IBOE are still both transport IB, so you just do the
> case on the transport bits and not on the link layer bits.
> 
> Patch 14/17:
> 
> Seems ok.
> 
> Patch 15/17:
> 
> If you implement the bitmap like I list above, then this code will need
> fixed up to use the bitmap.  Otherwise it looks OK.
> 
> Patch 16/17:
> 
> OK.
> 
> Patch 17/17:
> 
> I would drop this patch.  In the future, the mlx5 driver will support
> both Ethernet and IB like mlx4 does, and we would just need to pull this
> code back to core instead of only in mlx4.

Agreed.

Ira

