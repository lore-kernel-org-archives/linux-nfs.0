Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834Ab1CPPMH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 11:12:07 -0400
Date: Wed, 16 Mar 2011 11:12:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: make sure nfs server return right
 ca_maxresponsesize_cached
Message-ID: <20110316151205.GA9299@fieldses.org>
References: <4D789D49.7090407@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D789D49.7090407@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 10, 2011 at 05:43:37PM +0800, Mi Jinlong wrote:
> According to rfc5661, 
>   
>   ca_maxresponsesize_cached:
> 
>      Like ca_maxresponsesize, but the maximum size of a reply that
>      will be stored in the reply cache (Section 2.10.6.1).  For each
>      channel, the server MAY decrease this value, but MUST NOT
>      increase it.

I wonder what the reason for that is--I can't see why the client would
object to the server increasing this.  Oh well, my as well observe the
MUST NOT; applied.

--b.

>  
> the latest kernel(2.6.38-rc8) may increase the value for ignoring 
> request's ca_maxresponsesize_cached value. We should not ignore it.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 54b60bf..96edd02 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -608,7 +608,8 @@ static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4
>  	u32 maxrpc = nfsd_serv->sv_max_mesg;
>  
>  	new->maxreqs = numslots;
> -	new->maxresp_cached = slotsize + NFSD_MIN_HDR_SEQ_SZ;
> +	new->maxresp_cached = min_t(u32, req->maxresp_cached, 
> +					slotsize + NFSD_MIN_HDR_SEQ_SZ);
>  	new->maxreq_sz = min_t(u32, req->maxreq_sz, maxrpc);
>  	new->maxresp_sz = min_t(u32, req->maxresp_sz, maxrpc);
>  	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
> -- 
> 1.7.4.1
> 
> 
> 
