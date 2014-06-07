Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59566 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbaFGOJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:09:05 -0400
Date: Sat, 7 Jun 2014 07:09:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, hch@infradead.org
Subject: Re: [PATCH v2 2/2] nfsd: avoid taking the state_lock while holding
 the i_lock
Message-ID: <20140607140904.GB18140@infradead.org>
References: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
 <1402060026-26511-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1402060026-26511-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 06, 2014 at 09:07:06AM -0400, Jeff Layton wrote:
> state_lock is a heavily contended global lock. We don't want to grab
> that while simultaneously holding the inode->i_lock. Avoid doing that in
> the delegation break callback by ensuring that we add/remove the
> dl_perfile under a new per-nfs4_file fi_lock, and hold that while walking
> the fi_delegations list.
> 
> We still do need to queue the delegations to the global del_recall_lru
> list. Do that in the rpc_prepare op for the delegation recall RPC. It's
> possible though that the allocation of the rpc_task will fail, which
> would cause the delegation to be leaked.
> 
> If that occurs rpc_release is still called, so we also do it there if
> the rpc_task failed to run. This brings up another dilemma -- how do
> we know whether it got queued in rpc_prepare or not?
> 
> In order to determine that, we set the dl_time to 0 in the delegation
> break callback from the VFS and only set it when we queue it to the
> list. If it's still zero by the time we get to rpc_release, then we know
> that it never got queued and we can do it then.

Compared to this version I have to say the original one that I objected
to looks like the lesser evil.  I'll take another deeper look at it.

