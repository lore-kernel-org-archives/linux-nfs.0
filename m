From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Wed, 05 Dec 2007 22:50:25 -0600
Message-ID: <1196916625.25528.43.camel@trinity.ogc.int>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: James Lentini <jlentini@netapp.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:52969 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751628AbXLFEpv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2007 23:45:51 -0500
In-Reply-To: <1196902607.17724.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Wed, 2007-12-05 at 19:56 -0500, Trond Myklebust wrote:
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

xdr->len is 0

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

xdr->len notwithstanding, for the purpose of this code, the pos
manipulation isn't necessary because the condition being checked (no
tail) can be trivially determined just by looking at tail[0].iov_len.

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

