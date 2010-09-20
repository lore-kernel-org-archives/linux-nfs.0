Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045Ab0ITRUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 13:20:52 -0400
Date: Mon, 20 Sep 2010 13:19:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/9] sunrpc: The per-net skeleton
Message-ID: <20100920171924.GM4580@fieldses.org>
References: <4C90BADB.10700@parallels.com>
 <4C90BBE9.6000105@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C90BBE9.6000105@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 15, 2010 at 04:28:25PM +0400, Pavel Emelyanov wrote:
> @@ -38,18 +58,26 @@ init_sunrpc(void)
>  	err = rpcauth_init_module();
>  	if (err)
>  		goto out3;
> +
> +	cache_initialize();
> +
> +	err = register_pernet_subsys(&sunrpc_net_ops);
> +	if (err)
> +		goto out4;
>  #ifdef RPC_DEBUG
>  	rpc_register_sysctl();
>  #endif
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_init();
>  #endif
> -	cache_initialize();
>  	cache_register(&ip_map_cache);
>  	cache_register(&unix_gid_cache);
>  	svc_init_xprt_sock();	/* svc sock transport */
>  	init_socket_xprt();	/* clnt sock transport */
>  	return 0;
> +
> +out4:
> +	unregister_pernet_subsys(&sunrpc_net_ops);

If register_pernet_subsys() failed, then shouldn't this be unnecessary?
Maybe this should be rpcauth_remove_module()?

--b.

>  out3:
>  	rpc_destroy_mempool();
>  out2:
> @@ -69,6 +97,7 @@ cleanup_sunrpc(void)
>  	rpc_destroy_mempool();
>  	cache_unregister(&ip_map_cache);
>  	cache_unregister(&unix_gid_cache);
> +	unregister_pernet_subsys(&sunrpc_net_ops);
>  #ifdef RPC_DEBUG
>  	rpc_unregister_sysctl();
>  #endif
> -- 
> 1.5.5.6
> 
