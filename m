Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:36668 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706AbbC0Rto (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 13:49:44 -0400
Date: Fri, 27 Mar 2015 11:49:41 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Yun Wang <yun.wang@profitbricks.com>
Cc: "ira.weiny" <ira.weiny@intel.com>, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
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
Message-ID: <20150327174941.GC28901@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B71.6040505@profitbricks.com>
 <20150327162820.GC28412@obsidianresearch.com>
 <20150327170508.GB27862@phlsvsds.ph.intel.com>
 <CAJuTgQUSm0pM8pqLiivTrKbhtXkKYZaZbBxYFTog0JatzQm3=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJuTgQUSm0pM8pqLiivTrKbhtXkKYZaZbBxYFTog0JatzQm3=g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 06:31:26PM +0100, Yun Wang wrote:

> Maybe we can temporarily reserve the old logical, and gradually solve
> these problems?

It is best to make behavioral changes in small patches, yes.

I think it is best to address these sorts of problems before trying to
tackle the driver interface side - that will avoid complexity.

ie how does a driver set has_ipoib? It isn't even a sensible question
when it is a per port capability.

Jason
