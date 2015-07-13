Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:58492 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbbGMRSp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 13:18:45 -0400
Date: Mon, 13 Jul 2015 11:18:33 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Doug Ledford <dledford@redhat.com>
Cc: Tom Talpey <tom@talpey.com>, "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150713171833.GF23832@obsidianresearch.com>
References: <20150709000337.GE16812@obsidianresearch.com>
 <559EF332.7060103@redhat.com>
 <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <55A00754.4010009@redhat.com>
 <20150710205706.GA7883@obsidianresearch.com>
 <55A046EF.1060800@redhat.com>
 <20150710233417.GA8919@obsidianresearch.com>
 <55A0891F.4050105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A0891F.4050105@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 11:10:23PM -0400, Doug Ledford wrote:

> >> access controls and connection filtering.  The app/ULP itself doesn't
> >> even need to be filter aware as you can do the filtering in the TCP
> >> stack on the primary listening socket using the netfilter tools.
> > 
> > Does netfilter work for iWarp? I'm surprised to hear that.
> 
> iWARP requires a normal TCP socket to connect to, then the client must
> initiate an RDMA transfer, then a new connection is opened for the RDMA
> transfers.  Blocking the parent dst:port/*:* will prevent these
> connections.  If you are referring to allowing an untrusted client in
> TCP mode but blocking them in RDMA mode, that's more complex and
> requires app/ULP support.

Yes, that would be the use case here. If someone wishes to deploy
auth-then-trust in TCP mode with NFS/iSCSI (which is a kernel
supported TCP/IP mode) we need to be absolutely certain there is no
way for anything untrusted to pivot a connection into a RDMA mode and
exploit the RKEY problem.

Out of the box this must be impossible. The surest way to guarentee
that is to have this hack off by default.

> Black hat server is beyond the scope of this discussion.

We cannot assume an all-trusted model here, there are many
configurations to deploy NFS/iSCSI that don't assume that. Even if you
assume it for the RDMA cases (which I stronlgy disagree with), it
still must be proven to not weaken the existing TCP/IP case.

So, a black hat server is on the table, attacking a client that the
admin is not intending to use with RDMA, by forcing it to switch to
RDMA before auth and exploiting the RDMA side.

This is where the iwarp guys have to analyze and come back to say it
is OK. Maybe iwarp can't get to rdma without auth or something...

Jason
