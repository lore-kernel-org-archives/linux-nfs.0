From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Thu, 06 Dec 2007 14:29:52 -0500
Message-ID: <1196969392.7990.9.camel@localhost.localdomain>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
	 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:59773 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbXLFT37 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2007 14:29:59 -0500
In-Reply-To: <Pine.LNX.4.64.0712061255200.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-06 at 13:20 -0500, James Lentini wrote:
> 
> On Wed, 5 Dec 2007, Trond Myklebust wrote:
> 
> > 
> > On Thu, 2007-11-29 at 15:46 -0500, James Lentini wrote:
> > > In some instances, the code in rpcrdma_convert_iovs was failing to 
> > > include a chunk for the xdr tail. This was caused by defensive code 
> > > that checked if the current xdr pos was greater than the total xdr 
> > > length before encoding the tail. However, the xdr->len is 0 for 
> > > non-write operations, and therefore this check was invalid for such 
> > > operations.
> > 
> > Huh? xdr->page_len is 0 for non-write operations, but xdr->len had 
> > better not be 0...
> 
> We are talking about different xdr bufs. I'm refering to the xdr rcv 
> buf.
> 
> For an NFS read request, RPC/RDMA's rpcrdma_convert_iovs() will create 
> a request header with pointers to the xdr recv buf into which the 
> response should be placed (depending on the NFS operation, 
> rpcrdma_convert_iovs() can be passed either the rpc_rqst's snd or rcv 
> xdr_buf).
> 
> Using an NFSv3 read as an example, nfs3_xdr_readargs() will initialize 
> the rpc_rqst's snd xdr_buf len value with the return of 
> xdr_adjust_iovec(). However, xdr_inline_pages()'s initialization of 
> the rpc_rqst's rcv xdr_buf does not set len.
> 
> In this case, a len of 0 for the rpc_rqst's rcv xdr_buf appears to be 
> correct to me. The comment describing the field states len is the 
> "Length of XDR encoded message"; 0 seems like a reasonable value for 
> this field before the request is sent.

Eeewwww.... What an unholy mess!

Why are you trying to shoehorn reading and writing into
rpcrdma_create_chunks()? The way every action is split into 'if (read)
{} else {}' should be an obvious hint that none of this belongs
together. Please split this up for 2.6.25.

So yes, for read buffers, you should be looking at the storage buffer
length (xdr_buf->buflen) since the message length is obviously going to
be zero.

Trond

