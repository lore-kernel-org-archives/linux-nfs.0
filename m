Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:49547 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337Ab2CEVUa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 16:20:30 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 5 Mar 2012 16:20:28 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id EB4806E8051
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 16:20:16 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25LKGdS226912
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 16:20:16 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25LKGSn006304
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 16:20:16 -0500
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q25LKGGq006275
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 16:20:16 -0500
Date: Mon, 5 Mar 2012 15:20:15 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
Message-ID: <20120305212015.GA21904@us.ibm.com>
References: <1330976165-19849-1-git-send-email-steved@redhat.com>
 <1330976165-19849-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330976165-19849-2-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [steved@redhat.com] wrote:
> So path names are found during umounts, normalize
> path names by removing any extra slashes and add
> a lead slash if one does not exist.
> 
> This normalization only has to occur when the mtab
> and /proc/mounts are not the same file.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/nfsumount.c |   64 +++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 62 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
> index 3538d88..0f77261 100644
> --- a/utils/mount/nfsumount.c
> +++ b/utils/mount/nfsumount.c
> @@ -140,6 +140,52 @@ static int del_mtab(const char *spec, const char *node)
>  }
> 
>  /*
> + * To ensure the path is found during unmounts, strip
> + * off the multiple '/' or add a '/' if one does not exist.
> + */
> +static inline char *
> +normalize_path(char *spec) 
> +{
> +	char *colen, *ptr, *str, *dev;
> +
> +	if ((colen = strchr(spec, ':')) == NULL)
> +		return NULL;
> +
> +	if (*(colen + 1) != '/') {
> +		dev = str = malloc(strlen(spec) + 2);
> +		if (dev == NULL) 
> +			return NULL;
> +
> +		ptr = spec;
> +		while (ptr <= colen)
> +			*(str++) = *(ptr++);
> +		*str++='/';
> +		while (*ptr)
> +			*(str++) = *(ptr++);
> +		*str='\0';
> +
> +		return dev;
> +	}
> +
> +	if (strstr(spec, "//") != NULL) {
> +		dev = strdup(spec);
> +		if (dev == NULL)
> +			return NULL;
> +
> +		colen = strchr(dev, ':');
> +		ptr = (colen +1);
> +		while (*ptr && *(ptr+1) == '/')
> +			ptr++;
> +		while (*ptr)
> +			*(++colen) = *(ptr++);
> +		*(colen+1) = '\0';
> +
> +		return dev;
> +	} 
> +	return NULL;
> +}
> +
> +/*
>   * Detect NFSv4 mounts.
>   *
>   * Consult /proc/mounts to determine if the mount point
> @@ -154,6 +200,7 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
>  	struct mntentchn *pmc;
>  	struct mount_options *options;
>  	int retval;
> +	char *normpath=NULL;
> 
>  	retval = -1;
>  	pmc = getprocmntdirbackward(mc->m.mnt_dir, NULL);
> @@ -171,8 +218,20 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
>  		 */
>  		while (pmc->m.mnt_fsname[nlen - 1] == '/')
>  			nlen--;
> -		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
> -			continue;
> +		/*
> +		 * When the mtab and /proc/mounts are not the same
> +		 * file, normalize the path in the mtab if needed.
> +		 */
> +		if (mtab_is_writable())
> +			normpath = normalize_path(mc->m.mnt_fsname);
> +
> +		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0) {
> +			/* Is there a normalized path, if so compare that one too */
> +			if (normpath == NULL)
> +				continue;
> +			if (strncmp(pmc->m.mnt_fsname, normpath, nlen) != 0)
> +				continue;

You need to free normpath here before the "continue".

Also, when you normalize, why not go the extra mile of doing it all the
way as the patch I posted? I wanted to cover specs like
"host:/server/../home/./blah". This patch only does partial
normalization. The original patch also normalizes /proc/mount entry's
pathname (this avoids dealing with trailing '/' hack that exists now).

