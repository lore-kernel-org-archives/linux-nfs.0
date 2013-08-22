Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab3HVSkd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Aug 2013 14:40:33 -0400
Message-ID: <52165B1A.4090502@RedHat.com>
Date: Thu, 22 Aug 2013 14:40:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Libtirpc-devel Mailing List
	<libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [PATCH] rpcbind: rpcuser not being set in Makefile.am
References: <1377110881-14943-1-git-send-email-steved@redhat.com>
In-Reply-To: <1377110881-14943-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/08/13 14:48, Steve Dickson wrote:
> Commit 8d7a0708 cause a regression where the rpcuser id was not
> being set, which in turn cause rpcbind to immediately exit.
> This patch removes the extra ',' that was in the AC_ARG_WITH
> statement in the configure.ac file.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  configure.ac | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 2b67720..1cf42d3 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -23,7 +23,7 @@ AC_ARG_WITH([statedir],
>  AC_SUBST([statedir], [$with_statedir])
>  
>  AC_ARG_WITH([rpcuser],
> -  AS_HELP_STRING([--with-rpcuser=ARG], [use ARG for RPC @<:@default=root@:>@]),
> +  AS_HELP_STRING([--with-rpcuser=ARG], [use ARG for RPC @<:@default=root@:>@])
>    ,, [with_rpcuser=root])
>  AC_SUBST([rpcuser], [$with_rpcuser])
>   
> 
