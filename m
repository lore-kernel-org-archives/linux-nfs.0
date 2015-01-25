Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:19987 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbbAYULG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Jan 2015 15:11:06 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 2/2] SUNRPC: Allow waiting on memory allocation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1422145127-81838-2-git-send-email-trond.myklebust@primarydata.com>
Date: Sun, 25 Jan 2015 15:11:02 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1282FA7B-EE04-4EDE-A659-0697490CB9ED@oracle.com>
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com> <1422145127-81838-2-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 24, 2015, at 7:18 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> We should be safe now, as long as we don't do GFP_IO or higher allocations

Should the GFP flags in xprt_rdma_allocate() reflect this change
as well? The non-swap case uses GFP_NOFS currently, and the
swap case does not include GFP_MEMALLOC. These choices might be
out of date.

If so I can submit a patch on top of my existing for-3.20 series
that changes xprt_rdma_allocate() to use the same flags as
rpc_malloc().


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> net/sunrpc/sched.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 4f65ec28d2b4..b91fd9c597b4 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -844,10 +844,10 @@ static void rpc_async_schedule(struct work_struct *work)
> void *rpc_malloc(struct rpc_task *task, size_t size)
> {
> 	struct rpc_buffer *buf;
> -	gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
> +	gfp_t gfp = GFP_NOIO | __GFP_NOWARN;
> 
> 	if (RPC_IS_SWAPPER(task))
> -		gfp |= __GFP_MEMALLOC;
> +		gfp = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
> 
> 	size += sizeof(struct rpc_buffer);
> 	if (size <= RPC_BUFFER_MAXSIZE)
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



