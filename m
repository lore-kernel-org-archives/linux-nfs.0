Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47432 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554AbbDJSMA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 14:12:00 -0400
Date: Fri, 10 Apr 2015 14:11:44 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
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
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport() for each HW
Message-ID: <20150410181143.GA5716@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <20150410061610.GA26288@phlsvsds.ph.intel.com> <20150410161551.GA26419@obsidianresearch.com> <20150410173836.GE10675@phlsvsds.ph.intel.com> <1428688172.2980.372.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428688172.2980.372.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 01:49:32PM -0400, Doug Ledford wrote:
> On Fri, 2015-04-10 at 13:38 -0400, ira.weiny wrote:
> 
> 
> > > I think if we look closely we'll find that IPoIB today has a hard
> > > requirement on cap_sa being true, so lets use that?
> > 
> > I don't think that is appropriate.  You have been advocating that the checks
> > be clear as to what support we need.  While currently the IPoIB layer does (for
> > IB and OPA) require an SA I think those checks are only appropriate when it is
> > attempting an SA query.
> > 
> > The choice to run IPoIB at all is a different matter.
> 
> Appropriately named or not, Jason's choice of words "has a hard
> requirement" is correct ;-)

Agreed.  I meant that using "cap_sa" is not appropriate.  Not that IPoIB did
not have a hard requirement...  :-D

I actually think that _both_ the check for IB link layer and the "cap_sa" is
required.  Perhaps not at start up...

Ira

