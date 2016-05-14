Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbcENQgn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 May 2016 12:36:43 -0400
Subject: Re: [PATCH] blkmapd: Add the -h flag on the man page
To: yongcheng.yang@gmail.com, linux-nfs@vger.kernel.org
References: <1462342319-7355-1-git-send-email-yongcheng.yang@gmail.com>
Cc: yoyang@redhat.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <e116ec38-32be-6a00-7dc5-4879cce72608@RedHat.com>
Date: Sat, 14 May 2016 12:36:36 -0400
MIME-Version: 1.0
In-Reply-To: <1462342319-7355-1-git-send-email-yongcheng.yang@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/04/2016 02:11 AM, yongcheng.yang@gmail.com wrote:
> From: Yongcheng Yang <yongcheng.yang@gmail.com>
> 
> Update SYNOPSIS and OPTIONS for the -h flag.
> 
> Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
Committed... 

steved
> ---
>  utils/blkmapd/blkmapd.man | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/blkmapd/blkmapd.man b/utils/blkmapd/blkmapd.man
> index fd38122..914b80f 100644
> --- a/utils/blkmapd/blkmapd.man
> +++ b/utils/blkmapd/blkmapd.man
> @@ -9,7 +9,7 @@
>  .SH NAME
>  blkmapd \- pNFS block layout mapping daemon
>  .SH SYNOPSIS
> -.B "blkmapd [-d] [-f]"
> +.B "blkmapd [-h] [-d] [-f]"
>  .SH DESCRIPTION
>  The
>  .B blkmapd
> @@ -33,6 +33,9 @@ reflect the server topology, and passes these devices to the kernel for use
>  by the pNFS block layout client.
>  .SH OPTIONS
>  .TP
> +.B -h
> +Display usage message.
> +.TP
>  .B -d
>  Performs device discovery only then exits.
>  .TP
> 
