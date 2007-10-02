From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 04/35] svc: Add a max payload value to the transport
Date: Tue, 02 Oct 2007 11:28:08 -0500
Message-ID: <1191342488.1565.8.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192738.3250.6971.stgit@dell3.ogc.int>
	<8E01CAF1-5D8D-4AE5-B15D-C04983079F76@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ickcb-0004b4-Ux
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:29:22 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ickcg-0000k5-RG
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:29:27 -0700
In-Reply-To: <8E01CAF1-5D8D-4AE5-B15D-C04983079F76@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-10-02 at 10:54 -0400, Chuck Lever wrote:
> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> >

[...snip...]

> >
> >  struct svc_xprt {
> >  	struct svc_xprt_class	*xpt_class;
> >  	struct svc_xprt_ops	xpt_ops;
> > +	u32			xpt_max_payload;
> >  };
> 
> Why do you need this field in both the class and the instance  
> structures?  Since svc_xprt refers back to svc_xprt_class, you can  
> just take the max payload value from the class.
> 

The premise was that I didn't want a given thread peeking into some
other processors memory, so anything needed from the class is copied
into the svc_xprt structure when the transport instance is created.

Greg, help me here ;-)

> 
> >  int	svc_reg_xprt_class(struct svc_xprt_class *);
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index 55ea6df..2a4b3c6 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1034,10 +1034,8 @@ err_bad:
> >   */
> >  u32 svc_max_payload(const struct svc_rqst *rqstp)
> >  {
> > -	int max = RPCSVC_MAXPAYLOAD_TCP;
> > +	int max = rqstp->rq_xprt->xpt_max_payload;
> >
> > -	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
> > -		max = RPCSVC_MAXPAYLOAD_UDP;
> >  	if (rqstp->rq_server->sv_max_payload < max)
> >  		max = rqstp->rq_server->sv_max_payload;
> >  	return max;
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index f838b57..8ea65c3 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -90,5 +90,6 @@ void svc_xprt_init(struct svc_xprt_class
> >  {
> >  	xpt->xpt_class = xcl;
> >  	xpt->xpt_ops = *xcl->xcl_ops;
> > +	xpt->xpt_max_payload = xcl->xcl_max_payload;
> >  }
> >  EXPORT_SYMBOL_GPL(svc_xprt_init);
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index d52a6e2..d84b5c8 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -905,6 +905,7 @@ static struct svc_xprt_ops svc_udp_ops =
> >  static struct svc_xprt_class svc_udp_class = {
> >  	.xcl_name = "udp",
> >  	.xcl_ops = &svc_udp_ops,
> > +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
> >  };
> >
> >  static void
> > @@ -1358,6 +1359,7 @@ static struct svc_xprt_ops svc_tcp_ops =
> >  static struct svc_xprt_class svc_tcp_class = {
> >  	.xcl_name = "tcp",
> >  	.xcl_ops = &svc_tcp_ops,
> > +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
> >  };
> >
> >  void svc_init_xprt_sock(void)
> 
> Chuck Lever
> chuck.lever@oracle.com
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
