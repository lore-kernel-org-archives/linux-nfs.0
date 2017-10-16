Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:54620 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752358AbdJPOJg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 10:09:36 -0400
Received: by mail-qt0-f196.google.com with SMTP id z19so31852549qtg.11
        for <linux-nfs@vger.kernel.org>; Mon, 16 Oct 2017 07:09:36 -0700 (PDT)
Message-ID: <1508162973.5023.11.camel@poochiereds.net>
Subject: Re: [PATCH] sunrcp: make function _svc_create_xprt static
From: Jeff Layton <jlayton@poochiereds.net>
To: Colin King <colin.king@canonical.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 16 Oct 2017 10:09:33 -0400
In-Reply-To: <20171016134021.15702-1-colin.king@canonical.com>
References: <20171016134021.15702-1-colin.king@canonical.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-10-16 at 14:40 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The function _svc_create_xprt is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol '_svc_create_xprt' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sunrpc/svc_xprt.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index d16a8b423c20..18e87791350f 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -250,9 +250,9 @@ void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
>  	svc_xprt_received(new);
>  }
>  
> -int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> -		    struct net *net, const int family,
> -		    const unsigned short port, int flags)
> +static int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> +			    struct net *net, const int family,
> +			    const unsigned short port, int flags)
>  {
>  	struct svc_xprt_class *xcl;
>  

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
