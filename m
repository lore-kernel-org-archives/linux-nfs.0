Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:35114 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbbCaXUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 19:20:08 -0400
Date: Tue, 31 Mar 2015 17:20:02 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Doug Ledford <dledford@redhat.com>
Cc: Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
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
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
Message-ID: <20150331232002.GB20094@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B98.1060103@profitbricks.com>
 <1427731980.21101.199.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427731980.21101.199.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 12:13:00PM -0400, Doug Ledford wrote:
> On Fri, 2015-03-27 at 16:47 +0100, Michael Wang wrote:
> > Introduce helper has_iwarp() to help us check if an IB device
> > support IWARP protocol.
> 
> This is a needless redirection.  Just stick with the original
> rdma_transport_is_iwarp().

Sticking with the original isn't really the point.

The point here, is to document what Tom was talking about - some ports
can only support one RDMA READ SGL entry, even though they support
multiple RDMA WRITE SGL entries. Today the query API assumes
READ/WRITE/SEND are symmetrical.

has_rdma_read_sgl() is a good way to document that for now, and is a big
flashing marker where something might need to be fixed in the
future.

This tells everyone reading the code and the API that when working
with RDMA READ they need to be aware of this limitation.

Jason
