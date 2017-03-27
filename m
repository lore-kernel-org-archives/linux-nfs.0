Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33969 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdC0BVp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Mar 2017 21:21:45 -0400
Received: by mail-qt0-f193.google.com with SMTP id x35so5751876qtc.1
        for <linux-nfs@vger.kernel.org>; Sun, 26 Mar 2017 18:21:44 -0700 (PDT)
Message-ID: <1490577699.6879.1.camel@poochiereds.net>
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Date: Sun, 26 Mar 2017 21:21:39 -0400
In-Reply-To: <20170326231254.1319.26075.stgit@manet.1015granger.net>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2017-03-26 at 19:27 -0400, Chuck Lever wrote:
> Same change as Kinglong Mee's fix for the TCP backchannel service.
> 

Good catch. I guess I didn't do a good job of hunting down all of the
transports where this needed to be set. I'll give them another pass
again tomorrow to make sure I didn't miss any others.

> Fixes: 5283b03ee5cd ("nfs/nfsd/sunrpc: enforce transport...")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Some (perhaps late) review comments on 5283b03ee5cd:
> 
> I have reservations about returning RPC_PROG_MISMATCH in this case.
> RPC_PROG_UNAVAIL is more sensible. But the use of UDP with NFSv4 is
> not an RPC-level error, thus reporting the problem here seems like a
> layering violation.
> 
> I'm not sure why an explicit check is needed: if the server isn't
> listening on UDP, wouldn't clients see a transport-level rejection
> (like ECONNREFUSED)?
> 

Sure, if the server isn't listening on UDP...

The point of that patch is to enforce not allowing v4 over UDP when the
server is listening on UDP to serve earlier versions.

As far as the error...From RFC 5531:

            PROG_UNAVAIL  = 1, /* remote hasn't exported program  */
            PROG_MISMATCH = 2, /* remote can't support version #  */

Consider the case where the server is listening on both TCP and UDP,
and is serving both v3 and v4. Someone tries to send a v4 RPC over UDP.

The RPC program in that case (nfs) is supported over UDP, but the
version (v4) is not. So I disagree here. PROG_MISMATCH seems like the
better fit to me.

> Are we certain that all client implementations (including
> backchannel clients) will do something useful when presented with
> such a rejection? At least in the backchannel case, the Linux server
> had no idea what to do with RPC_PROG_MISMATCH on the backchannel.
> The workload stopped dead, no error report anywhere.
> 

Ouch. I think this would get translated into EPROTONOSUPPORT in the
client code. That should have ended up with nfsd4_mark_cb_down being
called with that error?...but I think that function may be effectively
neutered:

static void warn_no_callback_path(struct nfs4_client *clp, int reason)
{
        dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",
                (int)clp->cl_name.len, clp->cl_name.data, reason);
}

Note that it emits a dprintk instead of a printk. Should we promote
that to something more visible?

>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index c13a5c3..fc8f14c 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -127,6 +127,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
>  	xprt = &cma_xprt->sc_xprt;
>  
>  	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
> +	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
>  	serv->sv_bc_xprt = xprt;
>  
>  	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

