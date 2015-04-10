Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14962 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047AbbDJGQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 02:16:30 -0400
Date: Fri, 10 Apr 2015 02:16:11 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>,
        Michael Wang <yun.wang@profitbricks.com>,
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
Message-ID: <20150410061610.GA26288@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150408201015.GB28666@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First off there are 2 separate issues here:

1) We need to communicate if a port supports or requires various management
   support from the ib_mad, ib_cm, and/or ib_sa modules.

2) We need to communicate how a addresses are formated and resolved for a
   particular port


In general I don't think we need to remove all uses of the Transport
or Link Layer.

Although we may be able to remove most of the transport uses.

On Wed, Apr 08, 2015 at 02:10:15PM -0600, Jason Gunthorpe wrote:
> On Wed, Apr 08, 2015 at 02:29:46PM -0400, Doug Ledford wrote:
> 
> > To straighten all this out, lets break management out into the two
> > distinct types:
> > 
> > rdma_port_ib_fabric_mgmt() <- fabric specific management tasks: MAD, SM,
> > multicast.  The proper test for this with my bitmap above is a simple
> > transport & RDMA_MGMT_IB test.  If will be true for IB and OPA fabrics.
> 
> > rdma_port_conn_mgmt() <- connection management, which we currently
> > support everything except USNIC (correct Sean?), so a test would be
> > something like !(transport & RDMA_TRANSPORT_USNIC).  This is then split
> > out into two subgroups, IB style and iWARP stype connection management
> > (aka, rdma_port_iw_conn_mgmt() and rdma_port_ib_conn_mgmt()).  In my
> > above bitmap, since I didn't give IBOE its own transport type, these
> > subgroups still boil down to the simple tests transport & iWARP and
> > transport & IB like they do today.
> 
> There is a lot more variation here than just these two tests, and those
> two tests won't scale to include OPA.
> 
>         IB ROCEE OPA
> SMI     Y  N     Y    (though the OPA smi looked a bit different)

Yes OPA is different but it is based on the class version of the individual
MADs not any particular device/port support.

> IB SMP  Y  N     N

Correction:

  IB SMP  Y  N     Y    (OPA supports the IB NodeInfo query)

> OPA SMP N  N     Y

How is this different from the SMI?

> GMP     Y  Y     Y
> SA      Y  N     Y
> PM      Y  Y     Y    (? guessing for OPA)
                        ^^^
			Yes

> CM      Y  Y     Y
> GMP needs GRH N Y N
> 
> It may be unrealistic, but I was hoping we could largely scrub the
> opaque 'is spec iWARP, is spec ROCEE' kinds of tests because they
> don't tell anyone what it is the code cares about.

I somewhat agree except for things like addressing.  In the area of addressing
I think we are likely to need to define something like "cap_addr_ib",
"cap_addr_iboe", "cap_addr_iwarp".  See below for more details.

> 
> Maybe what is needed is a more precise language for the functions:
> 
> > > + * cap_ib_mad - Check if the port of device has the capability
> > > Infiniband
> > > + * Management Datagrams.
> 
> As used this seems to mean:
> 
> True if the port can do IB/OPA SMP, or GMP management packets on QP0 or
> QP1. (Y Y Y) ie: Do we need the MAD layer at all.
> 
> ib_smi seems to be true if QP0 is supported  (Y N Y)
> 
> Maybe the above set would make a lot more sense as:
>   cap_ib_qp0
>   cap_ib_qp1
>   cap_opa_qp0

I disagree.

All we need right now is is cap_qp0.  All devices currently support QP1.

Then after all this is settled I can add:

               IB ROCEE OPA
OPA MAD Space   N  N    Y    Port is OPA MAD space.

> 
> ib_cm seems to mean that the CM protocol from the IBA is used on the
> port (Y Y Y)

Agree.

> 
> ib_sa means the IBA SA protocol is supported (Y Y Y)

I think this should be (Y N Y)

