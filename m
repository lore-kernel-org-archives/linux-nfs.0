Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f46.google.com ([209.85.128.46]:41428 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbaAGFBe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jan 2014 00:01:34 -0500
Received: by mail-qe0-f46.google.com with SMTP id a11so18797286qen.5
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 21:01:33 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <52CB8564.6040002@gmail.com>
Date: Tue, 7 Jan 2014 00:01:30 -0500
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <11FBA3CF-C026-42F8-943E-326B11A55929@primarydata.com>
References: <52CB8564.6040002@gmail.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2014, at 23:41, Kinglong Mee <kinglongmee@gmail.com> wrote:

> If try_module_get failed, xpt_bc_xprt should be set to NULL,
> because xprt will be free.
> 
> Don't needed using xprt_put to free xprt, because it is always new.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
> net/sunrpc/xprtsock.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 4fcdf74..5ed124f 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2986,10 +2986,10 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> 	 */
> 	xprt_set_connected(xprt);
> 
> -
> 	if (try_module_get(THIS_MODULE))
> 		return xprt;
> -	xprt_put(xprt);
> +
> +	args->bc_xprt->xpt_bc_xprt = NULL;
> 	ret = ERR_PTR(-EINVAL);
> out_err:
> 	xs_xprt_free(xprt);


Just move the 'args->bc_xprt->xpt_bc_xprt = xprt’ line into the caller (see earlier discussion about xs_setup_bc_tcp()). Quite frankly, I don’t see why the client code should be modifying this variable in the first place. An svc_xprt is a server construct.

Trond