Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57835 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaG0NXG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:23:06 -0400
Date: Sun, 27 Jul 2014 06:23:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 02/40] nfsd: Add reference counting to the lock and open
 stateids
Message-ID: <20140727132305.GD32153@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 11:02:14AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> When we remove the client_mutex, we'll need to be able to ensure that
> these objects aren't destroyed while we're not holding locks.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3e55df0d7504..76d28be3ef41 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -883,8 +883,10 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
>  	release_all_access(stp);
>  }
>  
> -static void free_generic_stateid(struct nfs4_ol_stateid *stp)
> +static void put_generic_stateid(struct nfs4_ol_stateid *stp)

Can you please call this put_ol_stateid while you're at it?  And throw
in a patch to rename the other two generic_stateid names when you touch
them or at the end of the series?

Otherwise looks good to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>
