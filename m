Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754324Ab0J1NYD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 09:24:03 -0400
Message-ID: <4CC97970.6010706@RedHat.com>
Date: Thu, 28 Oct 2010 09:24:00 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
CC: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: fix default value for --enable-tirpc
References: <1286846991-4876-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1286846991-4876-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff,

On 10/11/2010 09:29 PM, Jeff Layton wrote:
> The patch I originally proposed to make --enable-tirpc the default had
> the default for $enable_tirpc as a blank string. When it was merged
> however, that value was changed to a 'yes'. 
Which commit or proposal are you talking about? I'm looking at commit 148503a
which changed it for no to yes, but I can not seem to find the 
proposal you are talking about?

I'm just trying to figure how the merge broke it so it does
not happen again... 

steved.

> This broke the ability for
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
