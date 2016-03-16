Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934845AbcCPSVc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 14:21:32 -0400
Subject: Re: [PATCH] mountd.man: Update to change -P option as an alias for -p
To: Yongcheng Yang <yoyang@redhat.com>, linux-nfs@vger.kernel.org
References: <1457667599-6880-1-git-send-email-yoyang@redhat.com>
Cc: Yongcheng Yang <yongcheng.yang@gmail.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E9A42B.5040200@RedHat.com>
Date: Wed, 16 Mar 2016 14:21:31 -0400
MIME-Version: 1.0
In-Reply-To: <1457667599-6880-1-git-send-email-yoyang@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/10/2016 10:39 PM, Yongcheng Yang wrote:
> From: Yongcheng Yang <yongcheng.yang@gmail.com>
> 
> Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
Committed... 

steved.

> ---
>  utils/mountd/mountd.man | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
> index 7c5bfbe..66e3bba 100644
> --- a/utils/mountd/mountd.man
> +++ b/utils/mountd/mountd.man
> @@ -115,10 +115,7 @@ must be invoked with the option
>  .B \-n " or " \-\-no-tcp
>  Don't advertise TCP for mount.
>  .TP
> -.B \-P
> -Ignored (compatibility with unfsd??).
> -.TP
> -.B \-p num " or " \-\-port num
> +.B \-p num " or " \-P num " or " \-\-port num
>  Specifies the port number used for RPC listener sockets.
>  If this option is not specified,
>  .B rpc.mountd
> 
