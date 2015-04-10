Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-06.prod.phx3.secureserver.net ([173.201.193.235]:44972
	"EHLO p3plsmtpa09-06.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756159AbbDJRuT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 13:50:19 -0400
Message-ID: <55280D51.20402@talpey.com>
Date: Fri, 10 Apr 2015 13:50:09 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Doug Ledford <dledford@redhat.com>, "ira.weiny" <ira.weiny@intel.com>
CC: Michael Wang <yun.wang@profitbricks.com>,
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
References: <5523CCD5.6030401@profitbricks.com>	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>	 <20150410074805.GA11855@phlsvsds.ph.intel.com> <1428685843.2980.353.camel@redhat.com>
In-Reply-To: <1428685843.2980.353.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/10/2015 1:10 PM, Doug Ledford wrote:
> As per my above statement, rdma_transport* tests were testing the high
> level transport type, rdma_port* types were testing link layers.  iWARP
> has an Eth link layer, so technically port_is_iwarp makes no sense.  But
> since all the other types had a check too, I included port_is_iwarp just
> to be complete, and if you are going to ask if a specific port is iwarp
> as a link layer, it makes sense to say yes if the transport is iwarp,
> not if the link layer is eth.

Not wanting to split hairs, but I would not rule out the possibility
of a future device supporting iWARP on one port and another RDMA
protocol on another. One could also imagine softiWARP and softROCE
co-existing atop a single ethernet NIC.

So, I disagree that port_is_iwarp() is a nonsequitur.

Tom.

