Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46154 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752915AbdJPSGn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 14:06:43 -0400
Date: Mon, 16 Oct 2017 14:06:42 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Colin King <colin.king@canonical.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrcp: make function _svc_create_xprt static
Message-ID: <20171016180642.GA12608@fieldses.org>
References: <20171016134021.15702-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171016134021.15702-1-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied for 4.15.--b.

On Mon, Oct 16, 2017 at 02:40:21PM +0100, Colin King wrote:
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
> -- 
> 2.14.1
