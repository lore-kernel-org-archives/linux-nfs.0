From: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Subject: Re: nfs4 over rdma transport oops
Date: Wed, 27 Feb 2008 22:49:26 -0600
Message-ID: <4a4634330802272049xe20ef80y21c2c59f55932c70@mail.gmail.com>
References: <EXNANE01nwpGR881Np7000000e3@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:38017 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbYB1Et2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Feb 2008 23:49:28 -0500
Received: by mu-out-0910.google.com with SMTP id i10so5212627mue.5
        for <linux-nfs@vger.kernel.org>; Wed, 27 Feb 2008 20:49:26 -0800 (PST)
In-Reply-To: <EXNANE01nwpGR881Np7000000e3-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/27/08, Talpey, Thomas <Thomas.Talpey@netapp.com> wrote:
> Shirish, can you try the following patch and see if it allows you to
> avoid increasing the inline read/write sizes?
>
> The problem is that in the case where RPC large-metadata operations
> overflow the buffer, the reallocated req->rl_buffer pointer is overloaded
> to hold the pointer to the old rpcrdma_req, since we had to reallocate it.
> So the container_of() calculation in xprt_rdma_free() backs up to garbage
> not an r_xprt. Then, the switch(ia_memreg_strategy) in the deregistration
> code looks at garbage and decides to ib_dereg_mr. Oops.
>
> The better fix is a little more involved (remove the overloading), but this
> one should nail the issue. Let us know! If it works, we can submit it to
> Trond for inclusion asap.
>
> Tom.
>
> ------
>
> Author: Tom Talpey <tmt@netapp.com>
> Date:   Wed Feb 27 15:04:26 2008 -0500
>
>    Prevent an RPC oops when freeing a dynamically allocated RDMA
>    buffer, used in certain special-case large metadata operations.
>
>    Signed-off-by: Tom Talpey <tmt@netapp.com>
>    Signed-off-by: James Lentini <jlentini@netapp.com>
>
> Index: linux-2.6.25-rc3/net/sunrpc/xprtrdma/transport.c
> ===================================================================
> --- linux-2.6.25-rc3.orig/net/sunrpc/xprtrdma/transport.c
> +++ linux-2.6.25-rc3/net/sunrpc/xprtrdma/transport.c
> @@ -610,7 +610,11 @@
>                return;
>
>        req = container_of(buffer, struct rpcrdma_req, rl_xdr_buf[0]);
> -       r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
> +       if (req->rl_iov.length == 0) {  /* see allocate above */
> +               r_xprt = container_of(((struct rpcrdma_req *) req->rl_buffer)->rl_buffer,
> +                                     struct rpcrdma_xprt, rx_buf);
> +       } else
> +               r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
>        rep = req->rl_reply;
>
>        dprintk("RPC:       %s: called on 0x%p%s\n",
>
>

Tom,

The code fix works.  I did not apply the workaround you had mentioned earlier
and did not encounter oops for the same operation (cat) on the file on the
mounted filesystem.
