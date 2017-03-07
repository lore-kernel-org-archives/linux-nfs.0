Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33708 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752532AbdCGLMO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 06:12:14 -0500
Received: by mail-qk0-f180.google.com with SMTP id y76so70093465qkb.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Mar 2017 03:11:25 -0800 (PST)
Message-ID: <1488885081.2788.0.camel@redhat.com>
Subject: Re: [PATCH] SUNRPC/backchanel: set XPT_CONG_CTRL flag for bc xprt
From: Jeff Layton <jlayton@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Tue, 07 Mar 2017 06:11:21 -0500
In-Reply-To: <b321152e-cbe8-94b3-498c-1d32e7c7be2d@gmail.com>
References: <b321152e-cbe8-94b3-498c-1d32e7c7be2d@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-03-07 at 17:22 +0800, Kinglong Mee wrote:
> The xprt for backchannel is created separately, not in TCP/UDP code.
> Because without the flags, the requests from NFSv41 backchannel are
> rejected in svc_process_common(),
> 
> 1191         if (versp->vs_need_cong_ctrl &&
> 1192             !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
> 1193                 goto err_bad_vers;
> 
> Fixes: 5283b03ee5 ("nfs/nfsd/sunrpc: enforce transport...")
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/svcsock.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 8931e33..2b720fa 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1635,6 +1635,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
>  
>  	xprt = &svsk->sk_xprt;
>  	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
> +	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
>  
>  	serv->sv_bc_xprt = xprt;
>  

Good catch.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
