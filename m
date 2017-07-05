Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42660 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750896AbdGEO6w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Jul 2017 10:58:52 -0400
Subject: Re: [PATCH] Fix struct rpcent for uclibc-ng
To: Joshua Kinard <kumba@gentoo.org>,
        libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
References: <229cb44f-f79e-f704-5930-9b1decacf555@gentoo.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <850f9ad2-552d-fefe-4b94-2420c02bf076@RedHat.com>
Date: Wed, 5 Jul 2017 10:58:50 -0400
MIME-Version: 1.0
In-Reply-To: <229cb44f-f79e-f704-5930-9b1decacf555@gentoo.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/05/2017 09:24 AM, Joshua Kinard wrote:
> Commit 6d8d4b5a7bf6 addresses an issue for musl, based on a description of
> an earlier patch at https://patchwork.kernel.org/patch/5499671/.  That
> description notes uncertainty with uclibc, which also defines __GLIBC__.
> This patch fixes the uclibc case by also checking for __UCLIBC__.
> 
> Fixes: 6d8d4b5a7bf6 ("Include string.h for memset")
> Signed-off-by: Joshua Kinard <kumba@gentoo.org>
> Cc: Natanael Copa <ncopa@alpinelinux.org>
Committed...

steved.

> ---
> 
>  tirpc/rpc/rpcent.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tirpc/rpc/rpcent.h b/tirpc/rpc/rpcent.h
> index e07503c..9d3ef9c 100644
> --- a/tirpc/rpc/rpcent.h
> +++ b/tirpc/rpc/rpcent.h
> @@ -49,7 +49,7 @@ extern "C" {
>  #endif
>  
>  /* These are defined in /usr/include/rpc/netdb.h */
> -#if !defined(__GLIBC__)
> +#if !defined(__GLIBC__) || defined(__UCLIBC__)
>  struct rpcent {
>  	char	*r_name;	/* name of server for this rpc program */
>  	char	**r_aliases;	/* alias list */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
