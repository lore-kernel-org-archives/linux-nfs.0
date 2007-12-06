From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Thu, 6 Dec 2007 13:20:00 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
 <1196902607.17724.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13047 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbXLFSUL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2007 13:20:11 -0500
In-Reply-To: <1196902607.17724.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Wed, 5 Dec 2007, Trond Myklebust wrote:

> 
> On Thu, 2007-11-29 at 15:46 -0500, James Lentini wrote:
> > In some instances, the code in rpcrdma_convert_iovs was failing to 
> > include a chunk for the xdr tail. This was caused by defensive code 
> > that checked if the current xdr pos was greater than the total xdr 
> > length before encoding the tail. However, the xdr->len is 0 for 
> > non-write operations, and therefore this check was invalid for such 
> > operations.
> 
> Huh? xdr->page_len is 0 for non-write operations, but xdr->len had 
> better not be 0...

We are talking about different xdr bufs. I'm refering to the xdr rcv 
buf.

For an NFS read request, RPC/RDMA's rpcrdma_convert_iovs() will create 
a request header with pointers to the xdr recv buf into which the 
response should be placed (depending on the NFS operation, 
rpcrdma_convert_iovs() can be passed either the rpc_rqst's snd or rcv 
xdr_buf).

Using an NFSv3 read as an example, nfs3_xdr_readargs() will initialize 
the rpc_rqst's snd xdr_buf len value with the return of 
xdr_adjust_iovec(). However, xdr_inline_pages()'s initialization of 
the rpc_rqst's rcv xdr_buf does not set len.

In this case, a len of 0 for the rpc_rqst's rcv xdr_buf appears to be 
correct to me. The comment describing the field states len is the 
"Length of XDR encoded message"; 0 seems like a reasonable value for 
this field before the request is sent.

> > With this change, the tail will always be marshaled when present. This 
> > makes the maintenance of the pos index unnecessary. The test of 
> > xdrbuf->len to decide if a message should be logged is also incorrect.
> > 
> > This fixes an observed problem when reading certain file sizes over 
> > NFS/RDMA. Please consider this for 2.6.24.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > Signed-off-by: Tom Talpey <talpey@netapp.com>
> > Signed-off-by: James Lentini <jlentini@netapp.com>
> > 
> > ---
> >  net/sunrpc/xprtrdma/rpc_rdma.c |    9 +--------
> >  1 file changed, 1 insertion(+), 8 deletions(-)
> > 
> > --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> > +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> > @@ -92,7 +92,6 @@
> >  		seg[n].mr_page = NULL;
> >  		seg[n].mr_offset = xdrbuf->head[0].iov_base;
> >  		seg[n].mr_len = xdrbuf->head[0].iov_len;
> > -		pos += xdrbuf->head[0].iov_len;
> >  		++n;
> >  	}
> >  
> > @@ -104,7 +103,6 @@
> >  		seg[n].mr_len = min_t(u32,
> >  			PAGE_SIZE - xdrbuf->page_base, xdrbuf->page_len);
> >  		len = xdrbuf->page_len - seg[n].mr_len;
> > -		pos += len;
> 
> Alternatively, just a single line fix should fix the bug AFAICS:
> -		pos += len;
> +		pos += xdrbuf->page_len

Since we are marshaling the rcv buf, the "pos < xdrbuf->len" test 
would fail.

>
> >  		++n;
> >  		p = 1;
> >  		while (len > 0) {
> > @@ -119,20 +117,15 @@
> >  		}
> >  	}
> >  
> > -	if (pos < xdrbuf->len && xdrbuf->tail[0].iov_len) {
> > +	if (xdrbuf->tail[0].iov_len) {
> >  		if (n == nsegs)
> >  			return 0;
> >  		seg[n].mr_page = NULL;
> >  		seg[n].mr_offset = xdrbuf->tail[0].iov_base;
> >  		seg[n].mr_len = xdrbuf->tail[0].iov_len;
> > -		pos += xdrbuf->tail[0].iov_len;
> >  		++n;
> >  	}
> >  
> > -	if (pos < xdrbuf->len)
> > -		dprintk("RPC:       %s: marshaled only %d of %d\n",
> > -				__func__, pos, xdrbuf->len);
> > -
> >  	return n;
> >  }
> >  
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
