From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 16/20] svc: xpt_create_svc
Date: Wed, 29 Aug 2007 15:43:41 -0500
Message-ID: <1188420221.7502.55.camel@trinity.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162355.15224.79027.stgit@dell3.ogc.int>
	<46D5C731.1060201@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQg0W-0006rY-MZ
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 02:08:10 -0700
Received: from ms-smtp-02.texas.rr.com ([24.93.47.41])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQg0Z-0004Rg-Ja
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 02:08:13 -0700
In-Reply-To: <46D5C731.1060201@oracle.com>
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

On Wed, 2007-08-29 at 15:21 -0400, Chuck Lever wrote:
> Tom Tucker wrote:
> > Add transport function that makes the creation of a listening endpoint 
> > transport independent.
> 
> I'm beginning to think svc_makesock should be renamed. :-)
> 
> I'm not sure about the function naming here.  I can't easily distinguish 
> between the generic and socket-specific creating functions.
> 

I _promise_ to clean the names up in the next patch ;-) But this one has
a special issue because it's called all over the place. That's why I
added the new API. The idea was we could go in and incrementally patch
other svc services as needed, but otherwise make the svc internals
changes opaque to svc clients.

> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  include/linux/sunrpc/svcsock.h |    5 +++
> >  net/sunrpc/svcsock.c           |   65 +++++++++++++++++++++++++++++++++++++---
> >  2 files changed, 65 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> > index cc911ab..e2d0256 100644
> > --- a/include/linux/sunrpc/svcsock.h
> > +++ b/include/linux/sunrpc/svcsock.h
> > @@ -14,6 +14,10 @@ #include <linux/sunrpc/svc.h>
> >  struct svc_xprt {
> >  	const char		*xpt_name;
> >  	struct module		*xpt_owner;
> > +	/* Create an svc socket for this transport */
> > +	int			(*xpt_create_svc)(struct svc_serv *,
> > +						  struct sockaddr *,
> > +						  int);
> >  	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
> >  	int			(*xpt_sendto)(struct svc_rqst *rqstp);
> >  	/*
> > @@ -109,6 +113,7 @@ #define	SK_LISTENER	11			/* listener (e.
> >  int 		svc_register_transport(struct svc_xprt *xprt);
> >  int 		svc_unregister_transport(struct svc_xprt *xprt);
> >  int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
> > +int		svc_create_svcsock(struct svc_serv *, char *, unsigned short, int);
> >  void		svc_force_close_socket(struct svc_sock *);
> >  int		svc_recv(struct svc_rqst *, long);
> >  int		svc_send(struct svc_rqst *);
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 276737e..44d6484 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -87,6 +87,8 @@ static void		svc_close_socket(struct svc
> >  static void		svc_sock_detach(struct svc_sock *);
> >  static void		svc_sock_free(struct svc_sock *);
> >  
> > +static int
> > +svc_create_socket(struct svc_serv *, int, struct sockaddr *, int, int);
> >  static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
> >  static int svc_deferred_recv(struct svc_rqst *rqstp);
> >  static struct cache_deferred_req *svc_defer(struct cache_req *req);
> > @@ -434,6 +436,7 @@ __svc_sock_put(struct svc_sock *svsk)
> >  
> >  	if (svsk->sk_info_authunix != NULL)
> >  		svcauth_unix_info_release(svsk->sk_info_authunix);
> > +	module_put(svsk->sk_xprt->xpt_owner);
> >  	svsk->sk_xprt->xpt_free(svsk);
> >  }
> >  EXPORT_SYMBOL_GPL(__svc_sock_put);
> > @@ -961,9 +964,17 @@ svc_udp_has_wspace(struct svc_sock *svsk
> >  	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
> >  }
> >  
> > +static int
> > +svc_udp_create_svc(struct svc_serv *serv, struct sockaddr *sa, int flags)
> > +{
> > +	return svc_create_socket(serv, IPPROTO_UDP, sa,
> > +				 sizeof(struct sockaddr_in), flags);
> > +}
> > +
> >  static struct svc_xprt svc_udp_xprt = {
> >  	.xpt_name = "udp",
> >  	.xpt_owner = THIS_MODULE,
> > +	.xpt_create_svc = svc_udp_create_svc,
> >  	.xpt_recvfrom = svc_udp_recvfrom,
> >  	.xpt_sendto = svc_udp_sendto,
> >  	.xpt_detach = svc_sock_detach,
> > @@ -1421,9 +1432,17 @@ svc_tcp_has_wspace(struct svc_sock *svsk
> >  	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
> >  }
> >  
> > +static int
> > +svc_tcp_create_svc(struct svc_serv *serv, struct sockaddr *sa, int flags)
> > +{
> > +	return svc_create_socket(serv, IPPROTO_TCP, sa,
> > +				 sizeof(struct sockaddr_in), flags);
> > +}
> > +
> >  static struct svc_xprt svc_tcp_xprt = {
> >  	.xpt_name = "tcp",
> >  	.xpt_owner = THIS_MODULE,
> > +	.xpt_create_svc = svc_tcp_create_svc,
> >  	.xpt_recvfrom = svc_tcp_recvfrom,
> >  	.xpt_sendto = svc_tcp_sendto,
> >  	.xpt_detach = svc_sock_detach,
> > @@ -1606,6 +1625,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
> >  		svc_delete_socket(svsk);
> >  	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
> >  		svsk->sk_xprt->xpt_accept(svsk);
> > +		__module_get(svsk->sk_xprt->xpt_owner);
> >  		svc_sock_received(svsk);
> >  	} else {
> >  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
> > @@ -1885,7 +1905,7 @@ EXPORT_SYMBOL_GPL(svc_addsock);
> >   * Create socket for RPC service.
> >   */
> >  static int svc_create_socket(struct svc_serv *serv, int protocol,
> > -				struct sockaddr *sin, int len, int flags)
> > +			     struct sockaddr *sin, int len, int flags)
> >  {
> >  	struct svc_sock	*svsk;
> >  	struct socket	*sock;
> > @@ -2037,18 +2057,53 @@ void svc_force_close_socket(struct svc_s
> >   *
> >   */
> >  int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port,
> > -			int flags)
> > +		 int flags)
> >  {
> > +	dprintk("svc: creating socket proto = %d\n", protocol);
> > +	switch (protocol) {
> > +	case IPPROTO_TCP:
> > +		return svc_create_svcsock(serv, "tcp", port, flags);
> > +	case IPPROTO_UDP:
> > +		return svc_create_svcsock(serv, "udp", port, flags);
> > +	default:
> > +		return -EINVAL;
> > +	}
> > +}
> > +
> > +int svc_create_svcsock(struct svc_serv *serv, char *transport, unsigned short port,
> > +		       int flags)
> > +{
> > +	int ret = -ENOENT;
> > +	struct list_head *le;
> >  	struct sockaddr_in sin = {
> >  		.sin_family		= AF_INET,
> >  		.sin_addr.s_addr	= INADDR_ANY,
> >  		.sin_port		= htons(port),
> >  	};
> > +	dprintk("svc: creating transport socket %s[%d]\n", transport, port);
> > +	spin_lock(&svc_transport_lock);
> > +	list_for_each(le, &svc_transport_list) {
> > +		struct svc_xprt *xprt =
> > +			list_entry(le, struct svc_xprt, xpt_list);
> >  
> > -	dprintk("svc: creating socket proto = %d\n", protocol);
> > -	return svc_create_socket(serv, protocol, (struct sockaddr *) &sin,
> > -							sizeof(sin), flags);
> > +		if (strcmp(transport, xprt->xpt_name)==0) {
> 
> nit: I like "xpt_name) == 0)" instead.
> 

ah, took me a second to get this one ... white space ... ok

> > +			spin_unlock(&svc_transport_lock);
> > +			if (try_module_get(xprt->xpt_owner)) {
> > +				ret = xprt->xpt_create_svc(serv,
> > +							   (struct sockaddr*)&sin,
> > +							   flags);
> > +				if (ret < 0)
> > +					module_put(xprt->xpt_owner);
> > +				goto out;
> > +			}
> > +		}
> > +	}
> > +	spin_unlock(&svc_transport_lock);
> > +	dprintk("svc: transport %s not found\n", transport);
> > + out:
> > +	return ret;
> >  }
> > +EXPORT_SYMBOL_GPL(svc_create_svcsock);
> >  
> >  /*
> >   * Handle defer and revisit of requests
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
