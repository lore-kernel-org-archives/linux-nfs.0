Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34722 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037Ab2BCLPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2012 06:15:38 -0500
Message-ID: <4F2BC1C0.8070900@panasas.com>
Date: Fri, 3 Feb 2012 13:15:12 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Malahal Naineni <malahal@us.ibm.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Check for beginning '/' in the mount path
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/03/2012 03:42 AM, Malahal Naineni wrote:
> NFSv4 gladly accepts and mounts "hostname:path" instead of
> "hostname:/path". This causes mount entry mistmatch between /etc/mtab
> and /proc/mounts files. The former will have "hostname:path" but the
> latter will have "hostname:/path". This causes umount not work at all.
> 

NACK

like it or not you are changing ABI. Bunch of systems will not work now.

Also some other NFS servers/clients support it fine. Actually some servers
make it a special case. (It's called mount by tag)

The bug is else where fix it there. Either add the preceding '/' to
/etc/mtab or remove it from /proc/mounts (I prefer the later). Or
fix umount to work with that case.

It's just a bug please fix it.

Boaz

> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  utils/mount/stropts.c |   22 ++++++++++++++++++++++
>  1 files changed, 22 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index d52e21a..559114d 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -571,6 +571,7 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
>  {
>  	char *options = NULL;
>  	int result;
> +	char *dirname;
>  
>  	if (mi->fake)
>  		return 1;
> @@ -580,6 +581,27 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
>  		return 0;
>  	}
>  
> +	/*
> +	 * Make sure that dirname in the spec starts with '/'. The mount
> +	 * works fine in NFSv4 without the '/', but then /etc/mtab and
> +	 * /proc/mounts disagree on the actual mount entry causing later
> +	 * umount to fail! There is no reason to allow any dirname not
> +	 * starting with '/', so fail it here.
> +	 *
> +	 * Note that for NFSv2 and NFSv3, the mount call itself fails if
> +	 * dirname doesn't start with '/'. So this check is only useful
> +	 * for NFSv4.
> +	 */
> +	dirname = strchr(mi->spec, ']');	/* IPv6 address check */
> +	if (dirname)
> +		dirname = strchr(dirname+1, ':');
> +	else
> +		dirname = strchr(mi->spec, ':');
> +	if (!dirname || *(dirname+1) != '/') {
> +		errno = EINVAL;
> +		return 0;
> +	}
> +
>  	result = mount(mi->spec, mi->node, mi->type,
>  			mi->flags & ~(MS_USER|MS_USERS), options);
>  	free(options);

