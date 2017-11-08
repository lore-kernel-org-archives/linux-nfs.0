Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:45170 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754756AbdKHBWt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Nov 2017 20:22:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id b192so827586pga.2
        for <linux-nfs@vger.kernel.org>; Tue, 07 Nov 2017 17:22:49 -0800 (PST)
Date: Wed, 8 Nov 2017 10:22:05 +0900
From: Stephen Hemminger <stephen@networkplumber.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 21/21] sunrpc: exit_net cleanup check added
Message-ID: <20171108102205.55aa82eb@shemminger-XPS-13-9360>
In-Reply-To: <c450ca1b-67dd-8cef-5cb5-a2dfeaaa793e@virtuozzo.com>
References: <c450ca1b-67dd-8cef-5cb5-a2dfeaaa793e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 5 Nov 2017 13:02:44 +0300
Vasily Averin <vvs@virtuozzo.com> wrote:

> Be sure that all_clients list initialized in net_init hook was return
> to initial state.
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  net/sunrpc/sunrpc_syms.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> index c73de18..0c5a90f 100644
> --- a/net/sunrpc/sunrpc_syms.c
> +++ b/net/sunrpc/sunrpc_syms.c
> @@ -65,10 +65,14 @@ static __net_init int sunrpc_init_net(struct net *net)
>  
>  static __net_exit void sunrpc_exit_net(struct net *net)
>  {
> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> +
>  	rpc_pipefs_exit_net(net);
>  	unix_gid_cache_destroy(net);
>  	ip_map_cache_destroy(net);
>  	rpc_proc_exit(net);
> +	WARN(!list_empty(&sn->all_clients),
> +	     "net %p exit: sunrpc all_clients list is not empty\n", net);
>  }

Don't print a kernel pointer, this is a security leak.
