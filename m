From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Gssd: modify wrong err message at handle_gssd_upcall
Date: Wed, 09 Feb 2011 11:34:47 -0500
Message-ID: <4D52C227.7050007@RedHat.com>
References: <4D523618.8080106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: NFS <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604Ab1BIQev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 11:34:51 -0500
In-Reply-To: <4D523618.8080106@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/2011 01:37 AM, Mi Jinlong wrote:
> Modify wrong err message at handle_gssd_upcall when 
> sscanf encryption types fail.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  utils/gssd/gssd_proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index c301d46..41328c9 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -1245,7 +1245,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>  			goto out;
>  		if (sscanf(p, "enctypes=%s", enctypes) != 1) {
>  			printerr(0, "WARNING: handle_gssd_upcall: "
> -				    "failed to parse target name "
> +				    "failed to parse encryption types "
>  				    "in upcall string '%s'\n", lbuf);
>  			goto out;
>  		}
Committed... 

steved.
