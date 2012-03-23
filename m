Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44676 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787Ab2CWMMJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 08:12:09 -0400
Date: Fri, 23 Mar 2012 08:12:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 3/8] sunrpc: create nfsd dir in rpc_pipefs
Message-ID: <20120323121208.GA3219@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <1332337929-18580-4-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332337929-18580-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2012 at 09:52:04AM -0400, Jeff Layton wrote:
> Add a new top-level dir in rpc_pipefs to hold the pipe for the clientid
> upcall.

After applying this patch, my tests consistently hang.  The hang happens
in excltest (of the special connectaton tests), over nfs4.1 and krb5.
Looking at the wire traffic, I'm seeing DELAY returned from a setattr
for mode on a newly-created (with EXCLUSIVE4_1) file.  That open got a
delegation, so presumably that's what's causing the DELAY, though I'm
not seeing the server send a recall.  That could be a krb5 bug.

Whatever bug there is here, it's hard to tell why this patch in
particular would make it more likely.

So, still investigating!

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/rpc_pipe.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 8584ec0..e651e1b 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -1014,6 +1014,7 @@ enum {
>  	RPCAUTH_statd,
>  	RPCAUTH_nfsd4_cb,
>  	RPCAUTH_cache,
> +	RPCAUTH_nfsd,
>  	RPCAUTH_RootEOF
>  };
>  
> @@ -1046,6 +1047,10 @@ static const struct rpc_filelist files[] = {
>  		.name = "cache",
>  		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
>  	},
> +	[RPCAUTH_nfsd] = {
> +		.name = "nfsd",
> +		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
> +	},
>  };
>  
>  /*
> -- 
> 1.7.7.6
> 
