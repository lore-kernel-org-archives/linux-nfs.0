Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656AbcGRRdK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2016 13:33:10 -0400
Subject: Re: [PATCH] exportfs: fix export point checking
To: "Jianhong.Yin" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
References: <1468041333-30255-1-git-send-email-yin-jianhong@163.com>
Cc: Jianhong Yin <jiyin@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <b5964dc7-c8af-8ffc-dfd4-c1355d9d9292@RedHat.com>
Date: Mon, 18 Jul 2016 13:33:03 -0400
MIME-Version: 1.0
In-Reply-To: <1468041333-30255-1-git-send-email-yin-jianhong@163.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/09/2016 01:15 AM, Jianhong.Yin wrote:
> NFS does not support file and symbolic export, if the export point
> is regular file should give warning to user.
> 
> Signed-off-by: Jianhong Yin <jiyin@redhat.com>
> ---
>  utils/exportfs/exportfs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
Committed... 

steved.
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 5db348b..a00b5ea 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -585,8 +585,8 @@ validate_export(nfs_export *exp)
>  		xlog(L_ERROR, "Failed to stat %s: %m", path);
>  		return;
>  	}
> -	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
> -		xlog(L_ERROR, "%s is neither a directory nor a file. "
> +	if (!S_ISDIR(stb.st_mode)) {
> +		xlog(L_ERROR, "%s is not a directory. "
>  			"Remote access will fail", path);
>  		return;
>  	}
> 
