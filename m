Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46408 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbbJLRNx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 13:13:53 -0400
Date: Mon, 12 Oct 2015 13:13:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Fix NFS server crash triggered by 1MB NFS WRITE
Message-ID: <20151012171352.GC28755@fieldses.org>
References: <20151012145257.3981.13852.stgit@oracle-120.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151012145257.3981.13852.stgit@oracle-120.nfsv4bat.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 10:53:39AM -0400, Chuck Lever wrote:
> Now that the NFS server advertises a maximum payload size of 1MB
> for RPC/RDMA again, it crashes in svc_process_common() when NFS
> client sends a 1MB NFS WRITE on an NFS/RDMA mount.
> 
> The server has set up a 259 element array of struct page pointers
> in rq_pages[] for each incoming request. The last element of the
> array is NULL.
> 
> When an incoming request has been completely received,
> rdma_read_complete() attempts to set the starting page of the
> incoming page vector:
> 
>   rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
> 
> and the page to use for the reply:
> 
>   rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> 
> But the value of page_no has already accounted for head->hdr_count.
> Thus rq_respages now points past the end of the incoming pages.
> 
> For NFS WRITE operations smaller than the maximum, this is harmless.
> But when the NFS WRITE operation is as large as the server's max
> payload size, rq_respages now points at the last entry in rq_pages,
> which is NULL.
> 
> Fixes: cc9a903d915c ('svcrdma: Change maximum server payload . . .')
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Reviewed-by: Sagi Grimberg <sagig@dev.mellanox.co.il>
> Reviewed-by: Steve Wise <swise@opengridcomputing.com>
> Reviewed-by: Shirley Ma <shirley.ma@oracle.com>
> ---
> 
> Hi Bruce-
> 
> This is a regression in 4.3. Can you send this to Linus?

OK, queuing for 4.3, thanks.--b.

> 
> 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index cb51742..37b4341 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -531,7 +531,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
>  	rqstp->rq_arg.page_base = head->arg.page_base;
>  
>  	/* rq_respages starts after the last arg page */
> -	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> +	rqstp->rq_respages = &rqstp->rq_pages[page_no];
>  	rqstp->rq_next_page = rqstp->rq_respages + 1;
>  
>  	/* Rebuild rq_arg head and tail. */
