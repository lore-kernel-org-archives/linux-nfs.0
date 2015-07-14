Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42743 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbbGNQWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 12:22:31 -0400
Date: Tue, 14 Jul 2015 10:22:17 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>, Tom Talpey <tom@talpey.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714162217.GB7399@obsidianresearch.com>
References: <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org>
 <55A4134C.2040301@talpey.com>
 <20150713201538.GA11681@obsidianresearch.com>
 <55A4D20C.2000904@dev.mellanox.co.il>
 <20150714153619.GC11026@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150714153619.GC11026@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 08:36:19AM -0700, 'Christoph Hellwig' wrote:
> Oh, I had missed that PHYS_MR might sleep.  That might be the reasons
> why everyone is avoiding them despite Tom preferring them over FMR.

Yep, almost certainly.

But even that is just a legacy of the bad API.

Even Sagi's API idea can accommodate this with enough driver effort,
but only if posting is combined:

- alloc_mr: Just set aside any memory the driver needs for PHYS_MR
- set_sg_list_and_post:
  + This would issue the PHYS_MR call to the NIC, but not
    sleep. It would adjust the SQ so that the tail pointer is blocked
    and the NIC doesn't see any more posts. Effectively, the SQ
    stalls. This way the ULP can post more stuff and ordering is preserved.
  + It would then setup a callback for PHYS_MR NIC completion and
    return, having never slept.
  + The callback will unblock the SQ

Yes, this is complicated, but it shows how combing MR setup and post
together lets us do a lot more.

Sadly, we could probably never do this for older drivers due to them
being unmaintained, but it is certainly possible the core could
provide an older driver wrapper that emulates the above with less
efficiency using threads/queues/etc.

Jason
