Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39030 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910Ab0JRVPk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 17:15:40 -0400
Date: Mon, 18 Oct 2010 17:15:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Pavel Emelyanov <xemul@parallels.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 9/13] sunrpc: Merge the xs_bind code
Message-ID: <20101018211537.GC4740@fieldses.org>
References: <4CA9CDA8.4010407@parallels.com>
 <4CA9CEE8.9050404@parallels.com>
 <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com>
 <4CAABAAB.8040608@parallels.com>
 <4CAB11A4.7000306@parallels.com>
 <20101015160545.GB12268@fieldses.org>
 <9D130D08-1FD3-4088-AB43-8CEFFE6476B3@oracle.com>
 <20101015180852.GC18869@fieldses.org>
 <068F3C9A-2930-46F7-AC15-EB71ADA1933F@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <068F3C9A-2930-46F7-AC15-EB71ADA1933F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 15, 2010 at 02:11:29PM -0400, Chuck Lever wrote:
> 
> On Oct 15, 2010, at 2:08 PM, J. Bruce Fields wrote:
> 
> > On Fri, Oct 15, 2010 at 12:39:36PM -0400, Chuck Lever wrote:
> >> 
> >> On Oct 15, 2010, at 12:05 PM, J. Bruce Fields wrote:
> >> 
> >>> On Tue, Oct 05, 2010 at 03:53:08PM +0400, Pavel Emelyanov wrote:
> >>>> There's the only difference betseen the xs_bind4 and the
> >>>> xs_bind6 - the size of sockaddr structure they use.
> >>>> 
> >>>> Fortunatelly its size can be indirectly get from the transport.
> >>>> 
> >>>> Change since v1:
> >>>> * use sockaddr_storage instead of sockaddr
> >>>> * use rpc_set_port instead of manual port assigning
> >>> 
> >>> Whoops, dropping this; it breaks nfsd startup.  I haven't figured out
> >>> why yet, but I get
> >>> 
> >>> RPC: server localhost requires stronger authentication.
> >>> svc: failed to register nfsdv2 RPC service (errno 13).
> >> 
> >> Capturing a network trace of lo during server initialization should reveal all.  Compare a trace from a working run and a non-working one.
> > 
> > Hm.  One difference is the source port of the portmap calls: 33471 in
> > the bad case, 1016 in the bad.--b.
> 
> 1016 in the good... yes, that's because the server's registration upcall needs a privileged port, and xs_bind is not obliging here.  That certainly would result in a "requires stronger authentication" error from rpcbind.

So, adding some printk's: the problem is that the patch assumes that the
trasnport->xprt.addrlen and transport->srcaddr.ss_family have been
initialized at this point.  But they haven't been.  I don't know where
that's supposed to happen.

--b.

