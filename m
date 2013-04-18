Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16980 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967565Ab3DRRHG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Apr 2013 13:07:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/5] SUNRPC: allow disabling idle timeout
Date: Thu, 18 Apr 2013 17:07:03 +0000
Message-ID: <1366304823.58246.22.camel@leira.trondhjem.org>
References: <1366054508-27604-1-git-send-email-bfields@redhat.com>
	 <1366054508-27604-3-git-send-email-bfields@redhat.com>
	 <20130418170020.GA31075@fieldses.org>
In-Reply-To: <20130418170020.GA31075@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-18 at 13:00 -0400, J. Bruce Fields wrote:
> On Mon, Apr 15, 2013 at 03:35:04PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > In the gss-proxy case we don't want to have to reconnect at random--we
> > want to connect only on gss-proxy startup when we can steal gss-proxy's
> > context to do the connect in the right namespace.
> > 
> > So, provide a flag that allows the rpc_create caller to turn off the
> > idle timeout.
> 
> Chuck, the basic ideas was your suggestion, does the executation look OK
> here?  I had to copy the rpc_create flags down to the xprt_create, I
> don't know if that's reasonable.

This patch will conflict with commit
b7993cebb841b0da7a33e9d5ce301a9fd3209165 (SUNRPC: Allow rpc_create() to
request that TCP slots be unlimited) that was posted on this list
earlier this week.

> --b.
> 
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  include/linux/sunrpc/clnt.h |    1 +
> >  include/linux/sunrpc/xprt.h |    1 +
> >  net/sunrpc/clnt.c           |    1 +
> >  net/sunrpc/xprt.c           |    2 ++
> >  4 files changed, 5 insertions(+)
> > 
> > diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> > index 2cf4ffa..8164986 100644
> > --- a/include/linux/sunrpc/clnt.h
> > +++ b/include/linux/sunrpc/clnt.h
> > @@ -124,6 +124,7 @@ struct rpc_create_args {
> >  #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
> >  #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
> >  #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
> > +#define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 7)
> >  
> >  struct rpc_clnt *rpc_create(struct rpc_create_args *args);
> >  struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 30834be..df28503 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -263,6 +263,7 @@ struct xprt_create {
> >  	size_t			addrlen;
> >  	const char		*servername;
> >  	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
> > +	unsigned long		flags;
> >  };
> >  
> >  struct xprt_class {
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index dcc446e..a41d64a 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -411,6 +411,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
> >  		.addrlen = args->addrsize,
> >  		.servername = args->servername,
> >  		.bc_xprt = args->bc_xprt,
> > +		.flags = args->flags,
> >  	};
> >  	char servername[48];
> >  
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index b7478d5..37cbc37 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -1245,6 +1245,8 @@ found:
> >  				-PTR_ERR(xprt));
> >  		goto out;
> >  	}
> > +	if (args->flags & RPC_CLNT_CREATE_NO_IDLE_TIMEOUT)
> > +		xprt->idle_timeout = 0;
> >  	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
> >  	if (xprt_has_timer(xprt))
> >  		setup_timer(&xprt->timer, xprt_init_autodisconnect,
> > -- 
> > 1.7.9.5
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
