Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794624135;
	b=yxYDiWgN5Z8HAAa9bkNajPR6BdbUa9TlMiHsS9ZwwR/QqX7YltYRy73F8zSfcaAN5nML
	 Wl4MU7yHPDSfEZe8APQzo2Kxzzar7Ig6peiO7olGjvdddyih3NYTcG8L+TNH4gpL9l+zs
	 +z6NSFE6llqvAF4BSQI1RATPYVDq+mztvCJyLwDDtj6nePkZq66kqC0Rg+93M3mEIp/77
	 wbX4gQbQOwuMdFPXGPu/ZtQkO+V/O5p4ihz2hHR1O/AmVCPYsza5RuSWmekYDSCwlMwnH
	 gAU5Q5MGnbaDOLFUIYCq+vP0S+CHzJTfPyAjh/tZ9iFnWBl5ETSgpHwwtoQ2EK1oGEw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794624135;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=c1BEVFgc+FgNlcOQuSnL/m7aKj3paVuo6y8ooEnQo5Q=;
	b=lqHnuoPrCBM8VwVonIM80uRpwd7rm1yN8c4rnFKWXg8jHYO2pmuqrXs83I+Z/9quTs4A
	 fIuwQP2ohjKCicS8phpvxl+OI46f3LaCLLt7lildmKGFrcwiwqH6BBx0/GhG08/KsjC47
	 BNhnNuhluf0Tlx9oBgX6GfwGAcjAwrqmu/xp6r656lWHsfqVb/4DPIfxvUYSmzdyqYkiS
	 QgJf35iE6L34ALg3rSVNdIYu6NhU2cwBHQ7MGcYx0qv0nE8Z7Td3M0JlouyNAToCoKh12
	 CraT65FtOHNb8rkTKRV5rk6DHYVfkFBfClPYEBElQwfklSyKGkt34IrZZY12wmJkZ5w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bFgem9fs;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8454606A323
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 02:42:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bFgem9fs
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2DB551F000C4;
	Sat, 14 Nov 2026 02:42:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794624135;
	bh=c1BEVFgc+FgNlcOQuSnL/m7aKj3paVuo6y8ooEnQo5Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=bFgem9fsScqbAkLz4eF7H6BpZ5GtwH75RhIEuD0E32MLiEOR7YeHtcR+oiS7atEIb
	 o5nvveTXa43g7UoiXXWevSj3nDxueYVeJF8443AoG9PO2SyyXYdG3BUh4YnlAVktjg
	 T7ZQ7kfwt1303zOTVVgiIGBS8GJnSQYfOm7TyVS7l4/XGrM/4D5f2Gtw2Rqz8qwW+u
	 urA9mIzY6DVbRuM4s1tiOljG4wz5ehYPgItVqJ/eipXEs1bzcZi6y5srV8kMhz2nJs
	 wG6P1dBJzbaT/1tpTx6qx6zy636o7pTTYYrnNa0belkqkvuCNT/g+0FhAaYyX5JiCa
	 PUDV3juspEoTQ==
Date: Fri, 13 Nov 2026 21:42:14 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] SUNRPC: Splice a request's pages into the TCP socket
Message-ID: <avfKhr21mjJVNFR7@kernel.org>
References: <20261113001611.90519-1-snitzer@kernel.org>
 <20261113001611.90519-3-snitzer@kernel.org>
 <ea496fb4-06a8-4ac4-a174-8c2d612704ca@app.fastmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea496fb4-06a8-4ac4-a174-8c2d612704ca@app.fastmail.com>

