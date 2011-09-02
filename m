Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724Ab1IBXYB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Sep 2011 19:24:01 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] nfs: Enclose hostname in brackets when needed in nfs_do_root_mount
Date: Fri, 2 Sep 2011 16:23:43 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AFD3952@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <1315004983-10271-1-git-send-email-jack@suse.cz>
References: <1315004983-10271-1-git-send-email-jack@suse.cz>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jan Kara" <jack@suse.cz>
Cc: <linux-nfs@vger.kernel.org>, "Josh Boyer" <jwboyer@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Jan Kara [mailto:jack@suse.cz]
> Sent: Friday, September 02, 2011 7:10 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; Jan Kara; Josh Boyer; Myklebust, Trond
> Subject: [PATCH] nfs: Enclose hostname in brackets when needed in
> nfs_do_root_mount
> 
> When hostname contains colon (e.g. when it is an IPv6 address) it
needs
> to be enclosed in brackets to make parsing of NFS device string
> possible.
> Fix nfs_do_root_mount() to enclose hostname properly when needed. NFS
> code
> actually does not need this as it does not parse the string passed by
> nfs_do_root_mount() but the device string is exposed to userspace in
> /proc/mounts.
> 
> CC: Josh Boyer <jwboyer@redhat.com>
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/nfs/super.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b961cea..42b74f8 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2694,11 +2694,15 @@ static struct vfsmount
> *nfs_do_root_mount(struct file_system_type *fs_type,
>  	char *root_devname;
>  	size_t len;
> 
> -	len = strlen(hostname) + 3;
> +	len = strlen(hostname) + 5;
>  	root_devname = kmalloc(len, GFP_KERNEL);
>  	if (root_devname == NULL)
>  		return ERR_PTR(-ENOMEM);
> -	snprintf(root_devname, len, "%s:/", hostname);
> +	/* Does hostname needs to be enclosed in brackets? */
> +	if (strchr(hostname, ':'))
> +		snprintf(root_devname, len, "[%s]:/", hostname);
> +	else
> +		snprintf(root_devname, len, "%s:/", hostname);

What if the hostname is already enclosed in brackets, as is usually the
case if I enter an IPv6 address instead of a DNS name? Won't this cause
it to be bracketed twice?

IOW: If I try to

	mount -t nfs [fe80::20c:29ff:fee9:83e6]:/export /mnt

won't the above end up returning a hostname of [[::20c:29ff:fee9:83e6]]?

Cheers
   Trond
