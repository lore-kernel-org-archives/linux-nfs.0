Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117Ab3BRSmH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 13:42:07 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 1/9] SUNRPC: Missing module alias for auth_rpcgss.ko
Date: Mon, 18 Feb 2013 18:42:05 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235CF1F8@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130204201458.1518.12931.stgit@seurat.1015granger.net>
	 <20130204201903.1518.91133.stgit@seurat.1015granger.net>
In-Reply-To: <20130204201903.1518.91133.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-02-04 at 15:19 -0500, Chuck Lever wrote:
> Commit f344f6df "SUNRPC: Auto-load RPC authentication kernel
> modules", Mon Mar 20 13:44:08 2006, adds a request_module() call
> in rpcauth_create() to auto-load RPC security modules when a ULP
> tries to create a credential of that flavor.
> 
> In rpcauth_create(), the name of the module to load is built like
> this:
> 
> 	request_module("rpc-auth-%u", flavor);
> 
> This means that for, say, RPC_AUTH_GSS, request_module() is looking
> for a module or alias called "rpc-auth-6".
> 
> The GSS module is named "auth_rpcgss", and commit f344f6df does not
> add any new module aliases.  There is also no such alias provided in
> /etc/modprobe.d on my system (Fedora 16).  Without this alias, the
> GSS module is not loaded on demand.

Wait... Why do we want to load the auth_rpcgss module on its own? It
doesn't provide any authentication or security mechanisms of its own.
All it does is to provide support for the other security mechanisms.

As far as I can see, calling rpcauth_create() with a pseudoflavour value
of '6' is a bug...

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/auth_gss/auth_gss.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 6e5c824..4db065d 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1721,6 +1721,7 @@ static void __exit exit_rpcsec_gss(void)
>  	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>  }
>  
> +MODULE_ALIAS("rpc-auth-6");
>  MODULE_LICENSE("GPL");
>  module_param_named(expired_cred_retry_delay,
>  		   gss_expired_cred_retry_delay,
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
