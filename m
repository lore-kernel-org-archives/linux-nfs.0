Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55886 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932709AbdC2BW6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Mar 2017 21:22:58 -0400
Date: Tue, 28 Mar 2017 21:22:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
Message-ID: <20170329012252.GB20963@fieldses.org>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
 <1490577699.6879.1.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1490577699.6879.1.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 26, 2017 at 09:21:39PM -0400, Jeff Layton wrote:
> On Sun, 2017-03-26 at 19:27 -0400, Chuck Lever wrote:
> > Are we certain that all client implementations (including
> > backchannel clients) will do something useful when presented with
> > such a rejection? At least in the backchannel case, the Linux server
> > had no idea what to do with RPC_PROG_MISMATCH on the backchannel.
> > The workload stopped dead, no error report anywhere.
> > 
> 
> Ouch. I think this would get translated into EPROTONOSUPPORT in the
> client code. That should have ended up with nfsd4_mark_cb_down being
> called with that error?...but I think that function may be effectively
> neutered:

Are we worrying now about a server that tries to open an NFSv4.0
callback connection using UDP?

That would be a very broken server.  And broken in a way that I think is
pretty unlikely to actually happen in practice.

Maybe I'm missing something.

> static void warn_no_callback_path(struct nfs4_client *clp, int reason)
> {
>         dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",
>                 (int)clp->cl_name.len, clp->cl_name.data, reason);
> }

In NFSv4.0 a failing callback connection is absolutely normal (e.g. if
the client is behind a firewall).  We might want to provide some better
diagnostics to help people figure out why a given client isn't getting
delegations, but we don't want to log this by default.

Even in the 4.1 case I wonder if some pretty common failures (e.g.
losing contact with the client) might get noticed by the callback code
first.

So, dprintk is right here.

--b.

> 
> Note that it emits a dprintk instead of a printk. Should we promote
> that to something more visible?
> 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > index c13a5c3..fc8f14c 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > @@ -127,6 +127,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
> >  	xprt = &cma_xprt->sc_xprt;
> >  
> >  	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
> > +	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
> >  	serv->sv_bc_xprt = xprt;
> >  
> >  	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
