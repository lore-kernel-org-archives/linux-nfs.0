Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4480 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043AbbC3Xr2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 19:47:28 -0400
Date: Mon, 30 Mar 2015 19:47:17 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Doug Ledford <dledford@redhat.com>, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
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
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast() and, cap_mcast() for mcast-check
Message-ID: <20150330234717.GA28446@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com> <55157B71.6040505@profitbricks.com> <1427731918.21101.198.camel@redhat.com> <551977E0.5030001@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <551977E0.5030001@profitbricks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 06:20:48PM +0200, Michael Wang wrote:
> On 03/30/2015 06:11 PM, Doug Ledford wrote:
> > On Fri, 2015-03-27 at 16:46 +0100, Michael Wang wrote:
> >> Introduce helper has_mcast() and cap_mcast() to help us check if an
> >> IB device or it's port support Multicast.
> > This probably needs reworded or rethought.  In truth, *all* rdma devices
> > are multicast capable.  *BUT*, IB/OPA devices require multicast
> > registration done the IB way (including for sendonly multicast sends),
> > while Ethernet devices do multicast the Ethernet way.  These tests are
> > really just for IB specific multicast registration and deregistration.
> > Call it has_mcast() and cap_mcast() is incorrect.
> 
> Thanks for the explanation :-)
> 
> Jason also mentioned we should use cap_ib_XX() instead, I'll use
> that name then we can distinguish the management between
> Eth and IB/OPA.
> 
> Regards,
> Michael Wang
> 
> 
> >
> >> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> >> Cc: Doug Ledford <dledford@redhat.com>
> >> Cc: Ira Weiny <ira.weiny@intel.com>
> >> Cc: Sean Hefty <sean.hefty@intel.com>
> >> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> >> ---
> >>  drivers/infiniband/core/cma.c       |  2 +-
> >>  drivers/infiniband/core/multicast.c |  8 ++++----
> >>  include/rdma/ib_verbs.h             | 28 ++++++++++++++++++++++++++++
> >>  3 files changed, 33 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
> >> index 276fb76..cbbc85b 100644
> >> --- a/drivers/infiniband/core/cma.c
> >> +++ b/drivers/infiniband/core/cma.c
> >> @@ -3398,7 +3398,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
> >>                  ib_detach_mcast(id->qp,
> >>                          &mc->multicast.ib->rec.mgid,
> >>                          be16_to_cpu(mc->multicast.ib->rec.mlid));
> >> -            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
> >> +            if (has_mcast(id_priv->cma_dev->device)) {


You need a similar check in rdma_join_multicast.

Ira


> >>                  switch (rdma_port_get_link_layer(id->device, id->port_num)) {
> >>                  case IB_LINK_LAYER_INFINIBAND:
> >>                      ib_sa_free_multicast(mc->multicast.ib);
> >> diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
> >> index 17573ff..ffeaf27 100644
> >> --- a/drivers/infiniband/core/multicast.c
> >> +++ b/drivers/infiniband/core/multicast.c
> >> @@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
> >>      int index;
> >>  
> >>      dev = container_of(handler, struct mcast_device, event_handler);
> >> -    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
> >> +    if (!cap_mcast(dev->device, event->element.port_num))
> >>          return;
> >>  
> >>      index = event->element.port_num - dev->start_port;
> >> @@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
> >>      int i;
> >>      int count = 0;
> >>  
> >> -    if (!rdma_transport_is_ib(device))
> >> +    if (!has_mcast(device))
> >>          return;
> >>  
> >>      dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
> >> @@ -823,7 +823,7 @@ static void mcast_add_one(struct ib_device *device)
> >>      }
> >>  
> >>      for (i = 0; i <= dev->end_port - dev->start_port; i++) {
> >> -        if (!rdma_port_ll_is_ib(device, dev->start_port + i))
> >> +        if (!cap_mcast(device, dev->start_port + i))
> >>              continue;
> >>          port = &dev->port[i];
> >>          port->dev = dev;
> >> @@ -861,7 +861,7 @@ static void mcast_remove_one(struct ib_device *device)
> >>      flush_workqueue(mcast_wq);
> >>  
> >>      for (i = 0; i <= dev->end_port - dev->start_port; i++) {
> >> -        if (rdma_port_ll_is_ib(device, dev->start_port + i)) {
> >> +        if (cap_mcast(device, dev->start_port + i)) {
> >>              port = &dev->port[i];
> >>              deref_port(port);
> >>              wait_for_completion(&port->comp);
> >> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> >> index fa8ffa3..e796104 100644
> >> --- a/include/rdma/ib_verbs.h
> >> +++ b/include/rdma/ib_verbs.h
> >> @@ -1823,6 +1823,19 @@ static inline int has_sa(struct ib_device *device)
> >>  }
> >>  
> >>  /**
> >> + * has_mcast - Check if a device support Multicast.
> >> + *
> >> + * @device: Device to be checked
> >> + *
> >> + * Return 0 when a device has none port to support
> >> + * Multicast.
> >> + */
> >> +static inline int has_mcast(struct ib_device *device)
> >> +{
> >> +    return rdma_transport_is_ib(device);
> >> +}
> >> +
> >> +/**
> >>   * cap_smi - Check if the port of device has the capability
> >>   * Subnet Management Interface.
> >>   *
> >> @@ -1852,6 +1865,21 @@ static inline int cap_sa(struct ib_device *device, u8 port_num)
> >>      return rdma_port_ll_is_ib(device, port_num);
> >>  }
> >>  
> >> +/**
> >> + * cap_mcast - Check if the port of device has the capability
> >> + * Multicast.
> >> + *
> >> + * @device: Device to be checked
> >> + * @port_num: Port number of the device
> >> + *
> >> + * Return 0 when port of the device don't support
> >> + * Multicast.
> >> + */
> >> +static inline int cap_mcast(struct ib_device *device, u8 port_num)
> >> +{
> >> +    return rdma_port_ll_is_ib(device, port_num);
> >> +}
> >> +
> >>  int ib_query_gid(struct ib_device *device,
> >>           u8 port_num, int index, union ib_gid *gid);
> >>  
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
