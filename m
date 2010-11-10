Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:15679 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993Ab0KJVo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 16:44:26 -0500
Date: Wed, 10 Nov 2010 22:32:44 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-kernel@vger.kernel.org
cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] SUNRPC: Simplify rpc_alloc_iostats by removing pointless
 local variable
In-Reply-To: <alpine.LNX.2.00.1011072205370.26247@swampdragon.chaosbits.net>
Message-ID: <alpine.LNX.2.00.1011102229370.625@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1011072205370.26247@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 7 Nov 2010, Jesper Juhl wrote:

> Hi,
> 
> We can simplify net/sunrpc/stats.c::rpc_alloc_iostats() a bit by getting 
> rid of the unneeded local variable 'new'.
> 
> 
> Please CC me on replies.
> 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  stats.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git 
> a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index f71a731..80df89d 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -115,9 +115,7 @@ EXPORT_SYMBOL_GPL(svc_seq_show);
>   */
>  struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt)
>  {
> -	struct rpc_iostats *new;
> -	new = kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
> -	return new;
> +	return kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
>  }
>  EXPORT_SYMBOL_GPL(rpc_alloc_iostats);
>  
> 
> 

Ok, no response to this for a couple of days.
Is there some problem or did it just get missed?
Could someone merge this and push it up-stream, please, if there are no 
problems with it...
 

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

