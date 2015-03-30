Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42235 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbbC3Wfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 18:35:31 -0400
Date: Mon, 30 Mar 2015 16:35:28 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: "ira.weiny" <ira.weiny@intel.com>, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
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
Message-ID: <20150330223528.GB27728@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B98.1060103@profitbricks.com>
 <20150327161319.GB28412@obsidianresearch.com>
 <20150327171631.GC27862@phlsvsds.ph.intel.com>
 <20150327172912.GA28901@obsidianresearch.com>
 <55196754.5010600@profitbricks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55196754.5010600@profitbricks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 05:10:12PM +0200, Michael Wang wrote:
> I found that actually we don't have to touch this one which
> only used by HW driver currently.

I'm having a hard time understanding this, the code in question was in

net/sunrpc/xprtrdma/svc_rdma_recvfrom.c

Which is the NFS ULP, not a device driver.

Regards,
Jason
