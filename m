From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1.5/2] mount: Remove MOUNT_CONFIG warning
Date: Sat, 05 Mar 2011 16:24:32 -0500
Message-ID: <4D72AA10.5010004@RedHat.com>
References: <1299159822-25190-1-git-send-email-kzak@redhat.com> <1299159822-25190-2-git-send-email-kzak@redhat.com> <4D6FF3F4.8040602@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Karel Zak <kzak@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752341Ab1CEVYg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Mar 2011 16:24:36 -0500
In-Reply-To: <4D6FF3F4.8040602-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Karel,

On 03/03/2011 03:03 PM, Steve Dickson wrote:
> The following changes are needed to remove compile warnings when
> MOUNT_CONFIG is not define
Don't worry about this one... I just committed it.. 

steved.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/utils/mount/mount_config.h b/utils/mount/mount_config.h
> index e86b4ba..69ffd1e 100644
> --- a/utils/mount/mount_config.h
> +++ b/utils/mount/mount_config.h
> @@ -39,10 +39,10 @@ static inline char *mount_config_opts(char *spec,
>  
>  #else /* MOUNT_CONFIG */
>  
> -static inline void mount_config_init(char *program) { }
> +static inline void mount_config_init(__attribute__ ((unused)) char *program) { }
>  
> -static inline char *mount_config_opts(char *spec,
> -		char *mount_point, char *mount_opts)
> +static inline char *mount_config_opts(__attribute__ ((unused)) char *spec,
> +		__attribute__ ((unused)) char *mount_point, char *mount_opts)
>  {
>  	return mount_opts;
>  }
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index e314b82..f1aa503 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -110,7 +110,7 @@ static void nfs_default_version(struct nfsmount_info *mi)
>  	}
>  }
>  #else
> -inline void nfs_default_version(struct nfsmount_info *mi) {}
> +inline void nfs_default_version(__attribute__ ((unused)) struct nfsmount_info *mi) {}
>  #endif /* MOUNT_CONFIG */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
