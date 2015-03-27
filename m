Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42782 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445AbbC0Rri (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 13:47:38 -0400
Date: Fri, 27 Mar 2015 11:47:27 -0600
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
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast()
 and, cap_mcast() for mcast-check
Message-ID: <20150327174727.GB28901@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B71.6040505@profitbricks.com>
 <20150327162820.GC28412@obsidianresearch.com>
 <20150327170508.GB27862@phlsvsds.ph.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150327170508.GB27862@phlsvsds.ph.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 01:05:08PM -0400, ira.weiny wrote:

> > But it seems redudent, since mcast_add_one will already not add a port that is
> > not IB, so mcast_event_handler is not callable. Something to do with
> > rocee/ib switching?
> 
> I'm not sure about this either.  This check seems to be necessary only on a
> per-port level.  It does seem apparent that one can't go from Eth to IB.  What
> happens if you go from IB to Eth on the port?

Hmm... I see a mlx4_change_port_types which ultimately calls
ib_unregister_device, which suggests the port type doesn't change at
runtime (yay)

So maybe these checks really are redundant?

Jason
