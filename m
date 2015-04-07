Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15685 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828AbbDGUSD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 16:18:03 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Michael Wang <yun.wang@profitbricks.com>
CC: Roland Dreier <roland@kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        "Tom Tucker" <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        infinipath <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        "Latif, Faisal" <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        "Nikolova, Tatyana E" <tatyana.e.nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        "Haggai Eran" <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        "Yann Droneaud" <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        "Li RongQing" <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        "Estrin, Alex" <alex.estrin@intel.com>,
        "Doug Ledford" <dledford@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        "Erez Shitrit" <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: RE: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB
 helpers
Date: Tue, 7 Apr 2015 20:18:00 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBE3B0@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CF0A.5090206@profitbricks.com>
 <20150407201259.GA17147@obsidianresearch.com>
In-Reply-To: <20150407201259.GA17147@obsidianresearch.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > index f704254..4e61104 100644
> > +++ b/drivers/infiniband/core/sa_query.c
> > @@ -540,7 +540,7 @@ int ib_init_ah_from_path(struct ib_device *device,
> u8 port_num,
> >  	ah_attr->port_num = port_num;
> >  	ah_attr->static_rate = rec->rate;
> >
> > -	force_grh = rdma_port_get_link_layer(device, port_num) ==
> IB_LINK_LAYER_ETHERNET;
> > +	force_grh = !rdma_transport_ib(device, port_num);
> 
> Maybe these tests should be called cap_mandatory_grh - but I'm not
> really sure how iWarp uses the GRH fields in the AH...

AH are used with unconnected endpoints, which iWarp doesn't currently support.
