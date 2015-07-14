Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:43703 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781AbbGNVOM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 17:14:12 -0400
Date: Tue, 14 Jul 2015 15:14:00 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714211400.GA21502@obsidianresearch.com>
References: <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714194512.GA25887@infradead.org>
 <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com>
 <20150714204145.GC26927@obsidianresearch.com>
 <010c01d0be76$dbb4c520$931e4f60$@opengridcomputing.com>
 <011001d0be78$32412ef0$96c38cd0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <011001d0be78$32412ef0$96c38cd0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 04:01:04PM -0500, Steve Wise wrote:

> > Right, a local_dma_lkey is not an rkey, and iwarp requires the
> > rkey for the read destination MR.  Further that rkey needs
> > REMOTE_WRITE.
> 
> BTW: What use is an IB rkey with no REMOTE_ flags set?  Can it be
> used somehow differently than the associated lkey?

Don't think so. Sagi?

This looks like it is just an artifact of the sloppy API that treats a
rkey MR and lkey MR as the same thing - they are clearly not, and we
should start talking about APIs that return lkeys or rkeys, never both
(and enforcing that lkey and rkey MRS have the right ACCESS flags).

Having looked at this for a bit now, I am of the view that it is very
hard to use a MR as both rkey and lkey without creating some kind of
security problem. At least every place in current ULPs that does this
is a security problem :) So the API should prevent it, IMHO.

local_dma_lkey is an excellent step, and if Sagi's MR unification
patch is careful to have a lkey/rkey API entry point for the two
usages we can maybe nuke this problem for good...

Jason
