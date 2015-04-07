Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:37014 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbbDGRmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Apr 2015 13:42:38 -0400
Date: Tue, 7 Apr 2015 11:42:23 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Tom Talpey <tom@talpey.com>
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 09/17] IB/Verbs: Use helper cap_read_multi_sge() and
 reform svc_rdma_accept()
Message-ID: <20150407174223.GB15704@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CEE4.5060901@profitbricks.com>
 <5523FBF1.80304@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5523FBF1.80304@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2015 at 11:46:57AM -0400, Tom Talpey wrote:
> On 4/7/2015 8:34 AM, Michael Wang wrote:
> >  /**
> >+ * cap_read_multi_sge - Check if the port of device has the capability
> >+ * RDMA Read Multiple Scatter-Gather Entries.
> >+ *
> >+ * @device: Device to be checked
> >+ * @port_num: Port number of the device
> >+ *
> >+ * Return 0 when port of the device don't support
> >+ * RDMA Read Multiple Scatter-Gather Entries.
> >+ */
> >+static inline int cap_read_multi_sge(struct ib_device *device, u8 port_num)
> >+{
> >+	return !rdma_transport_iwarp(device, port_num);
> >+}
> 
> This just papers over the issue we discussed earlier. How *many*
> entries does the device support? If a device supports one, or two,
> is that enough? How does the upper layer know the limit?

I think Michael is fine to just make this one mechanical change.

The kernel only supports two kinds of devices today, ones with 1 read
SGE and ones where READ SGE == WRITE SGE == SEND SGE.

If someone makes another variation then it is up to them to propose a
better fix.


> >  static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
> >  {
> >-	if (rdma_node_get_transport(xprt->sc_cm_id->device->node_type) ==
> >-	     RDMA_TRANSPORT_IWARP)
> >+	if (!cap_read_multi_sge(xprt->sc_cm_id->device,
> >+				xprt->sc_cm_id->port_num))
> >  		return 1;
> >  	else
> >  		return min_t(int, sge_count, xprt->sc_max_sge);
> 
> This is incorrect. The RDMA Read max is not at all the same as the
> max_sge. It is a different operation, with a different set of work
> request parameters.

The algorithm looks OK to me,

        newxprt->sc_max_sge = min((size_t)devattr.max_sge,
                                  (size_t)RPCSVC_MAXPAGES);

So it returns 1 or the number of sge entries per WR, and max_sge is
for READ/WRITE/SEND in every case except when cap_read_multi_sge == 1

> >  	/*
> >  	 * Determine if a DMA MR is required and if so, what privs are required
> >  	 */
> >-	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
> >-	case RDMA_TRANSPORT_IWARP:
> >+	if (rdma_transport_iwarp(newxprt->sc_cm_id->device,
> >+				 newxprt->sc_cm_id->port_num)) {
> >  		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
> 
> Do I read this correctly that it is forcing the "read with invalidate"
> capability to "on" for all iWARP devices? I don't think that is correct,
> for the legacy devices you're also supporting.

No idea here, this logic was added in:

commit 3a5c63803d0552a3ad93b85c262f12cd86471443
Author: Tom Tucker <tom@opengridcomputing.com>
Date:   Tue Sep 30 13:46:13 2008 -0500

    svcrdma: Query device for Fast Reg support during connection setup
    
    Query the device capabilities in the svc_rdma_accept function to determine
    what advanced memory management capabilities are supported by the device.
    Based on the query, select the most secure model available given the
    requirements of the transport and capabilities of the adapter.
    
    Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

> >@@ -992,8 +992,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
> >  			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
> >  		} else
> >  			need_dma_mr = 0;
> >-		break;
> >-	case RDMA_TRANSPORT_IB:
> >+	} else if (rdma_ib_mgmt(newxprt->sc_cm_id->device,
> >+				newxprt->sc_cm_id->port_num)) {
> >  		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
> >  			need_dma_mr = 1;
> >  			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
> 
> Now I'm even more confused. How is the presence of IB management
> related to needing a privileged lmr?

Agree, this needs to be someone else. 

I think the test is probably based on this comment:

        * NB:  iWARP requires remote write access for the data sink
        *      of an RDMA_READ. IB does not.

So the if should be:

          if (cap_rdma_read_needs_write(..) && 
	  !(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
                       need_dma_mr = 1;
                       dma_mr_acc =
                               (IB_ACCESS_LOCAL_WRITE |
                                IB_ACCESS_REMOTE_WRITE);

And the identical if blocks merged.

Plus the
	if (rdma_transport_iwarp(newxprt->sc_cm_id->device,
				 newxprt->sc_cm_id->port_num))
  		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV

Jason
