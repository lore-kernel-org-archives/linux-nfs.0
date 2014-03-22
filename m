Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbaCVONx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 10:13:53 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2MEDrfR028147
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 22 Mar 2014 10:13:53 -0400
Message-ID: <532D9A9F.5050703@RedHat.com>
Date: Sat, 22 Mar 2014 10:13:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] mount: chk_mountpoint should only check for
 execute perms for unpriveleged users
References: <1395346354-64069-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1395346354-64069-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/20/2014 04:12 PM, Scott Mayhew wrote:
> Otherwise 'mount -o remount' fails on mounts that have root squashing
> enabled and world execute perms disabled.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.
> ---
>  utils/mount/utils.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/mount/utils.c b/utils/mount/utils.c
> index ede77a8..92662ed 100644
> --- a/utils/mount/utils.c
> +++ b/utils/mount/utils.c
> @@ -130,7 +130,7 @@ int chk_mountpoint(const char *mount_point)
>  		mount_error(NULL, mount_point, ENOTDIR);
>  		return 1;
>  	}
> -	if (access(mount_point, X_OK) < 0) {
> +	if (getuid() != 0 && geteuid() != 0 && access(mount_point, X_OK) < 0) {
>  		mount_error(NULL, mount_point, errno);
>  		return 1;
>  	}
> -- 1.7.11.7 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html
> 
