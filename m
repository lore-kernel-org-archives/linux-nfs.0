Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53200 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbbGNPgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 11:36:24 -0400
Date: Tue, 14 Jul 2015 08:36:19 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>, "'Christoph Hellwig'" <hch@infradead.org>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714153619.GC11026@infradead.org>
References: <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org>
 <55A4134C.2040301@talpey.com>
 <20150713201538.GA11681@obsidianresearch.com>
 <55A4D20C.2000904@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A4D20C.2000904@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 12:10:36PM +0300, Sagi Grimberg wrote:
> Having an API that does FRMR/FMR/PHYS_MR is even worse from the ULP
> PoV. If you expose an API that might schedule (PHYS_MR) it limits the
> context that the caller is allowed to call in.
> 
> I'm 100% against an registration API that *might* schedule.

Oh, I had missed that PHYS_MR might sleep.  That might be the reasons
why everyone is avoiding them despite Tom preferring them over FMR.

