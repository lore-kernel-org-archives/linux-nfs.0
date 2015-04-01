Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:57882 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797AbbDABbu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 21:31:50 -0400
Date: Tue, 31 Mar 2015 19:31:35 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "ira.weiny" <ira.weiny@intel.com>
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
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
Message-ID: <20150401013135.GA29331@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B43.6060507@profitbricks.com>
 <1427732191.21101.201.camel@redhat.com>
 <55197CDB.3040105@profitbricks.com>
 <1427734923.21101.227.camel@redhat.com>
 <20150331231202.GA20094@obsidianresearch.com>
 <20150401005113.GA15327@phlsvsds.ph.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150401005113.GA15327@phlsvsds.ph.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 08:51:13PM -0400, ira.weiny wrote:

> > Going forward we want to NAK stuff like this:
> > 
> >   if (rdma_ib_mgmt() || rdma_opa_mgmt())
> >   if (has_sa() || has_opa_foobar())
> 
> I'm confused.
> 
> Is the idea that you would NAK has_sa but be in favor of has_ib_sa?

It is the || I don't want to see. Feature tests should be one thing.

> I believe it is reasonable to flag OPA MAD support as a feature set through a
> single bit.  From this the MAD stack can know if OPA MAD base/class versions
> are allowed (or treated differently from future IB versions) and if it should
> processing OPA SM Class DR MADs differently.  I don't want devices to be
> required to supply a list of MAD Base/Class Versions they support.

That seems reasonable, but we'd gain a is_ib_smp and is_opa_smp test
to do that.

> For example, the MAD size is more generally (and perhaps better) communicated
> via an actual mad_size attribute rather than as part of the OPA MAD feature
> set.

Start with a bit and change when that makes no sense, MTUs as ints
make sense.

> Another example is the question of is it appropriate to wrap up the single READ
> SGL entry support within the "is iwarp" flag?

Again, stick with a single bit test until a HW vendors needs more,
then someone can clean it. At least they now know what to clean and
why.

Remember, this is in the kernel, we can change it when it outlives its
life.

Jason
