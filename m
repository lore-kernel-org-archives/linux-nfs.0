Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:43684 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbbC0R3Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 13:29:25 -0400
Date: Fri, 27 Mar 2015 11:29:12 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Michael Wang <yun.wang@profitbricks.com>,
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
Message-ID: <20150327172912.GA28901@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B98.1060103@profitbricks.com>
 <20150327161319.GB28412@obsidianresearch.com>
 <20150327171631.GC27862@phlsvsds.ph.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150327171631.GC27862@phlsvsds.ph.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 01:16:31PM -0400, ira.weiny wrote:
> On Fri, Mar 27, 2015 at 10:13:19AM -0600, Jason Gunthorpe wrote:
> > On Fri, Mar 27, 2015 at 04:47:36PM +0100, Michael Wang wrote:
> > > 
> > > Introduce helper has_iwarp() to help us check if an IB device
> > > support IWARP protocol.
> > 
> > Should probably be !has_rdma_read_sges()
> > 
> > True if the device can handle more than one SGE entry on a RDMA READ
> > work request.
> 
> Isn't this value already provided by the query_device verb?
> 
> The verbs spec states the Query HCA contains the:
> 
> "Maximum number of scatter/gather entries per Work Request supported by the
> HCA."

http://www.spinics.net/lists/linux-rdma/msg22565.html

''Unlike IB, the iWARP protocol only allows 1 target/sink SGE in an
rdma read''

It is one of those annoying verbs is different on iWarp things.

So the max sge in the query_verbs must only apply to send/rdma write
on iWarp?

Jason