IBoE has no SA.  The IBoE code "fabricates" a Path Record it does not need to
interact with the SA.

> 
> ib_mcast true if the IBA SA protocol is used for multicast GIDs (Y N
> Y)

Given the above why can't we just have the "ib_sa" flag?

> 
> ipoib means the port supports the ipoib protocol (Y N ?)


OPA does IPoIB so...   (Y N Y)


However, I think checking the link layer is more appropriate here.  It does not
make sense to do IP over IB over Eth.  Even though the IBoE can do the "IB"
protocol.


Making flags in the driver to indicate which ULPs they support is a _bad_
_idea_.

FWIW: I don't consider the MAD and SA (multicast) modules ULPs.   Rather they
are helper modules which are built to share code amongst the drivers to process
things on behalf of the drivers themselves.  As such advertising a need for or
particular support within those modules make sense.

So although strictly speaking we could do IPoIBoEth, I think having IPoIB check
the LL and limiting itself to ports which are IB LL is appropriate.

> 
> This seem reasonable and understandable, even if they are currently a
> bit duplicating.
> 
> > Patch 9/17:
> > 
> > Most of the other comments on this patch stand as they are.  I would add
> > the test:
> > 
> > rdma_port_separate_read_sge(dev, port)
> > {
> > 	return dev->port[port]->transport & RDMA_SEPERATE_READ_SGE;
> > }
> > 
> > and add the helper function:
> > 
> > rdma_port_get_read_sge(dev, port)
> > {
> > 	if (rdma_transport_is_iwarp)
> > 		return 1;
> > 	return dev->port[port]->max_sge;
> > }
> 
> Hum, that is nice, but it doesn't quite fit with how the ULP needs to
> work. The max limit when creating a WR is the value passed into the
> qp_cap, not the device maximum limit.
> 
> To do this properly we need to extend the qp_cap, and that is just too
> big a change. A one bit iWarp quirk is OK for now.

I agree.  This is the one place we probably want to just keep the "Transport"
check.

> 
> > As Sean pointed out, force_grh should be rdma_dev_is_iboe().  The cm
> 
> I actually really prefer cap_mandatory_grh - that is what is going on
> here. ie based on that name (as a reviewer) I'd expect to see the mad
> layer check that the mandatory GRH is always present, or blow up.

While GRH mandatory (for the GMP) is what this is.  The function
ib_init_ah_from_path generically is really handling an "IBoE address" to send
to and therefore we need to force the GRH in the AH.

There is a whole slew of LL and Transport checks which are used to
format/resolve addresses.

Functions which need to know that the address format is "IBoE"

	-- cma.c: cma_acquire_dev
	-- cma.c: cma_modify_qp_rtr
	-- sa_query.c: ib_init_ah_from_path
	-- verbs.c: ib_resolve_eth_l2_attrs

What about a check rdma_port_req_iboe_addr()?

Functions where AF_IB is checked against LL because it does not make sense to
use AF_IB on anything but an IB LL

	-- cma.c: cma_listen_on_dev
	-- cma.c: cma_bind_loopback

These checks should be directly against the LL

Functions where the ARP type is checked against the link layer.

	-- cma.c: cma_acquire_dev
	-- cma.c: cma_bind_loopback

These checks should be directly against the LL

> 
> Some of the other checks in this file revolve around pkey, I'm not
> sure what rocee does there? cap_pkey_supported ?

It seems IBoE just hardcodes the pkey to 0xffff.  I don't see it used anywhere.

Function where port requires "real" PKey

	-- cma.c: cma_ib_init_qp_attr

Check rdma_port_req_pkey()?


Over all for the addressing choices:

The "Transport" (or protocol, or whatever) is Verbs.  The Layer below Verbs
(OPA/IB/Eth/TCP) defines how addressing, route, and connection information is
generated, communicated, and used.

As Jason and Doug have been saying sometimes we want to know when that requires
SA interaction or the use of the CM protocol (or neither).  Other times we just
need to know what the Address format or Link Layer is.


Ira

