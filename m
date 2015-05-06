Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34763 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbEFNj6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:39:58 -0400
Received: by pacyx8 with SMTP id yx8so9824903pac.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 06:39:58 -0700 (PDT)
Message-ID: <554A19A9.8040403@gmail.com>
Date: Wed, 06 May 2015 21:39:53 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
Subject: Re: [PATCH 1/3] configure.ac: fix typo of enable_nfsdcltrack
References: <552E8FD8.7030706@gmail.com>
In-Reply-To: <552E8FD8.7030706@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Steve, 

What's your opinion about those three ? 

thanks,
Kinglong Mee

On 4/16/2015 12:20 AM, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  configure.ac | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index e61430f..21be2bd 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -213,7 +213,7 @@ fi
>  AC_ARG_ENABLE(nfsdcltrack,
>  	[AC_HELP_STRING([--disable-nfsdcltrack],
>  			[disable NFSv4 clientid tracking programs @<:@default=no@:>@])],
> -	enable_nfsdctrack=$enableval,
> +	enable_nfsdcltrack=$enableval,
>  	enable_nfsdcltrack="yes")
>  
>  dnl Check for TI-RPC library and headers
> 