On Fri, Nov 13, 2026 at 04:26:06PM -0500, Anna Schumaker wrote:
> Hi Mike,
> 
> On Thu, Nov 12, 2026, at 7:16 PM, Mike Snitzer wrote:
> > xprt_sock_sendmsg() sends a request's page array to the socket as a
> > bvec, and tcp_sendmsg_locked() copies every byte of it into the
> > socket's skbs under the socket lock.  For an NFS WRITE that is the
> > whole payload, copied by rpciod one request at a time a transport: at
> > 1 MiB a WRITE it comes to about 3 GB/s a connection, and on a client
> > with 24 connections to a server whose storage takes more, it is the
> > ceiling of the rate, with 18% of the client's 48 CPUs in memcpy under
> > tcp_sendmsg_locked().
> >
> > Until commit 0472e4766049 ("SUNRPC: Convert socket page send code to
> > use iov_iter()") the client sent the pages with kernel_sendpage(), so
> > the socket held them and copied nothing.  Send them with
> > MSG_SPLICE_PAGES, as the server's svc_tcp_sendmsg() has since
> > commit 5df5dd03a8f7 ("sunrpc: Use sendmsg(MSG_SPLICE_PAGES) rather then
> > sendpage"), and the socket holds them again.  Only the page array is
> > spliced: the head and the tail are kvecs over the request's buffer,
> > memory the socket may not hold a reference to, and are copied as
> > before.
> >
> > A request's pages are the caller's until the reply, and TCP delivers
> > them before the server can reply, so a first transmission is safe to
> > splice.  A retransmission is not: the reply to the first transmission
> > may complete the call and release the pages to be rewritten while the
> > socket still holds them for the second, the corruption that
> > commit a6b31d18b02f ("SUNRPC: Fix a data corruption issue when
> > retransmitting RPC calls") found with kernel_sendpage().  So a
> > retransmission is copied, as it was then, and only the TCP transport
> > asks for the splice: UDP and AF_LOCAL copy as before.
> >
> > Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> > ---
> >  net/sunrpc/socklib.c  | 26 ++++++++++++++++++++++----
> >  net/sunrpc/xprtsock.c |  9 +++++++++
> >  2 files changed, 31 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
> > index d8d8842c7de5c..ba18387f8ed6d 100644
> > --- a/net/sunrpc/socklib.c
> > +++ b/net/sunrpc/socklib.c
> > @@ -173,11 +173,17 @@ static int xprt_send_kvec(struct socket *sock, 
> > struct msghdr *msg,
> >  }
> > 
> >  static int xprt_send_pagedata(struct socket *sock, struct msghdr *msg,
> > -			      struct xdr_buf *xdr, size_t base)
> > +			      struct xdr_buf *xdr, size_t base,
> > +			      unsigned int splice)
> >  {
> > +	int ret;
> > +
> >  	iov_iter_bvec(&msg->msg_iter, ITER_SOURCE, xdr->bvec, xdr_buf_pagecount(xdr),
> >  		      xdr->page_len + xdr->page_base);
> > -	return xprt_sendmsg(sock, msg, base + xdr->page_base);
> > +	msg->msg_flags |= splice;
> > +	ret = xprt_sendmsg(sock, msg, base + xdr->page_base);
> > +	msg->msg_flags &= ~MSG_SPLICE_PAGES;
> > +	return ret;
> >  }
> > 
> >  /* Common case:
> > @@ -207,6 +213,12 @@ static int xprt_send_rm_and_kvec(struct socket 
> > *sock, struct msghdr *msg,
> >   * @sock: open socket to send on
> >   * @msg: socket message metadata
> >   * @xdr: xdr_buf containing this request
> > + *
> > + * With %MSG_SPLICE_PAGES set in @msg->msg_flags, the pages of @xdr are
> > + * spliced into the socket rather than copied, and the caller must 
> > leave
> > + * them unchanged until the socket has sent them.  The head and the 
> > tail
> > + * are always copied.
> > + *
> 
> What an odd place to put this comment. I honestly don't think it's needed,
> however. 
> 
> >   * @base: starting position in the buffer
> >   * @marker: stream record marker field
> >   * @sent_p: return the total number of bytes successfully queued for 
> > sending
> > @@ -221,6 +233,7 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> > msghdr *msg,
> >  {
> >  	unsigned int rmsize = marker ? sizeof(marker) : 0;
> >  	unsigned int remainder = rmsize + xdr->len - base;
> > +	unsigned int splice = msg->msg_flags & MSG_SPLICE_PAGES;
> >  	unsigned int want;
> >  	int err = 0;
> > 
> > @@ -229,6 +242,10 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> > msghdr *msg,
> >  	if (unlikely(!sock))
> >  		return -ENOTSOCK;
> > 
> > +	/* The head and tail are kvecs over memory the socket may not
> > +	 * hold a reference to, so only the page array is spliced.
> > +	 */
> 
> Same here. Code should be self-documenting enough that comments should
> be saved to explain tricky decisions and not describe basic behavior.
> 
> > +	msg->msg_flags &= ~MSG_SPLICE_PAGES;
> >  	msg->msg_flags |= MSG_MORE;
> >  	want = xdr->head[0].iov_len + rmsize;
> >  	if (base < want) {
> > @@ -256,7 +273,7 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> > msghdr *msg,
> >  		remainder -= len;
> >  		if (remainder == 0)
> >  			msg->msg_flags &= ~MSG_MORE;
> > -		err = xprt_send_pagedata(sock, msg, xdr, base);
> > +		err = xprt_send_pagedata(sock, msg, xdr, base, splice);
> >  		if (remainder == 0 || err != len)
> >  			goto out;
> >  		*sent_p += err;
> > @@ -266,10 +283,11 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> > msghdr *msg,
> >  	}
> > 
> >  	if (base >= xdr->tail[0].iov_len)
> > -		return 0;
> > +		goto out;
> >  	msg->msg_flags &= ~MSG_MORE;
> >  	err = xprt_send_kvec(sock, msg, &xdr->tail[0], base);
> >  out:
> > +	msg->msg_flags |= splice;
> >  	if (err > 0) {
> >  		*sent_p += err;
> >  		err = 0;
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 173e3b0fd7a3b..2a077cddcc8ad 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1136,6 +1136,15 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
> > 
> >  	xs_set_srcport(transport, transport->sock);
> > 
> > +	/* Splice the pages of a first transmission into the socket: TCP
> > +	 * delivers them before the server can reply, and the reply is
> 
> Does "TCP delivers them before the server can reply" really need to be stated?
> 
> Anyway, what do you think is the right path forward for this? Chuck's patches
> seem to replace your 1/2, so should I just put this one on top of those?

Chuck's replacement for my 1/2 is basically identical, so yes that's
fine.

Sorry for the excessive (and weirdly placed) comments.  Feel free to
nuke them, or I can clean them up and send v2.

Mike
