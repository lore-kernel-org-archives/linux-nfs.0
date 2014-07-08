Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42503 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbaGHGqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 02:46:47 -0400
Date: Mon, 7 Jul 2014 23:46:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is there a good reason that nfs4_state_manager should use a
 work_queue?
Message-ID: <20140708064641.GA16497@infradead.org>
References: <20140708152100.67cd93c7@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140708152100.67cd93c7@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 03:21:00PM +1000, NeilBrown wrote:
>  2/ would it be reasonable to have a single work queue for all nfs clients?
>     In the worst case this could serialise reclaim across all clients so we
>     wouldn't want any reclaim attempt to block indefinitely.  Is that likely
>     to be a big problem do you think?

A workqueue isn't serialized, it has a max_active paramater to control
the concurrency of execution.

