Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60384 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbbDIFhH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2015 01:37:07 -0400
Date: Thu, 9 Apr 2015 01:36:51 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Michael Wang'" <yun.wang@profitbricks.com>,
        "'Roland Dreier'" <roland@kernel.org>,
        "'Sean Hefty'" <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "'Hal Rosenstock'" <hal.rosenstock@gmail.com>,
        "'Tom Tucker'" <tom@opengridcomputing.com>,
        "'Hoang-Nam Nguyen'" <hnguyen@de.ibm.com>,
        "'Christoph Raisch'" <raisch@de.ibm.com>,
        "'Mike Marciniszyn'" <infinipath@intel.com>,
        "'Eli Cohen'" <eli@mellanox.com>,
        "'Faisal Latif'" <faisal.latif@intel.com>,
        "'Upinder Malhi'" <umalhi@cisco.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'David S. Miller'" <davem@davemloft.net>,
        "'PJ Waskiewicz'" <pj.waskiewicz@solidfire.com>,
        "'Tatyana Nikolova'" <Tatyana.E.Nikolova@intel.com>,
        "'Or Gerlitz'" <ogerlitz@mellanox.com>,
        "'Jack Morgenstein'" <jackm@dev.mellanox.co.il>,
        "'Haggai Eran'" <haggaie@mellanox.com>,
        "'Ilya Nelkenbaum'" <ilyan@mellanox.com>,
        "'Yann Droneaud'" <ydroneaud@opteya.com>,
        "'Bart Van Assche'" <bvanassche@acm.org>,
        "'Shachar Raindel'" <raindel@mellanox.com>,
        "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Devesh Sharma'" <devesh.sharma@emulex.com>,
        "'Matan Barak'" <matanb@mellanox.com>,
        "'Moni Shoua'" <monis@mellanox.com>, "'Jiri Kosina'" <jkosina@suse.cz>,
        "'Selvin Xavier'" <selvin.xavier@emulex.com>,
        "'Mitesh Ahuja'" <mitesh.ahuja@emulex.com>,
        "'Li RongQing'" <roy.qing.li@gmail.com>,
        "'Rasmus Villemoes'" <linux@rasmusvillemoes.dk>,
        "'Alex Estrin'" <alex.estrin@intel.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "'Eric Dumazet'" <edumazet@google.com>,
        "'Erez Shitrit'" <erezsh@mellanox.com>,
        "'Tom Gundersen'" <teg@jklm.no>,
        "'Chuck Lever'" <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
Message-ID: <20150409053651.GB28926@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com> <5523CF0A.5090206@profitbricks.com> <20150407201259.GA17147@obsidianresearch.com> <008401d0716f$bc41c5c0$34c55140$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <008401d0716f$bc41c5c0$34c55140$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2015 at 03:16:30PM -0500, Steve Wise wrote:
> 
> 
> > -----Original Message-----
> > From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
> > Sent: Tuesday, April 07, 2015 3:13 PM
> > To: Michael Wang
> > Cc: Roland Dreier; Sean Hefty; linux-rdma@vger.kernel.org; linux-kernel@vger.kernel.org; linux-nfs@vger.kernel.org;
> > netdev@vger.kernel.org; Hal Rosenstock; Tom Tucker; Steve Wise; Hoang-Nam Nguyen; Christoph Raisch; Mike Marciniszyn; Eli Cohen;
> > Faisal Latif; Upinder Malhi; Trond Myklebust; J. Bruce Fields; David S. Miller; Ira Weiny; PJ Waskiewicz; Tatyana Nikolova; Or
> Gerlitz; Jack
> > Morgenstein; Haggai Eran; Ilya Nelkenbaum; Yann Droneaud; Bart Van Assche; Shachar Raindel; Sagi Grimberg; Devesh Sharma; Matan
> > Barak; Moni Shoua; Jiri Kosina; Selvin Xavier; Mitesh Ahuja; Li RongQing; Rasmus Villemoes; Alex Estrin; Doug Ledford; Eric
> Dumazet; Erez
> > Shitrit; Tom Gundersen; Chuck Lever
> > Subject: Re: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
> > 
> > On Tue, Apr 07, 2015 at 02:35:22PM +0200, Michael Wang wrote:
> > > index f704254..4e61104 100644
> > > +++ b/drivers/infiniband/core/sa_query.c
> > > @@ -540,7 +540,7 @@ int ib_init_ah_from_path(struct ib_device *device, u8 port_num,
> > >  	ah_attr->port_num = port_num;
> > >  	ah_attr->static_rate = rec->rate;
> > >
> > > -	force_grh = rdma_port_get_link_layer(device, port_num) == IB_LINK_LAYER_ETHERNET;
> > > +	force_grh = !rdma_transport_ib(device, port_num);
> > 
> > Maybe these tests should be called cap_mandatory_grh - but I'm not
> > really sure how iWarp uses the GRH fields in the AH...
> > 
> 
> iWARP runs on top of TCP...this SA code is all IB-specific.  The reason it was checking for ETHERNET, I think, is for RoCE.    So
> this change is totally incorrect,  I think,  because RoCE is an IB transport, but it runs on ETHERNET.

But RoCE does not have an SA?

Looks like ib_init_ah_from_path was overloaded to handle non-standard "path
records".

It seems like the correct functionality would be to use ib_init_ah_from_path()
for true SA PathRecords and have another call iboe_init_ah() wrap
ib_init_ah_from_path() when RoCE address information is needed in the AH.

For Michaels patches I think 

	force_grh = rdma_device_is_iboe(...)

is the logic we need here.

Ira


> 
> Steve.
> 
> 
> 
