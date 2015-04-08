Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33218 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507AbbDHUK1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 16:10:27 -0400
Date: Wed, 8 Apr 2015 14:10:15 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Message-ID: <20150408201015.GB28666@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428517786.2980.180.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2015 at 02:29:46PM -0400, Doug Ledford wrote:

> To straighten all this out, lets break management out into the two
> distinct types:
> 
> rdma_port_ib_fabric_mgmt() <- fabric specific management tasks: MAD, SM,
> multicast.  The proper test for this with my bitmap above is a simple
> transport & RDMA_MGMT_IB test.  If will be true for IB and OPA fabrics.

> rdma_port_conn_mgmt() <- connection management, which we currently
> support everything except USNIC (correct Sean?), so a test would be
> something like !(transport & RDMA_TRANSPORT_USNIC).  This is then split
> out into two subgroups, IB style and iWARP stype connection management
> (aka, rdma_port_iw_conn_mgmt() and rdma_port_ib_conn_mgmt()).  In my
> above bitmap, since I didn't give IBOE its own transport type, these
> subgroups still boil down to the simple tests transport & iWARP and
> transport & IB like they do today.

There is a lot more variation here than just these two tests, and those
two tests won't scale to include OPA.

        IB ROCEE OPA
SMI     Y  N     Y    (though the OPA smi looked a bit different)
IB SMP  Y  N     N
OPA SMP N  N     Y
GMP     Y  Y     Y
SA      Y  N     Y
PM      Y  Y     Y    (? guessing for OPA)
CM      Y  Y     Y
GMP needs GRH N Y N

It may be unrealistic, but I was hoping we could largely scrub the
opaque 'is spec iWARP, is spec ROCEE' kinds of tests because they
don't tell anyone what it is the code cares about.

Maybe what is needed is a more precise language for the functions:

> > + * cap_ib_mad - Check if the port of device has the capability
> > Infiniband
> > + * Management Datagrams.

As used this seems to mean:

True if the port can do IB/OPA SMP, or GMP management packets on QP0 or
QP1. (Y Y Y) ie: Do we need the MAD layer at all.

ib_smi seems to be true if QP0 is supported  (Y N Y)

Maybe the above set would make a lot more sense as:
  cap_ib_qp0
  cap_ib_qp1
  cap_opa_qp0

ib_cm seems to mean that the CM protocol from the IBA is used on the
port (Y Y Y)

ib_sa means the IBA SA protocol is supported (Y Y Y)

ib_mcast true if the IBA SA protocol is used for multicast GIDs (Y N
Y)

ipoib means the port supports the ipoib protocol (Y N ?)

This seem reasonable and understandable, even if they are currently a
bit duplicating.

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

Hum, that is nice, but it doesn't quite fit with how the ULP needs to
work. The max limit when creating a WR is the value passed into the
qp_cap, not the device maximum limit.

To do this properly we need to extend the qp_cap, and that is just too
big a change. A one bit iWarp quirk is OK for now.

> As Sean pointed out, force_grh should be rdma_dev_is_iboe().  The cm

I actually really prefer cap_mandatory_grh - that is what is going on
here. ie based on that name (as a reviewer) I'd expect to see the mad
layer check that the mandatory GRH is always present, or blow up.

Some of the other checks in this file revolve around pkey, I'm not
sure what rocee does there? cap_pkey_supported ?

Jason
