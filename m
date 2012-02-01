Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52945 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208Ab2BAWok (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 17:44:40 -0500
Message-ID: <4F29C04B.8020703@panasas.com>
Date: Thu, 2 Feb 2012 00:44:27 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
References: <1328123201-894-1-git-send-email-dros@netapp.com>
In-Reply-To: <1328123201-894-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/01/2012 09:06 PM, Weston Andros Adamson wrote:
> Don't allow invalid 'vers' and 'minorversion' combinations in mount options,
> such as "vers=3,minorversion=1".
> 

Just my $0.017 I don't see the point in this. 

If vers==3 then minorversion is ignored, just like today.
What kind  of extra protection does it buy us?

But maybe it's just me

Thanks
Boaz

> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> %d -> %u for printing mnt->version.
> 
>  fs/nfs/super.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 8e210b2..b88e023 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1519,6 +1519,9 @@ static int nfs_parse_mount_options(char *raw,
>  	if (!sloppy && invalid_option)
>  		return 0;
>  
> +	if (mnt->minorversion && mnt->version != 4)
> +		goto out_minorversion_mismatch;
> +
>  	/*
>  	 * verify that any proto=/mountproto= options match the address
>  	 * familiies in the addr=/mountaddr= options.
> @@ -1552,6 +1555,10 @@ out_invalid_address:
>  out_invalid_value:
>  	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
>  	return 0;
> +out_minorversion_mismatch:
> +	printk(KERN_INFO "NFS: mount option vers=%u does not support "
> +			 "minorversion=%u\n", mnt->version, mnt->minorversion);
> +	return 0;
>  out_nomem:
>  	printk(KERN_INFO "NFS: not enough memory to parse option\n");
>  	return 0;

