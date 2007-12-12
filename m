From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 09/38] svc: Add a transport function that checks for
	write space
Date: Wed, 12 Dec 2007 14:00:05 -0600
Message-ID: <1197489605.21931.133.camel@trinity.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
	 <20071211233212.15718.69282.stgit@dell3.ogc.int>
	 <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:45119 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbXLLTzH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2007 14:55:07 -0500
In-Reply-To: <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2007-12-12 at 13:10 -0500, Chuck Lever wrote:
> Hi Tom-
> 
> On Dec 11, 2007, at 6:32 PM, Tom Tucker wrote:
> > In order to avoid blocking a service thread, the receive side checks

[...snip...]

> > +static int svc_tcp_has_wspace(struct svc_xprt *xprt)
> > +{
> > +	struct svc_sock *svsk = container_of(xprt, struct svc_sock,  
> > sk_xprt);
> > +	struct svc_serv	*serv = svsk->sk_server;
> > +	int required;
> > +	int wspace;
> > +
> > +	/*
> > +	 * Set the SOCK_NOSPACE flag before checking the available
> > +	 * sock space.
> > +	 */
> > +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> > +	wspace = sk_stream_wspace(svsk->sk_sk);
> > +
> > +	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> > +		return 0;
> > +	if (required * 2 > wspace)
> > +		return 0;
> 
> Since "required" is an int, this test can behave differently than the  
> one it replaces.
> 
> What's the test plan to ensure the new test works reasonably?   
> (Actually that's a question for the Maintainers too).
> 

Here's my matrix:

	Connectathon	iozone		Kernel build

V2	udp,tcp
V3	tcp,rdma	tcp,rdma	tcp,rdma
V4	tcp,rdma	tcp,rdma	tcp,rdma

I also kill tests to test the signal race paths, and I run multiple
tests concurrently (e.g. a couple iozones plus a kernel build). 

I guess none of these tests explicitly test the path in question
though.  


> > +
> > +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	return 1;
> > +}
> > +
> >  static struct svc_xprt_ops svc_tcp_ops = {
> >  	.xpo_recvfrom = svc_tcp_recvfrom,
> >  	.xpo_sendto = svc_tcp_sendto,
> > @@ -1373,6 +1402,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
> >  	.xpo_detach = svc_sock_detach,
> >  	.xpo_free = svc_sock_free,
> >  	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
> > +	.xpo_has_wspace = svc_tcp_has_wspace,
> >  };
> >
> >  static struct svc_xprt_class svc_tcp_class = {
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

