Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:55623 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbbC0Pzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 11:55:49 -0400
Date: Fri, 27 Mar 2015 09:55:30 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Moni Shoua <monis@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Jiri Kosina <jkosina@suse.cz>, Matan Barak <matanb@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>, Mel Gorman <mgorman@suse.de>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
Message-ID: <20150327155530.GA21778@obsidianresearch.com>
References: <5512CFB0.1050108@profitbricks.com>
 <1427378940.21101.100.camel@redhat.com>
 <55142DFD.2060100@profitbricks.com>
 <1427387258.21101.124.camel@redhat.com>
 <55143AAC.8040206@profitbricks.com>
 <20150326211334.GA3359@obsidianresearch.com>
 <5515284A.3030106@profitbricks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5515284A.3030106@profitbricks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:52:10AM +0100, Michael Wang wrote:
> Basically I found there are three kind of check in current
> implementation:
> 
> 1. check transport type of device only
>     I'd like to use helper has_XX(device)
>     which means some port of the device has XX capability.
> 
> 2. check link layer of device's port only
>     I'd like to use helper cap_XX(device, port)
>     which means the port has XX capability
> 
> 3. check both the transport type and link layer
>     I'd like to use helper tech_XX(device, port)
>     which means the port of that device using technology
>     ib, iwrap, iboe(roce) ...

So, in principle, testing the device should almost make sense. The
device is the container for things like PD's MR's and QP's and those
things can migrate between the ports freely, so all post must share
the same attributes for those items.

However.. AFAIK, we can have RoCEE and IB ports on the same device -
which makes that whole concept seem sort of like nonsense..

Anyhow, I would discourage testing the device. Each site has to be
examined and determine if it working with a single port and really
needs a port attribute (which may be a device attribute today) or if
it is doing something device wide and is checking if all ports support
X.

> Let's discuss and figure out the right name in the thread of
> v2 patch set, I guess there will be a lot to be correct :-P

Well, this is actually a hard job. This isn't a mechanical clean up,
each site has to be inspected and understood before it can be
migrated to the correct API.

Jason
