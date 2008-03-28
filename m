From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/6] SUNRPC: Fix a bug in rpcauth_lookup_credcache()
Date: Fri, 28 Mar 2008 11:12:49 -0400
Message-ID: <20080328151249.GA30169@fieldses.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080313174806.13840.26367.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38459 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000AbYC1PMw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 11:12:52 -0400
In-Reply-To: <20080313174806.13840.26367.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delayed response--I read over these offline and them
forgot about them....:

On Thu, Mar 13, 2008 at 01:48:07PM -0400, Trond Myklebust wrote:
> The hash bucket is for some reason always being set to zero.

The changelog seems out of sync with the code; nr is normally set a
little lower to the low bits of acred->uid:

...
> @@ -280,7 +281,9 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
>  	struct hlist_node *pos;
>  	struct rpc_cred	*cred = NULL,
>  			*entry, *new;
> -	int		nr = 0;
> +	unsigned int nr;
> +
> +	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
>  
>  	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS))
>  		nr = acred->uid & RPC_CREDCACHE_MASK;

So what you're really doing is switching to a better hash fn.  (Except
that the result is being overwritten immediately afterwards in the
!RPCAUTH_LOOKUP_ROOTRCREDS case.)

Wouldn't it have made more sense to replace the existing assignment,
then remove just make it unconditional in next patch?

--b.
