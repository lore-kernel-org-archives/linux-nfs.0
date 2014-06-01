Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbaFARNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Jun 2014 13:13:15 -0400
Message-ID: <538B5F28.2000100@RedHat.com>
Date: Sun, 01 Jun 2014 13:13:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mount.nfs: print more useful error message
References: <537AD1E7.6080404@gmail.com>
In-Reply-To: <537AD1E7.6080404@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/19/2014 11:54 PM, Kinglong Mee wrote:
> When mounting spec of a regular file, mount.nfs print error message as,
> 
> # mount -t nfs 127.0.0.1:/root/testfile /mnt/
> mount.nfs: mount point /mnt is not a directory
> # mount -t nfs 127.0.0.1:/root/testfile /mnt/testfile
> mount.nfs: mount point /mnt/testfile is not a directory
> 
> This patch lets mount.nfs print more useful message,
> 
> # mount -t nfs 127.0.0.1:/root/testfile /mnt/
> mount.nfs: mount spec 127.0.0.1:/root/testfile or point /mnt is not a directory
> # mount -t nfs 127.0.0.1:/root/testfile /mnt/testfile
> mount.nfs: mount point /mnt/testfile is not a directory
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... 

steved.

> ---
>  utils/mount/error.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/error.c b/utils/mount/error.c
> index f8fc13f..e06f598 100644
> --- a/utils/mount/error.c
> +++ b/utils/mount/error.c
> @@ -215,8 +215,12 @@ void mount_error(const char *spec, const char *mount_point, int error)
>  				progname);
>  		break;
>  	case ENOTDIR:
> -		nfs_error(_("%s: mount point %s is not a directory"),
> -				progname, mount_point);
> +		if (spec)
> +			nfs_error(_("%s: mount spec %s or point %s is not a "
> +				  "directory"),	progname, spec, mount_point);
> +		else
> +			nfs_error(_("%s: mount point %s is not a directory"),
> +				  progname, mount_point);
>  		break;
>  	case EBUSY:
>  		nfs_error(_("%s: %s is busy or already mounted"),
> 
