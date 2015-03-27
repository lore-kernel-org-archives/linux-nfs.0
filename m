Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5481 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754741AbbC0RFS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 13:05:18 -0400
Date: Fri, 27 Mar 2015 13:05:08 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast() and, cap_mcast() for mcast-check
Message-ID: <20150327170508.GB27862@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com> <55157B71.6040505@profitbricks.com> <20150327162820.GC28412@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150327162820.GC28412@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:28:20AM -0600, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 04:46:57PM +0100, Michael Wang wrote:
> > 
> > Introduce helper has_mcast() and cap_mcast() to help us check if an
> > IB device or it's port support Multicast.
> > 
> > Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> > Cc: Doug Ledford <dledford@redhat.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Sean Hefty <sean.hefty@intel.com>
> > Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> >  drivers/infiniband/core/cma.c       |  2 +-
> >  drivers/infiniband/core/multicast.c |  8 ++++----
> >  include/rdma/ib_verbs.h             | 28 ++++++++++++++++++++++++++++
> >  3 files changed, 33 insertions(+), 5 deletions(-)
> > 
> > diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
> > index 276fb76..cbbc85b 100644
> > +++ b/drivers/infiniband/core/cma.c
> > @@ -3398,7 +3398,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
> >                  ib_detach_mcast(id->qp,
> >                          &mc->multicast.ib->rec.mgid,
> >                          be16_to_cpu(mc->multicast.ib->rec.mlid));
> > -            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
> > +            if (has_mcast(id_priv->cma_dev->device)) {
> 
> This might make more sense as cap_ib_multicast / cap_ip_multicast

Agreed.

> 
> >                  switch (rdma_port_get_link_layer(id->device, id->port_num)) {
> >                  case IB_LINK_LAYER_INFINIBAND:
> >                      ib_sa_free_multicast(mc->multicast.ib);
> 
> > diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
> > index 17573ff..ffeaf27 100644
> > +++ b/drivers/infiniband/core/multicast.c
> > @@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
> >      int index;
> >  
> >      dev = container_of(handler, struct mcast_device, event_handler);
> > -    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
> > +    if (!cap_mcast(dev->device, event->element.port_num))
> >          return;
> 
> These should probably be cap_ib_sa - that is what they are guarding
> against.
> 
> But it seems redudent, since mcast_add_one will already not add a port that is
> not IB, so mcast_event_handler is not callable. Something to do with
> rocee/ib switching?

I'm not sure about this either.  This check seems to be necessary only on a
per-port level.  It does seem apparent that one can't go from Eth to IB.  What
happens if you go from IB to Eth on the port?

> 
> >      index = event->element.port_num - dev->start_port;
> > @@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
> >      int i;
> >      int count = 0;
> >  
> > -    if (!rdma_transport_is_ib(device))
> > +    if (!has_mcast(device))
> >          return;
> 
> Again, this seems redundant, every port is tested directly below, why
> is this check needed?

Agreed.  Same as my comments about the SA support.  This is really only
needed on ports which need to register with the SA (or perhaps some future
entity) for Mcast support.

Also this is part of the ib_sa module and exports the function
ib_sa_join_multicast.  So that this point it is covered under the
cap_sa(device, port) call.

So the implementation of cap_mcast at this point is:

cap_mcast(device, port)
{
	return cap_sa(device,port);
}

> 
> Looking at this, I do wonder how a port can dynamically change between
> rocee and IB.. If the link value changes then mcast_remove_one will
> not be a perfect reversal of mcast_add_one. Bug?
> 
> It feels necessary to understand what happens when a port dynamically
> switches to ethernet on mlx hardware to validate these patches :(

Agreed.

:-(

-- Ira

> 
> Jason
