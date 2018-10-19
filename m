Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37388 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727338AbeJTBoG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 21:44:06 -0400
Subject: Re: [PATCH] [nfs-utils] fix issue: mount -osharecache failure but
 return 'true'
To: jiyin@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
References: <20181019080354.26141-1-jiyin@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <907dd179-13d7-071e-8c60-eb9915762299@RedHat.com>
Date: Fri, 19 Oct 2018 13:36:59 -0400
MIME-Version: 1.0
In-Reply-To: <20181019080354.26141-1-jiyin@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/19/18 4:03 AM, jiyin@redhat.com wrote:
> From: "Jianhong.Yin" <yin-jianhong@163.com>
> 
> see: https://bugzilla.redhat.com/show_bug.cgi?id=1629705
> mount.nfs4 -o context=system_u:object_r:user_home_dir_t:s0,sharecache $serv:$expdir $nfsmp
> mount.nfs4 -o context=system_u:object_r:xferlog_t:s0,sharecache $serv:$expdir $nfsmp2
> ^^^ here mount fail, but return true. it confuse user!
Why should it fail? Two different mounts are being used and using -o sharecache 
which is the default the way...

steved.
> 
> according: https://patchwork.kernel.org/patch/10602607/#22234047
> add function is_mounted_already()
> -		if (errno == EBUSY)
> +		if (errno == EBUSY && is_mounted_already(mi->spec, mi->node))
> 			return EX_SUCCESS;
> 
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> ---
>  utils/mount/stropts.c | 31 ++++++++++++++++++++++++-------
>  1 file changed, 24 insertions(+), 7 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 4d2e37e..4be7e61 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -48,6 +48,7 @@
>  #include "version.h"
>  #include "parse_dev.h"
>  #include "conffile.h"
> +#include <mntent.h>
>  
>  #ifndef NFS_PROGRAM
>  #define NFS_PROGRAM	(100003)
> @@ -1056,6 +1057,27 @@ static int nfs_is_permanent_error(int error)
>  	}
>  }
>  
> +static int is_mounted_already(const char *fsname, const char *dir)
> +{
> +	struct mntent *ent;
> +	FILE *fp;
> +	int ret = 0;
> +
> +	fp = setmntent("/proc/mounts", "r");
> +	if (fp == NULL) {
> +		perror("[unlikely] setmntent(3) fail");
> +		exit(1);
> +	}
> +	while (NULL != (ent = getmntent(fp))) {
> +		if (!strcmp(ent->mnt_fsname, fsname) && !strcmp(ent->mnt_dir, dir)) {
> +			ret = 1;
> +			break;
> +		}
> +	}
> +	endmntent(fp);
> +	return ret;
> +}
> +
>  /*
>   * Handle "foreground" NFS mounts.
>   *
> @@ -1078,13 +1100,8 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>  		if (nfs_try_mount(mi))
>  			return EX_SUCCESS;
>  
> -		if (errno == EBUSY)
> -			/* The only cause of EBUSY is if exactly the desired
> -			 * filesystem is already mounted.  That can arguably
> -			 * be seen as success.  "mount -a" tries to optimise
> -			 * out this case but sometimes fails.  Help it out
> -			 * by pretending everything is rosy
> -			 */
> +		/* if EBUSY is caused by re-mount, ignore the error */
> +		if (errno == EBUSY && is_mounted_already(mi->spec, mi->node))
>  			return EX_SUCCESS;
>  
>  		if (nfs_is_permanent_error(errno))
> 
