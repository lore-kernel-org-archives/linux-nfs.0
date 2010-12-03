Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23304 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab0LCRfR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Dec 2010 12:35:17 -0500
Subject: Re: [PATCH] NFS: suppressing showing of default mount port value in /proc fixed
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101203170138.22955.86546.stgit@localhost6.localdomain6>
Date: Fri, 3 Dec 2010 12:35:04 -0500
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <7AF6FF7E-F57C-493B-8880-25509CC54EDE@oracle.com>
References: <20101203170138.22955.86546.stgit@localhost6.localdomain6>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 3, 2010, at 12:11 PM, Stanislav Kinsbursky wrote:

> Default value for mount server port is set to NFS_UNSPEC_PORT (-1) and will not
> be changed during parsing mount options for mound data version 6. This default
> value will be showed for mountport in /proc/mounts always since current default
> check is for zero value. This small mistake leads to big problem, because
> during umount.nfs execution from old user-space utils (at least nfs-utils
> 1.0.9) this value will be used as the server port to connect to. This request
> will be rejected (since port is 65535) and thus nfs mount point can't be
> unmounted.

Note: this is only possible if /etc/mtab is a link to /proc/mounts.  Not all systems have this configuration.

> 
> Kernel version affected: 2.6.37-rc4
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
> fs/nfs/super.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 6d6e21d..fd4cac8 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -681,7 +681,8 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
> 
> 	if (nfss->mountd_version || showdefaults)
> 		seq_printf(m, ",mountvers=%u", nfss->mountd_version);
> -	if (nfss->mountd_port || showdefaults)
> +	if (nfss->mountd_port != (unsigned short)NFS_UNSPEC_PORT ||
> +			showdefaults)
> 		seq_printf(m, ",mountport=%u", nfss->mountd_port);
> 
> 	nfs_show_mountd_netid(m, nfss, showdefaults);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




