Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-02.prod.phx3.secureserver.net ([173.201.192.231]:40078
	"EHLO p3plsmtpa07-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751270AbbGMWXH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 18:23:07 -0400
Message-ID: <55A43A44.7060605@talpey.com>
Date: Mon, 13 Jul 2015 18:23:00 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Doug Ledford <dledford@redhat.com>
CC: "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <55A00754.4010009@redhat.com> <20150710205706.GA7883@obsidianresearch.com> <55A046EF.1060800@redhat.com> <20150710233417.GA8919@obsidianresearch.com> <55A0891F.4050105@redhat.com> <20150713171833.GF23832@obsidianresearch.com>
In-Reply-To: <20150713171833.GF23832@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/13/2015 1:18 PM, Jason Gunthorpe wrote:
> On Fri, Jul 10, 2015 at 11:10:23PM -0400, Doug Ledford wrote:
>> Black hat server is beyond the scope of this discussion.
>
> We cannot assume an all-trusted model here, there are many
> configurations to deploy NFS/iSCSI that don't assume that. Even if you
> assume it for the RDMA cases (which I stronlgy disagree with), it
> still must be proven to not weaken the existing TCP/IP case.
>
> So, a black hat server is on the table, attacking a client that the
> admin is not intending to use with RDMA, by forcing it to switch to
> RDMA before auth and exploiting the RDMA side.
>
> This is where the iwarp guys have to analyze and come back to say it
> is OK. Maybe iwarp can't get to rdma without auth or something...

Two observations.

One, auth is an Upper Layer matter. It's not the job of the transport
to authenticate the peer, the user, etc. Upper layers do this, and
iSCSI performs a login, NFSv4.1+ creates a session, SMB3 creates
sessions on multiple connections, etc. All this happens after the
connection is established.

Two, the iSCSI and NFSv4.1 protocols have explicit support for iWARP
"step-up" mode, which supports an initial connection in TCP (i.e.
with RDMA disabled), and switching to RDMA mode dynamically.

The IB and RoCE protocols do not support step-up mode, so in fact
one could argue that iWARP is *better* positioned to support this.

Tom.

