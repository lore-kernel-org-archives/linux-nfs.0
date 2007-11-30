From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 04/38] svc: Add a max payload value to the transport
Date: Fri, 30 Nov 2007 14:51:26 -0600
Message-ID: <1196455886.5432.47.camel@trinity.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
	 <20071129224002.14563.96227.stgit@dell3.ogc.int>
	 <9EE69A6F-7E18-40CC-A8F4-71CBFF4E6E2E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:45359 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052AbXK3UrV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 15:47:21 -0500
In-Reply-To: <9EE69A6F-7E18-40CC-A8F4-71CBFF4E6E2E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Chuck, I'll fix this.

On Fri, 2007-11-30 at 15:22 -0500, Chuck Lever wrote:
> On Nov 29, 2007, at 5:40 PM, Tom Tucker wrote:
> > The svc_max_payload function currently looks at the socket type
> > to determine the max payload. Add a max payload value to  
> > svc_xprt_class
> > so it can be returned directly.
> >
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> >
> >  include/linux/sunrpc/svc_xprt.h |    1 +
> >  net/sunrpc/svc.c                |    4 +---
> >  net/sunrpc/svcsock.c            |    2 ++
> >  3 files changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> > svc_xprt.h
> > index a8b1da8..b4ce054 100644
> > --- a/include/linux/sunrpc/svc_xprt.h
> > +++ b/include/linux/sunrpc/svc_xprt.h
> > @@ -17,6 +17,7 @@ struct svc_xprt_class {
> >  	struct module		*xcl_owner;
> >  	struct svc_xprt_ops	*xcl_ops;
> >  	struct list_head	xcl_list;
> > +	u32			xcl_max_payload;
> >  };
> >
> >  struct svc_xprt {
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index a4a6bf7..ce59044 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1054,10 +1054,8 @@ err_bad:
> >   */
> >  u32 svc_max_payload(const struct svc_rqst *rqstp)
> >  {
> > -	int max = RPCSVC_MAXPAYLOAD_TCP;
> > +	int max = rqstp->rq_xprt->xpt_class->xcl_max_payload;
> 
> Nit: xcl_max_payload is unsigned, as is sv_max_payload, and so is the  
> return type of the svc_max_payload() function, so the automatic  
> variable "max" should also be an unsigned integral type.  (Implicit  
> type conversion in the comparison below prevents this from being an  
> actual bug).
> 
> > -	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
> > -		max = RPCSVC_MAXPAYLOAD_UDP;
> >  	if (rqstp->rq_server->sv_max_payload < max)
> >  		max = rqstp->rq_server->sv_max_payload;
> >  	return max;
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 4755467..ca9b8d8 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -906,6 +906,7 @@ static struct svc_xprt_ops svc_udp_ops = {
> >  static struct svc_xprt_class svc_udp_class = {
> >  	.xcl_name = "udp",
> >  	.xcl_ops = &svc_udp_ops,
> > +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
> >  };
> >
> >  static void
> > @@ -1359,6 +1360,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
> >  static struct svc_xprt_class svc_tcp_class = {
> >  	.xcl_name = "tcp",
> >  	.xcl_ops = &svc_tcp_ops,
> > +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
> >  };
> >
> >  void svc_init_xprt_sock(void)
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com

