Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50282 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751124AbdFUQZ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Jun 2017 12:25:57 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4C16461D24
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jun 2017 16:19:33 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-227.phx2.redhat.com [10.3.116.227])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 12FB75D961
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jun 2017 16:19:32 +0000 (UTC)
Subject: Re: [PATCH 2/2 V4] mount.nfs: Use default minor version when -o v4 is
 specified
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170619152526.26260-1-steved@redhat.com>
 <20170619152526.26260-2-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d0ff22e8-b366-1caf-d4ec-9479f24f9be2@RedHat.com>
Date: Wed, 21 Jun 2017 12:19:32 -0400
MIME-Version: 1.0
In-Reply-To: <20170619152526.26260-2-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/19/2017 11:25 AM, Steve Dickson wrote:
> When v4 is specified on the command line the
> default minor version needs to be used.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/stropts.c | 24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)
> 
> v2: Removed pointless check of v_mode in nfs_do_mount_v4()
> v3: Correctly set the minor version when set in nfsmount.conf
> v4: Post the correct patch!!! 
Committed...

steved. 
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index fbea6fb..c2a739b 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_info *mi)
>  	if (mi->version.v_mode == V_DEFAULT &&
>  		config_default_vers.v_mode != V_DEFAULT) {
>  		mi->version.major = config_default_vers.major;
> -		mi->version.minor = config_default_vers.minor;
> +		if (config_default_vers.v_mode == V_SPECIFIC)
> +			mi->version.minor = config_default_vers.minor;
> +		else
> +			mi->version.minor = NFS_DEFAULT_MINOR;
>  		return;
>  	}
>  
>  	if (mi->version.v_mode == V_GENERAL) {
>  		if (config_default_vers.v_mode != V_DEFAULT &&
> -		    mi->version.major == config_default_vers.major)
> -			mi->version.minor = config_default_vers.minor;
> +		    mi->version.major == config_default_vers.major) {
> +			if (config_default_vers.v_mode == V_SPECIFIC)
> +				mi->version.minor = config_default_vers.minor;
> +			else
> +				mi->version.minor = NFS_DEFAULT_MINOR;
> +		} else
> +			mi->version.minor = NFS_DEFAULT_MINOR;
>  		return;
>  	}
>  
> @@ -741,13 +749,9 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>  	}
>  
>  	if (mi->version.v_mode != V_SPECIFIC) {
> -		if (mi->version.v_mode == V_GENERAL)
> -			snprintf(version_opt, sizeof(version_opt) - 1,
> -				"vers=%lu", mi->version.major);
> -		else
> -			snprintf(version_opt, sizeof(version_opt) - 1,
> -				"vers=%lu.%lu", mi->version.major,
> -				mi->version.minor);
> +		snprintf(version_opt, sizeof(version_opt) - 1,
> +			"vers=%lu.%lu", mi->version.major,
> +			mi->version.minor);
>  
>  		if (po_append(options, version_opt) == PO_FAILED) {
>  			errno = EINVAL;
> 
