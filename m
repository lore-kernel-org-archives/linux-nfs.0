Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:41696 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756013AbbDJSFK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 14:05:10 -0400
Date: Fri, 10 Apr 2015 12:04:55 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "ira.weiny" <ira.weiny@intel.com>
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
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Message-ID: <20150410180455.GA1277@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
 <20150408201015.GB28666@obsidianresearch.com>
 <20150410061610.GA26288@phlsvsds.ph.intel.com>
 <20150410161551.GA26419@obsidianresearch.com>
 <20150410173836.GE10675@phlsvsds.ph.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150410173836.GE10675@phlsvsds.ph.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 01:38:38PM -0400, ira.weiny wrote:
 
> Isn't ocrdma an iWarp device?

No, it is RoCEE

> > I was wondering why there are so many checks in the SA code, I know
> > RoCEE doesn't use it, but why are there there?
> 
> Which checks are you referring to?  I think there are separate calls to query
> the SA when running on IB for both the Route resolution and the Multicast join
> operations.  The choice of those calls could be made by a "cap_sa()" helper.

I will point them out next time I look through the patches

> > I think if we look closely we'll find that IPoIB today has a hard
> > requirement on cap_sa being true, so lets use that?
> 
> I don't think that is appropriate.  You have been advocating that the checks
> be clear as to what support we need. 

Right, but this is narrow, and we are not hiding meaning.

Look at the IPoIB ULP, and look at the hard requiments of the code,
then translate those back to our new cap scheme. We see today's IPoIB
will not run without:
 - UD support
 - IB addressing
 - IB multicast
 - IB SA
 - CM (optional)

It seems perfectly correct for a ULP to say at the very start, I need
all these caps, or I will not run (how could it run?). This is true of
any ULP that has a hard need to use those APIs.

That would seem to be the very essance of the cap scheme. Declare what
you need, not what standard you think you need.

Hiding meaning is to say 'only run on IB or OPA': WHY are we limited
to those two?

> While currently the IPoIB layer does (for IB and OPA) require an SA
> I think those checks are only appropriate when it is attempting an
> SA query.

That doesn't make any sense unless someone also adds support for
handling the !SA case.

> > It appears we have at least rocee, rocee v2 (udp?), tcp, ib and opa
> > address and AH formats?
> 
> Seems that way.  But has the rocee v2 been accepted?

Don't know much about it yet, patches exist, it seems to have a
slightly different addressing format.

> > opa would support ib addresses too I guess.
> 
> Yes opa address == ib addresses.  So there is no need to distinguish them.

The patches you sent showed a different LRH format for OPA (eg 32 bit
LID), so someday we will need to know that the full 32 bit LID is
available.

We can see how this might work in future, lets say OPAv2 *requires* the
32 bit LID, for that case cap_ib_address = 0 cap_opa_address = 1. If
we don't update IPoIB and it uses the tests from above then it
immediately, and correctly, stops running on those OPAv2 devices.

Once patched to support cap_op_address then it will begin working
again. That seems very sane..

Jason
