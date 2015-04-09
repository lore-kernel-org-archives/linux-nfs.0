Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53904 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755485AbbDIQB1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2015 12:01:27 -0400
Date: Thu, 9 Apr 2015 10:01:23 -0600
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
Message-ID: <20150409160123.GA31353@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
 <20150408201015.GB28666@obsidianresearch.com>
 <1428590070.2980.190.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428590070.2980.190.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 09, 2015 at 10:34:30AM -0400, Doug Ledford wrote:

> These are exactly the tests I proposed Jason.  I'm not sure I see your
> point here.  I guess my point is that although the scenario of all the
> different items seems complex, it really does boil down to needing only
> exactly what I proposed earlier to fulfill the entire test matrix.

I have no problem with minimizing a bitmap, but I want the accessors
to make sense first.

My specific problem with your suggestion was combining cap_ib_mad,
cap_ib_sa, and cap_ib_smi into rdma_port_ib_fabric_mgmt.

Not only do the three cap things not return the same value for all
situations, the documentary knowledge is lost by the reduction.

I'd prefer we look at this from a 'what do the call sites need' view,
not a 'how do we minimize' view.

I've written this before: The mess here is that it is too hard to know
what the call sites are actually checking for when it is some baroque
conditional.

Jason
