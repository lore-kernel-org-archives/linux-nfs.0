Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59833 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbaFGObe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:31:34 -0400
Date: Sat, 7 Jun 2014 07:31:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com
Subject: Re: [PATCH v2 2/2] nfsd: avoid taking the state_lock while holding
 the i_lock
Message-ID: <20140607143133.GA5072@infradead.org>
References: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
 <1402060026-26511-3-git-send-email-jlayton@primarydata.com>
 <20140607140904.GB18140@infradead.org>
 <20140607102826.59a4af24@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140607102826.59a4af24@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 07, 2014 at 10:28:26AM -0400, Jeff Layton wrote:
> Well, I think using the fp->fi_lock instead of the i_lock here is
> reasonable. We at least avoid taking the state_lock (which is likely to
> be much more contended) within the i_lock.

Yes, avoiding i_lock usage inside nfsd is something I'd prefer.  But
with the current lock manager ops that are called with i_lock held
we'll have some leakage into the nfsd lock hierachy anyway
unfortunately.

> The thing that makes this
> patch nasty is all of the shenanigans to queue the delegation to the
> global list from within rpc_prepare or rpc_release.
> 
> Personally, I think it'd be cleaner to add some sort of cb_prepare
> operation to the generic callback framework you're building to handle
> that, but let me know what you thing.

I guess I'll have to do it that way then.  It's not like so far
unreleased code should be a hard blocker for a bug fix anyway.

Care to prefer a version that uses fi_lock, but otherwise works like the
first version?

