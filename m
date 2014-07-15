Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38524 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbaGORPt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:15:49 -0400
Date: Tue, 15 Jul 2014 10:15:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 2/7] nfsd: Ensure stateids remain unique until they are
 freed
Message-ID: <20140715171547.GA5269@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
 <1405420669-4030-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405420669-4030-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:37:44AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Add an extra delegation state to allow the stateid to remain in the idr
> tree until the last reference has been released. This will be necessary
> to ensure uniqueness once the client_mutex is removed.
> 
> [jlayton: reset the sc_type under the state_lock in unhash_delegation]
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 9 ++++-----
>  fs/nfsd/state.h     | 1 +
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1b01a20827ab..df3e9ef1fb38 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -609,6 +609,7 @@ static void remove_stid(struct nfs4_stid *s)
>  
>  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>  {
> +	remove_stid(s);
>  	kmem_cache_free(slab, s);
>  }

Might make sense to just keep it in the caller.  In your big series
remove_stid_locked ends up there again anyway, and it avoids some churn
in this series that made me investiage how you keep open and lock
stateids hashed longer in this patch (you don't of course..).

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
