Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1034023AbeCASx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Mar 2018 13:53:56 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0C6317D852
        for <linux-nfs@vger.kernel.org>; Thu,  1 Mar 2018 18:53:56 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E15F110AF9E7
        for <linux-nfs@vger.kernel.org>; Thu,  1 Mar 2018 18:53:55 +0000 (UTC)
Subject: Re: [PATCH 1/1 V2] mount.nfs: minorversion setting is being ignored
 with the -t flag
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180227221318.4866-1-steved@redhat.com>
 <20180227221318.4866-2-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <15462942-6d1c-ae7a-939c-76b0d285bab4@RedHat.com>
Date: Thu, 1 Mar 2018 13:53:55 -0500
MIME-Version: 1.0
In-Reply-To: <20180227221318.4866-2-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/27/2018 05:13 PM, Steve Dickson wrote:
> mount -t nfs or mount -t nfs4 and setting minorversion
> should set the v4 minor version. This patch adds a few
> checks to make sure the minor version is set.
> 
> The patch also translate the minorversion= option
> to vers=4.x in the arguments passed to the kernel
> when the kernel is later then v3.4.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/mount/network.c | 15 ++++++++++-----
>  utils/mount/stropts.c | 15 +++++++++++++++
>  2 files changed, 25 insertions(+), 5 deletions(-)
> 
> v1:
>  Added kernel version check
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 8ab5be8..8d6e4c6 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1275,8 +1275,8 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
>  		}
>  	}
>  
> -	if (!found && strcmp(type, "nfs4") == 0)
> -		version_val = type + 3;
> +	if (!found && strncmp(type, "nfs", 3) == 0)
> +		version_val = "4";
>  	else if (!found)
>  		return 1;
>  	else if (i <= 2 ) {
> @@ -1308,9 +1308,14 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
>  		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
>  			goto ret_error;
>  		version->v_mode = V_SPECIFIC;
> -	} else if (version->major > 3 && *cptr == '\0')
> -		version->v_mode = V_GENERAL;
> -
> +	} else if (version->major > 3 && *cptr == '\0') {
> +		version_val = po_get(options, "minorversion");
> +		if (version_val != NULL) {
> +			version->minor = strtol(version_val, &cptr, 10);
> +			version->v_mode = V_SPECIFIC;
> +		} else 
> +			version->v_mode = V_GENERAL;
> +	}
>  	if (*cptr != '\0')
>  		goto ret_error;
>  
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 777de39..d1b0708 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -767,6 +767,21 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>  			mi->version.minor);
>  #pragma GCC diagnostic warning "-Wformat-nonliteral"
>  
> +		if (po_append(options, version_opt) == PO_FAILED) {
> +			errno = EINVAL;
> +			goto out_fail;
> +		}
> +	} else if (po_get(options, "minorversion") &&
> +		linux_version_code() > MAKE_VERSION(3, 4, 0)) {
> +		/*
> +	 	 * convert minorversion= into vers=4.x
> +	 	 */
> +		po_remove_all(options, "minorversion");
> +
> +		snprintf(version_opt, sizeof(version_opt) - 1,
> +			"vers=%lu.%lu", mi->version.major,
> +			mi->version.minor);
> +
>  		if (po_append(options, version_opt) == PO_FAILED) {
>  			errno = EINVAL;
>  			goto out_fail;
> 
