From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/17] SUNRPC: Don't return EPROTONOSUPPORT in
	svc_register()'s helpers
Date: Wed, 11 Mar 2009 14:32:21 -0400
Message-ID: <20090311183221.GF13540@fieldses.org>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net> <20090303223309.2933.51773.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51988 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbZCKSc2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 14:32:28 -0400
In-Reply-To: <20090303223309.2933.51773.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2009 at 05:33:10PM -0500, Chuck Lever wrote:
> The RPC client returns -EPROTONOSUPPORT if there is a protocol version
> mismatch (ie the remote RPC server doesn't support the RPC protocol
> version sent by the client).
> 
> Helpers for the svc_register() function return -EPROTONOSUPPORT if they
> don't recognize the passed-in IPPROTO_ value.
> 
> These are two entirely different failure modes.
> 
> Have the helpers return -ENOPROTOOPT instead of -ENOPROTOOPT.  This will
						   ^^^^^^^^^^^
						   should be
						   -EPROTONOSUPPORT?

--b.

> allow callers to determine more precisely what the underlying problem is,
> and decide to report or recover appropriately.
> 
> This patch is part of a series that addresses
>    http://bugzilla.kernel.org/show_bug.cgi?id=12256
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/svc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 6cc3c62..c89f04e 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -749,7 +749,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
>  		netid = RPCBIND_NETID_TCP;
>  		break;
>  	default:
> -		return -EPROTONOSUPPORT;
> +		return -ENOPROTOOPT;
>  	}
>  
>  	return rpcb_v4_register(program, version,
> @@ -785,7 +785,7 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
>  		netid = RPCBIND_NETID_TCP6;
>  		break;
>  	default:
> -		return -EPROTONOSUPPORT;
> +		return -ENOPROTOOPT;
>  	}
>  
>  	return rpcb_v4_register(program, version,
> 
