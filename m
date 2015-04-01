Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:59288 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551AbbDAAvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 20:51:24 -0400
Date: Tue, 31 Mar 2015 20:51:13 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>,
        Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
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
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and cap_sa(), for sa-check
Message-ID: <20150401005113.GA15327@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com> <55157B43.6060507@profitbricks.com> <1427732191.21101.201.camel@redhat.com> <55197CDB.3040105@profitbricks.com> <1427734923.21101.227.camel@redhat.com> <20150331231202.GA20094@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150331231202.GA20094@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 05:12:02PM -0600, Jason Gunthorpe wrote:
> On Mon, Mar 30, 2015 at 01:02:03PM -0400, Doug Ledford wrote:
> 
> > If we use something like this, then the above is all you need.  Then
> > every place in the code that checks for something like has_sa or cap_sa
> > can be replaced with rdma_ib_mgmt. 
> 
> I don't want to see this slide back into some ill defined feature
> test.
> 
> We need to clearly define exactly what these tests are checking, and I
> think, since we have so much code sharing, the checks should be narrow
> in scope, not just an entire standard.

Somewhat agree.

> 
> I think the basic family of checks Michael identified seemed like
> a reasonable start.
> 
> Going forward we want to NAK stuff like this:
> 
>   if (rdma_ib_mgmt() || rdma_opa_mgmt())
>   if (has_sa() || has_opa_foobar())

I'm confused.

Is the idea that you would NAK has_sa but be in favor of has_ib_sa?

I think cap_opa_mad is reasonable.  And this confuses me why has_opa_foobar
would be NAKed.

I believe it is reasonable to flag OPA MAD support as a feature set through a
single bit.  From this the MAD stack can know if OPA MAD base/class versions
are allowed (or treated differently from future IB versions) and if it should
processing OPA SM Class DR MADs differently.  I don't want devices to be
required to supply a list of MAD Base/Class Versions they support.

> 
> That indicates we need a new micro feature test.

The million dollar question is how micro we should go.

More specifically which feature sets can be appropriately communicated with a
single bit vs not.

For example, the MAD size is more generally (and perhaps better) communicated
via an actual mad_size attribute rather than as part of the OPA MAD feature
set.

Another example is the question of is it appropriate to wrap up the single READ
SGL entry support within the "is iwarp" flag?

https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg23611.html

Right now there is implicit information being gleaned from the "is iwarp" flag.
That is that an iWarp device is limited to only 1 READ SGL entry.  As this is
the only device type which has this limitation _and_ that number is "well
known" it works.  Even if not the best solution.

The task at hand is to clean up implicit information passing like this while
not getting mired down in our own refactoring.

> 
> A big problem here is people working on the core may not know the
> intricate details of all the families. This will only get worse when
> proprietary tech like OPA gets added. Documenting requirements via a
> narrow feature test gives a much higher chance that core stuff will be
> right via review.

Agreed as long as we get the width right.

> 
> > But, like I said, this is an all or nothing change, it isn't
> > something we can ease into.
> 
> Well, we ease into it by introducing the micro tests and then wiping
> the legacy ones, followed by changing how the driver/core communicates
> the port and device feature set, ideally to a bitset like you've
> described.

I think this does need to be eased into.  We seem to agree that the feature
flags we have now are not granular and/or explicit enough.  So lets start
cleaning up some of these tests and see how it goes.

Ira

> 
> Michael has tackled the core code, another series could work on the
> drivers..
> 
> Jason
