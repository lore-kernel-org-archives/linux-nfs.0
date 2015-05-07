Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbbEGOOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 10:14:53 -0400
Message-ID: <554B7355.5090002@RedHat.com>
Date: Thu, 07 May 2015 10:14:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
Subject: Re: [PATCH 1/3] configure.ac: fix typo of enable_nfsdcltrack
References: <552E8FD8.7030706@gmail.com>
In-Reply-To: <552E8FD8.7030706@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/15/2015 12:20 PM, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  configure.ac | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed... 

steved.

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