> 
> > 
> >> 
> >>> 
> >>> --b.
> >>> 
> >>>> 
> >>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >>>> ---
> >>>> net/sunrpc/xprtsock.c |   64 +++++++++++++------------------------------------
> >>>> 1 files changed, 17 insertions(+), 47 deletions(-)
> >>>> 
> >>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> >>>> index 7fdf2bb..bab808f 100644
> >>>> --- a/net/sunrpc/xprtsock.c
> >>>> +++ b/net/sunrpc/xprtsock.c
> >>>> @@ -1534,23 +1534,18 @@ static unsigned short xs_next_srcport(struct sock_xprt *transport, unsigned shor
> >>>> 		return xprt_max_resvport;
> >>>> 	return --port;
> >>>> }
> >>>> -
> >>>> -static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
> >>>> +static int xs_bind(struct sock_xprt *transport, struct socket *sock)
> >>>> {
> >>>> -	struct sockaddr_in myaddr = {
> >>>> -		.sin_family = AF_INET,
> >>>> -	};
> >>>> -	struct sockaddr_in *sa;
> >>>> +	struct sockaddr_storage myaddr;
> >>>> 	int err, nloop = 0;
> >>>> 	unsigned short port = xs_get_srcport(transport);
> >>>> 	unsigned short last;
> >>>> 
> >>>> -	sa = (struct sockaddr_in *)&transport->srcaddr;
> >>>> -	myaddr.sin_addr = sa->sin_addr;
> >>>> +	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
> >>>> 	do {
> >>>> -		myaddr.sin_port = htons(port);
> >>>> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
> >>>> -						sizeof(myaddr));
> >>>> +		rpc_set_port((struct sockaddr *)&myaddr, port);
> >>>> +		err = kernel_bind(sock, (struct sockaddr *)&myaddr,
> >>>> +				transport->xprt.addrlen);
> >>>> 		if (port == 0)
> >>>> 			break;
> >>>> 		if (err == 0) {
> >>>> @@ -1562,44 +1557,19 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
> >>>> 		if (port > last)
> >>>> 			nloop++;
> >>>> 	} while (err == -EADDRINUSE && nloop != 2);
> >>>> -	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
> >>>> -			__func__, &myaddr.sin_addr,
> >>>> -			port, err ? "failed" : "ok", err);
> >>>> -	return err;
> >>>> -}
> >>>> -
> >>>> -static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
> >>>> -{
> >>>> -	struct sockaddr_in6 myaddr = {
> >>>> -		.sin6_family = AF_INET6,
> >>>> -	};
> >>>> -	struct sockaddr_in6 *sa;
> >>>> -	int err, nloop = 0;
> >>>> -	unsigned short port = xs_get_srcport(transport);
> >>>> -	unsigned short last;
> >>>> 
> >>>> -	sa = (struct sockaddr_in6 *)&transport->srcaddr;
> >>>> -	myaddr.sin6_addr = sa->sin6_addr;
> >>>> -	do {
> >>>> -		myaddr.sin6_port = htons(port);
> >>>> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
> >>>> -						sizeof(myaddr));
> >>>> -		if (port == 0)
> >>>> -			break;
> >>>> -		if (err == 0) {
> >>>> -			transport->srcport = port;
> >>>> -			break;
> >>>> -		}
> >>>> -		last = port;
> >>>> -		port = xs_next_srcport(transport, port);
> >>>> -		if (port > last)
> >>>> -			nloop++;
> >>>> -	} while (err == -EADDRINUSE && nloop != 2);
> >>>> -	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
> >>>> -		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
> >>>> +	if (myaddr.ss_family == PF_INET)
> >>>> +		dprintk("RPC:       %s %pI4:%u: %s (%d)\n", __func__,
> >>>> +				&((struct sockaddr_in *)&myaddr)->sin_addr,
> >>>> +				port, err ? "failed" : "ok", err);
> >>>> +	else
> >>>> +		dprintk("RPC:       %s %pI6:%u: %s (%d)\n", __func__,
> >>>> +				&((struct sockaddr_in6 *)&myaddr)->sin6_addr,
> >>>> +				port, err ? "failed" : "ok", err);
> >>>> 	return err;
> >>>> }
> >>>> 
> >>>> +
> >>>> #ifdef CONFIG_DEBUG_LOCK_ALLOC
> >>>> static struct lock_class_key xs_key[2];
> >>>> static struct lock_class_key xs_slock_key[2];
> >>>> @@ -1645,7 +1615,7 @@ static struct socket *xs_create_sock4(struct rpc_xprt *xprt,
> >>>> 	}
> >>>> 	xs_reclassify_socket4(sock);
> >>>> 
> >>>> -	if (xs_bind4(transport, sock)) {
> >>>> +	if (xs_bind(transport, sock)) {
> >>>> 		sock_release(sock);
> >>>> 		goto out;
> >>>> 	}
> >>>> @@ -1669,7 +1639,7 @@ static struct socket *xs_create_sock6(struct rpc_xprt *xprt,
> >>>> 	}
> >>>> 	xs_reclassify_socket6(sock);
> >>>> 
> >>>> -	if (xs_bind6(transport, sock)) {
> >>>> +	if (xs_bind(transport, sock)) {
> >>>> 		sock_release(sock);
> >>>> 		goto out;
> >>>> 	}
> >>>> -- 
> >>>> 1.5.5.6
> >>>> 
> >> 
> >> -- 
> >> chuck[dot]lever[at]oracle[dot]com
> >> 
> >> 
> >> 
> >> 
> 
> -- 
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
