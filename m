Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33094 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319AbbDJTRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 15:17:43 -0400
Date: Fri, 10 Apr 2015 13:17:23 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Doug Ledford <dledford@redhat.com>
Cc: "ira.weiny" <ira.weiny@intel.com>,
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
Message-ID: <20150410191723.GC1277@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
 <20150408201015.GB28666@obsidianresearch.com>
 <20150410061610.GA26288@phlsvsds.ph.intel.com>
 <20150410161551.GA26419@obsidianresearch.com>
 <20150410173836.GE10675@phlsvsds.ph.intel.com>
 <20150410180455.GA1277@obsidianresearch.com>
 <1428690266.2980.381.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428690266.2980.381.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 02:24:26PM -0400, Doug Ledford wrote:

> IPoIB is more than just an ULP.  It's a spec.  And it's very IB
> specific.  It will only work with OPA because OPA is imitating IB.
> To run it on another fabric, you would need more than just to make
> it work.  If the new fabric doesn't have a broadcast group, or has
> multicast registration like IB does, you need the equivalent of
> IBTA, whatever that may be for this new fabric, buy in on the
> pre-defined multicast groups and you might need firmware support in
> the switches.

It feels like the 'cap_ib_addressing' or whatever we call it captures
this very well. The IPoIB RFC is very much concerned with GID's and
MGID's and broadly requires the IBA addressing
scheme. cap_ib_addressing asserts the port uses that scheme. 

We wouldn't accept patches to IPoIB to add a new addressing scheme
without seeing proper diligence to the standards work.

Looking away from the stadards, using cap_XX seems very sane: We are
building a well defined system of invarients, You can't call into the
sa functions if cap_sa is not set, you can't call into the mcast
functions if cap_mcast is not set, you can't form a AH from IB
GIDs/MGID/LID without cap_ib_addressing.

I makes so much sense for the ULP to directly require the needed cap's
for the kernel APIs it intends to call, or not use the RDMA port at
all.

> > We can see how this might work in future, lets say OPAv2 *requires* the
> > 32 bit LID, for that case cap_ib_address = 0 cap_opa_address = 1. If
> > we don't update IPoIB and it uses the tests from above then it
> > immediately, and correctly, stops running on those OPAv2 devices.
> > 
> > Once patched to support cap_op_address then it will begin working
> > again. That seems very sane..
> 
> It is very sane from an implementation standpoint, but from the larger
> interoperability standpoint, you need that spec to be extended to the
> new fabric simultaneously.

I liked the OPAv2 hypothetical because it doesn't actually touch the
IPoIB spec. IPoIB spec has little to say about LIDs or LRHs it works
entirely at the GID/MGID/GRH level.

Jason
