Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42375 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965283Ab3GLU00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jul 2013 16:26:26 -0400
Date: Fri, 12 Jul 2013 16:26:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: walter harms <wharms@bfs.de>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch -stable] svcrdma: underflow issue in decode_write_list()
Message-ID: <20130712202620.GA10562@fieldses.org>
References: <20130712063903.GB29320@longonot.mountain>
 <51DFBD49.7000205@bfs.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51DFBD49.7000205@bfs.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 12, 2013 at 10:24:41AM +0200, walter harms wrote:
> 
> 
> Am 12.07.2013 08:39, schrieb Dan Carpenter:
> > My static checker marks everything from ntohl() as untrusted and it
> > complains we could have an underflow problem doing:
> > 
> > 	return (u32 *)&ary->wc_array[nchunks];
> > 
> > Also on 32 bit systems the upper bound check could overflow.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
> > index 8d2eddd..65b1462 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
> > @@ -98,6 +98,7 @@ void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *ch,
> >   */
> >  static u32 *decode_write_list(u32 *va, u32 *vaend)
> >  {
> > +	unsigned long start, end;
> >  	int nchunks;
> >  
> >  	struct rpcrdma_write_array *ary =
> > @@ -113,9 +114,12 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
> >  		return NULL;
> >  	}
> >  	nchunks = ntohl(ary->wc_nchunks);
> > -	if (((unsigned long)&ary->wc_array[0] +
> > -	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
> > -	    (unsigned long)vaend) {
> > +
> > +	start = (unsigned long)&ary->wc_array[0];
> > +	end = (unsigned long)vaend;
> > +	if (nchunks < 0 ||
> > +	    nchunks > (SIZE_MAX - start) / sizeof(struct rpcrdma_write_chunk) ||
> > +	    (start + (sizeof(struct rpcrdma_write_chunk) * nchunks)) > end) {
> >  		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
> >  			ary, nchunks, vaend);
> 
> 
> i am struggling to understand what is actually checked here.
> Perhaps this improves the readability a bit
>  if ( nchunks < 0 ||
>        sizeof(struct rpcrdma_write_chunk) * nchunks > (SIZE_MAX - start) ||
>        sizeof(struct rpcrdma_write_chunk) * nchunks > (end - start) )

If the product on the left-hand size overflows, the product could pass
all these tests while nchunks is still too large.  That's the same
problem the original code had.

Committing Dan's version unless someone has something better.

--b.

> 
>  with that rewrite i would say that (SIZE_MAX - start) is strange.
> 
> just my 2 cents,
>  wh
> 
> >  		return NULL;
> > @@ -129,6 +133,7 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
> >  
> >  static u32 *decode_reply_array(u32 *va, u32 *vaend)
> >  {
> > +	unsigned long start, end;
> >  	int nchunks;
> >  	struct rpcrdma_write_array *ary =
> >  		(struct rpcrdma_write_array *)va;
> > @@ -143,9 +148,12 @@ static u32 *decode_reply_array(u32 *va, u32 *vaend)
> >  		return NULL;
> >  	}
> >  	nchunks = ntohl(ary->wc_nchunks);
> > -	if (((unsigned long)&ary->wc_array[0] +
> > -	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
> > -	    (unsigned long)vaend) {
> > +
> > +	start = (unsigned long)&ary->wc_array[0];
> > +	end = (unsigned long)vaend;
> > +	if (nchunks < 0 ||
> > +	    nchunks > (SIZE_MAX - start) / sizeof(struct rpcrdma_write_chunk) ||
> > +	    (start + (sizeof(struct rpcrdma_write_chunk) * nchunks)) > end) {
> >  		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
> >  			ary, nchunks, vaend);
> >  		return NULL;
> > --
> > To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
