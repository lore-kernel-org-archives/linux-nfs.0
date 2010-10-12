Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53182 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757496Ab0JLRoY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Oct 2010 13:44:24 -0400
Date: Tue, 12 Oct 2010 13:44:22 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: fix default value for --enable-tirpc
Message-ID: <20101012174421.GE22495@fieldses.org>
References: <1286846991-4876-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1286846991-4876-1-git-send-email-jlayton@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 11, 2010 at 09:29:51PM -0400, Jeff Layton wrote:
> The patch I originally proposed to make --enable-tirpc the default had
> the default for $enable_tirpc as a blank string. When it was merged
> however, that value was changed to a 'yes'. This broke the ability for
> autoconf to detect and autodisable building with tirpc. When tirpc isn't
> present now, the configure step fails unless someone explicitly
> specifies --disable-libtirpc.
> 
> We need $enable_tirpc to be a tristate. 'yes' means that someone
> explicitly requested building with tirpc. 'no' means that it was
> explicitly disabled. Anything else means that no one specified a value.
> 
> Fix it by setting the value to a blank string so that the default is
> properly undefined.

Thanks for looking into that, it's FAQ #1 for people rolling their own
these days....

--b.

> 
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  configure.ac |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 3058be6..5408e85 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -136,7 +136,7 @@ AC_ARG_ENABLE(tirpc,
>  	[AC_HELP_STRING([--enable-tirpc],
>  			[enable use of TI-RPC @<:@default=yes@:>@])],
>  	enable_tirpc=$enableval,
> -	enable_tirpc='yes')
> +	enable_tirpc='')
>  AC_ARG_ENABLE(ipv6,
>  	[AC_HELP_STRING([--enable-ipv6],
>                          [enable support for IPv6 @<:@default=no@:>@])],
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
