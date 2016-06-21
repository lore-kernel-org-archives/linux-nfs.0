Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbcFUQJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2016 12:09:26 -0400
Subject: Re: [PATCH] nfsdcltrack: fix a typo in the manpage
To: yongcheng.yang@gmail.com, linux-nfs@vger.kernel.org
References: <1466128222-21415-1-git-send-email-yongcheng.yang@gmail.com>
Cc: yoyang@redhat.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <35484e8f-c90b-7d29-183a-a80e1a3db368@RedHat.com>
Date: Tue, 21 Jun 2016 12:09:25 -0400
MIME-Version: 1.0
In-Reply-To: <1466128222-21415-1-git-send-email-yongcheng.yang@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/16/2016 09:50 PM, yongcheng.yang@gmail.com wrote:
> From: Yongcheng Yang <yongcheng.yang@gmail.com>
> 
> Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
Committed.... 

steved.

> ---
>  utils/nfsdcltrack/nfsdcltrack.man | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsdcltrack/nfsdcltrack.man b/utils/nfsdcltrack/nfsdcltrack.man
> index c37c9a8..4b8f4d7 100644
> --- a/utils/nfsdcltrack/nfsdcltrack.man
> +++ b/utils/nfsdcltrack/nfsdcltrack.man
> @@ -22,7 +22,7 @@ nfsdcltrack \- NFSv4 Client Tracking Callout Program
>  nfsdcltrack [\-d] [\-f] [\-s stable storage dir] <command> <args...>
>  .SH "DESCRIPTION"
>  .IX Header "DESCRIPTION"
> -nfsdcltack is the NFSv4 client tracking callout program. It is not necessary
> +nfsdcltrack is the NFSv4 client tracking callout program. It is not necessary
>  to install this program on machines that are not acting as NFSv4 servers.
>  .PP
>  When a network partition is combined with a server reboot, there are
> 
