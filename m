From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] sunrpc: fix build-time warning
Date: Thu, 31 Dec 2009 09:18:15 -0800
Message-ID: <20091231091815.a1ea7e51.rdunlap@xenotime.net>
References: <1262226195-27733-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:46740 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752746AbZLaRSH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Dec 2009 12:18:07 -0500
Received: from chimera.site ([96.253.169.185]) by xenotime.net for <linux-nfs@vger.kernel.org>; Thu, 31 Dec 2009 09:18:03 -0800
In-Reply-To: <1262226195-27733-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Dec 2009 21:23:15 -0500 Jeff Layton wrote:

> Commit 486bad2e40e938cd68fd853b7a9fa3115a9d3a4a introduced this warning
> at build time on some 32-bit architectures:
> 
> net/sunrpc/auth_gss/auth_gss.c: In function 'gss_pipe_downcall':
> net/sunrpc/auth_gss/auth_gss.c:660: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t
> 
> ...fix it by changing the length modifier in the printk.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 66cb89c..6de4f91 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -657,7 +657,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  			break;
>  		default:
>  			printk(KERN_CRIT "%s: bad return from "
> -				"gss_fill_context: %ld\n", __func__, err);
> +				"gss_fill_context: %Zd\n", __func__, err);
>  			BUG();
>  		}
>  		goto err_release_msg;
> -- 

I have that almost-same patch in my (unposted) linux-next patch queue,
so basically, ack, except that we try to use 'z' instead of 'Z' nowadays.

My quick kernel source tree count is 173 %Z to 966 %z.
(Please don't anyone start a project of converting %Z to %z.)


---
~Randy
