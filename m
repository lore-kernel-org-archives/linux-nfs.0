Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx01-sz.bfs.de ([194.94.69.67]:33770 "EHLO mx01-sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757283Ab3GLIb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jul 2013 04:31:26 -0400
Message-ID: <51DFBD49.7000205@bfs.de>
Date: Fri, 12 Jul 2013 10:24:41 +0200
From: walter harms <wharms@bfs.de>
Reply-To: wharms@bfs.de
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch -stable] svcrdma: underflow issue in decode_write_list()
References: <20130712063903.GB29320@longonot.mountain>
In-Reply-To: <20130712063903.GB29320@longonot.mountain>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Am 12.07.2013 08:39, schrieb Dan Carpenter:
> My static checker marks everything from ntohl() as untrusted and it
> complains we could have an underflow problem doing:
> 
> 	return (u32 *)&ary->wc_array[nchunks];
> 
> Also on 32 bit systems the upper bound check could overflow.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
> index 8d2eddd..65b1462 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
> @@ -98,6 +98,7 @@ void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *ch,
>   */
>  static u32 *decode_write_list(u32 *va, u32 *vaend)
>  {
> +	unsigned long start, end;
>  	int nchunks;
>  
>  	struct rpcrdma_write_array *ary =
> @@ -113,9 +114,12 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
>  		return NULL;
>  	}
>  	nchunks = ntohl(ary->wc_nchunks);
> -	if (((unsigned long)&ary->wc_array[0] +
> -	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
> -	    (unsigned long)vaend) {
> +
> +	start = (unsigned long)&ary->wc_array[0];
> +	end = (unsigned long)vaend;
> +	if (nchunks < 0 ||
> +	    nchunks > (SIZE_MAX - start) / sizeof(struct rpcrdma_write_chunk) ||
> +	    (start + (sizeof(struct rpcrdma_write_chunk) * nchunks)) > end) {
>  		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
>  			ary, nchunks, vaend);


i am struggling to understand what is actually checked here.
Perhaps this improves the readability a bit
 if ( nchunks < 0 ||
       sizeof(struct rpcrdma_write_chunk) * nchunks > (SIZE_MAX - start) ||
       sizeof(struct rpcrdma_write_chunk) * nchunks > (end - start) )

 with that rewrite i would say that (SIZE_MAX - start) is strange.

just my 2 cents,
 wh

>  		return NULL;
> @@ -129,6 +133,7 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
>  
>  static u32 *decode_reply_array(u32 *va, u32 *vaend)
>  {
> +	unsigned long start, end;
>  	int nchunks;
>  	struct rpcrdma_write_array *ary =
>  		(struct rpcrdma_write_array *)va;
> @@ -143,9 +148,12 @@ static u32 *decode_reply_array(u32 *va, u32 *vaend)
>  		return NULL;
>  	}
>  	nchunks = ntohl(ary->wc_nchunks);
> -	if (((unsigned long)&ary->wc_array[0] +
> -	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
> -	    (unsigned long)vaend) {
> +
> +	start = (unsigned long)&ary->wc_array[0];
> +	end = (unsigned long)vaend;
> +	if (nchunks < 0 ||
> +	    nchunks > (SIZE_MAX - start) / sizeof(struct rpcrdma_write_chunk) ||
> +	    (start + (sizeof(struct rpcrdma_write_chunk) * nchunks)) > end) {
>  		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
>  			ary, nchunks, vaend);
>  		return NULL;
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
