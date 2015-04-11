Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-02.prod.phx3.secureserver.net ([173.201.192.231]:48166
	"EHLO p3plsmtpa07-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753337AbbDKABU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 20:01:20 -0400
Message-ID: <55286456.8060805@talpey.com>
Date: Fri, 10 Apr 2015 20:01:26 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: "ira.weiny" <ira.weiny@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Doug Ledford <dledford@redhat.com>,
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
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <20150410061610.GA26288@phlsvsds.ph.intel.com> <20150410161551.GA26419@obsidianresearch.com> <20150410173836.GE10675@phlsvsds.ph.intel.com> <20150410180455.GA1277@obsidianresearch.com> <1428690266.2980.381.camel@redhat.com> <20150410191723.GC1277@obsidianresearch.com> <20150410210639.GB19907@phlsvsds.ph.intel.com>
In-Reply-To: <20150410210639.GB19907@phlsvsds.ph.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/10/2015 5:06 PM, ira.weiny wrote:
> On Fri, Apr 10, 2015 at 01:17:23PM -0600, Jason Gunthorpe wrote:
>...
> So trying to sum up.
>
> Have we settled on the following "capabilities"?  Helper function names aside.
>
> /* legacy to communicate to userspace */
> RDMA_LINK_LAYER_IB       = 0x0000000000000001,
> RDMA_LINK_LAYER_ETH      = 0x0000000000000002,
> RDMA_LINK_LAYER_MASK     = 0x000000000000000f, /* more bits? */
> 	/* I'm hoping we don't need more bits here */
>
>
> /* legacy to communicate to userspace */
> RDMA_TRANSPORT_IB        = 0x0000000000000010,
> RDMA_TRANSPORT_IWARP     = 0x0000000000000020,
> RDMA_TRANSPORT_USNIC     = 0x0000000000000040,
> RDMA_TRANSPORT_USNIC_UDP = 0x0000000000000080,
> RDMA_TRANSPORT_MASK      = 0x00000000000000f0, /* more bits? */
> 	/* I'm hoping we don't need more bits here */
>
>
> /* New flags */
>
> RDMA_MGMT_IB_MAD         = 0x0000000000000100, /* ib_mad module support */
> RDMA_MGMT_QP0            = 0x0000000000000200, /* ib_mad QP0 support */
> RDMA_MGMT_IB_SA          = 0x0000000000000400, /* ib_sa module support */
> 					       /* NOTE includes IB Mcast */
> RDMA_MGMT_IB_CM          = 0x0000000000000800, /* ib_cm module support */
> RDMA_MGMT_OPA_MAD        = 0x0000000000001000, /* ib_mad OPA MAD support */
> RDMA_MGMT_MASK           = 0x00000000000fff00,

You explicitly say "userspace" - why would an upper layer need to
know the link, transport and management details? These seem to be
mid-layer matters.

> RDMA_ADDR_IB             = 0x0000000000100000, /* Port does IB AH, PR, Pkey */
> RDMA_ADDR_IBoE           = 0x0000000000200000, /* Port does IBoE AH, PR, Pkey */
> /* Do we need iWarp (TCP) here? */
> RDMA_ADDR_IB_MASK        = 0x000000000ff00000,

I do see a ULP needing to know the address family needed to pass to
rdma_connect and rdma_listen, so I would add "IP", but not "iWARP".

> RDMA_SEPARATE_READ_SGE   = 0x0000000010000000,
> RDMA_QUIRKS_MASK         = 0x000000fff0000000

This is good, but it also needs an attribute to signal the need for a
remote-writable RDMA Read sink buffer, for today's iWARP.

Tom.
