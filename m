Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33685 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934043Ab3DKK0t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2013 06:26:49 -0400
Received: by mail-wi0-f178.google.com with SMTP id ez12so378532wid.17
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2013 03:26:47 -0700 (PDT)
Message-ID: <51668FE4.5050501@tonian.com>
Date: Thu, 11 Apr 2013 13:26:44 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: fanchaoting <fanchaoting@cn.fujitsu.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsd: remove /proc/fs/nfs when create /proc/fs/nfs/exports
 error
References: <5152AE56.5010306@cn.fujitsu.com>
In-Reply-To: <5152AE56.5010306@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-27 10:31, fanchaoting wrote:
> when create /proc/fs/nfs/exports error, we should remove /proc/fs/nfs,
> if don't do it, it maybe cause Memory leak.
> 
>  Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
>  Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>

I merged this patch into pnfsd-block as well
to compliment
a55abd8 pnfsd-block: block layout should cleanup when register nfsd filesystem error

Thanks,

Benny

> 
> ---
>  fs/nfsd/nfsctl.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f33455b..58e4db4 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1102,8 +1102,10 @@ static int create_proc_exports_entry(void)
>  		return -ENOMEM;
>  	entry = proc_create("exports", 0, entry,
>  				 &exports_proc_operations);
> -	if (!entry)
> +	if (!entry) {
> +		remove_proc_entry("fs/nfs", NULL);
>  		return -ENOMEM;
> +	}
>  	return 0;
>  }
>  #else /* CONFIG_PROC_FS */
> 
