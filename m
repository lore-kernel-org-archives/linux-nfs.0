Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52366 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747AbaEFQkK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 12:40:10 -0400
Date: Tue, 6 May 2014 12:40:09 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/70] NFSd: Remove 'inline' designation for free_client()
Message-ID: <20140506164009.GF18281@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:43:58PM -0400, Trond Myklebust wrote:
> It is large, it is used in more than one place, and it is not performance
> critical. Let gcc figure out whether it should be inlined...

Thanks, applying for 3.16.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 32b699bebb9c..841495aa9170 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1093,7 +1093,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>  	return clp;
>  }
>  
> -static inline void
> +static void
>  free_client(struct nfs4_client *clp)
>  {
>  	struct nfsd_net __maybe_unused *nn = net_generic(clp->net, nfsd_net_id);
> -- 
> 1.9.0
> 
