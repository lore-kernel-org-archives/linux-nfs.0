Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38210 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752968AbcKHUDx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 15:03:53 -0500
Date: Tue, 8 Nov 2016 15:03:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: svc_xprt_put is no longer BH-safe
Message-ID: <20161108200339.GA26589@fieldses.org>
References: <1934654A-78D7-4180-A0AA-4B144254BFC2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1934654A-78D7-4180-A0AA-4B144254BFC2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2016 at 12:21:03PM -0400, Chuck Lever wrote:
> Hi Bruce-

Sorry for the slow response!

...
> In commit 39a9beab5acb83176e8b9a4f0778749a09341f1f ('rpc: share one xps between
> all backchannels') you added:
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index f5572e3..4f01f63 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -136,6 +136,8 @@ static void svc_xprt_free(struct kref *kref)
>         /* See comment on corresponding get in xs_setup_bc_tcp(): */
>         if (xprt->xpt_bc_xprt)
>                 xprt_put(xprt->xpt_bc_xprt);
> +       if (xprt->xpt_bc_xps)
> +               xprt_switch_put(xprt->xpt_bc_xps);
>         xprt->xpt_ops->xpo_free(xprt);
>         module_put(owner);
>  }
> 
> svc_xprt_free() is invoked by svc_xprt_put(). svc_xprt_put() is called
> from svc_rdma in soft IRQ context (eg. svc_rdma_wc_receive).

Is that necessary?  I wonder why the svcrdma code seems to be taking so
many of its own references on svc_xprts.

> However, xprt_switch_put() takes a spin lock (xps_lock) which is locked
> everywhere without disabling BHs.
> 
> It looks to me like 39a9beab5acb makes svc_xprt_put() no longer BH-safe?
> Not sure if svc_xprt_put() was intended to be BH-safe beforehand.
> 
> Maybe xprt_switch_put() could be invoked in ->xpo_free, but that seems
> like a temporary solution.

Since xpo_free is also called from svc_xprt_put that doesn't sound like
it would change anything.  Or do we not trunk over RDMA for some reason?

--b.

> 
> 
> --
> Chuck Lever
> 
> 
