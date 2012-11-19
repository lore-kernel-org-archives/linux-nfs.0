Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61917 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab2KSRmk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2012 12:42:40 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peter Staubach <pstaubach@exagrid.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [RFC PATCH 1/4] NFS: Add an ioctl to allow applications limited
 control over caching
Date: Mon, 19 Nov 2012 17:42:38 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF2FC@SACEXCMBX04-PRD.hq.netapp.com>
References: <1353033088-47163-1-git-send-email-Trond.Myklebust@netapp.com>
 <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C1D2D44D6@IT-1874.Isys.com>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C1D2D44D6@IT-1874.Isys.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> -----Original Message-----
> From: Peter Staubach [mailto:pstaubach@exagrid.com]
> Sent: Monday, November 19, 2012 11:53 AM
> To: Myklebust, Trond; linux-nfs@vger.kernel.org
> Subject: RE: [RFC PATCH 1/4] NFS: Add an ioctl to allow applications limited
> control over caching
> 
> Hi.
> 
> What application is having a problem which can be addressed via this support
> and what is the problem?

I've mainly heard complaints from the people who are trying to make distributed 'make' work well, but there have also been a few complaints from the MPIO crowd over the years.

O_DIRECT will generally satisfy the needs of the folks who want to do uncached I/O on regular files, however the caching of directories remains as problematic as ever. We don't have write delegations (although that wouldn't help the distributed make folks), and we have no locking primitives in NFS. The 'lookupcache=' and 'noac' client-side mount options do help mitigate some of the problems, but at a cost: revalidation is enforced on all lookups and attribute-related operations, and there is no option to target only the files/directories that are changing.

Adding a complete set of cache control primitives is the missing piece that will allow people to invent their own locking schemes in the form of user-space DLMs, and have them work safely on both directories and files. It should allow them to replace the many hacks that I've seen being used (and that often break when we fix caching bugs) with a documented API that we can actually support and standardise; at least across Linux-based NFS clients.

Cheers
  Trond

> 
> 	Thanx...
> 
> 		ps
> 
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Thursday, November 15, 2012 9:31 PM
> To: linux-nfs@vger.kernel.org
> Subject: [RFC PATCH 1/4] NFS: Add an ioctl to allow applications limited
> control over caching
> 
> Add an ioctl that allows an application to force the NFS client to revalidate the
> attributes and/or data for a regular file, or directory.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/Makefile   |  2 +-
>  fs/nfs/dir.c      |  4 +++
>  fs/nfs/file.c     |  4 +++
>  fs/nfs/internal.h |  3 ++
>  fs/nfs/ioctl.c    | 86
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/ioctl.h    | 35 ++++++++++++++++++++++
>  fs/nfs/nfs4file.c |  4 +++
>  7 files changed, 137 insertions(+), 1 deletion(-)  create mode 100644
> fs/nfs/ioctl.c  create mode 100644 fs/nfs/ioctl.h
> 
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile index b7db608..581db7a 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -7,7 +7,7 @@ obj-$(CONFIG_NFS_FS) += nfs.o
>  nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
>  			   direct.o pagelist.o read.o symlink.o unlink.o \
>  			   write.o namespace.o mount_clnt.o \
> -			   dns_resolve.o cache_lib.o
> +			   dns_resolve.o cache_lib.o ioctl.o
>  nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
>  nfs-$(CONFIG_SYSCTL)	+= sysctl.o
>  nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o diff --git
> a/fs/nfs/dir.c b/fs/nfs/dir.c index ce8cb92..10ad886 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -58,6 +58,10 @@ const struct file_operations nfs_dir_operations = {
>  	.open		= nfs_opendir,
>  	.release	= nfs_closedir,
>  	.fsync		= nfs_fsync_dir,
> +	.unlocked_ioctl = nfs_ioctl,
> +#ifdef CONFIG_COMPAT
> +	.compat_ioctl	= nfs_ioctl,
> +#endif
>  };
> 
>  const struct address_space_operations nfs_dir_aops = { diff --git
> a/fs/nfs/file.c b/fs/nfs/file.c index 582bb88..deefa62 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -925,5 +925,9 @@ const struct file_operations nfs_file_operations = {
>  	.splice_write	= nfs_file_splice_write,
>  	.check_flags	= nfs_check_flags,
>  	.setlease	= nfs_setlease,
> +	.unlocked_ioctl = nfs_ioctl,
> +#ifdef CONFIG_COMPAT
> +	.compat_ioctl	= nfs_ioctl,
> +#endif
>  };
>  EXPORT_SYMBOL_GPL(nfs_file_operations);
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h index e1827b0..4b425bd
> 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -481,6 +481,9 @@ extern int nfs41_walk_client_list(struct nfs_client
> *clp,
>  				struct nfs_client **result,
>  				struct rpc_cred *cred);
> 
> +/* ioctl.c */
> +extern long nfs_ioctl(struct file *filp, unsigned int cmd, unsigned
> +long arg);
> +
>  /*
>   * Determine the device name as a string
>   */
> diff --git a/fs/nfs/ioctl.c b/fs/nfs/ioctl.c new file mode 100644 index
> 0000000..9da5f7d
> --- /dev/null
> +++ b/fs/nfs/ioctl.c
> @@ -0,0 +1,86 @@
> +/*
> + * linux/fs/nfs/ioctl.c
> + *
> + * Copyright (C) 2012 Trond Myklebust <Trond.Myklebust@netapp.com>
> + *
> + * nfs ioctl implementation
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/fs.h>
> +#include <linux/nfs_fs.h>
> +#include "internal.h"
> +#include "ioctl.h"
> +
> +static long nfs_ioctl_cache_revalidate(struct file *filp, bool
> +metadata, bool data) {
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	umode_t mode = inode->i_mode;
> +	unsigned long invalid = 0;
> +	long ret = -EINVAL;
> +
> +	if (metadata)
> +		invalid |= NFS_INO_INVALID_ATTR
> +			| NFS_INO_INVALID_ACCESS
> +			| NFS_INO_INVALID_ACL;
> +	if (data)
> +		invalid |= NFS_INO_INVALID_DATA;
> +
> +	switch (mode & S_IFMT) {
> +	default:
> +		goto out;
> +	case S_IFDIR:
> +		spin_lock(&inode->i_lock);
> +		if (data)
> +			nfsi->cache_change_attribute++;
> +		nfsi->cache_validity |= invalid;
> +		spin_unlock(&inode->i_lock);
> +		break;
> +	case S_IFREG:
> +		vfs_fsync(filp, 1);
> +		if (data)
> +			invalid |= NFS_INO_REVAL_PAGECACHE;
> +	case S_IFLNK:
> +		spin_lock(&inode->i_lock);
> +		nfsi->cache_validity |= invalid;
> +		spin_unlock(&inode->i_lock);
> +	}
> +	ret = nfs_revalidate_inode(NFS_SERVER(inode), inode);
> +	if (ret == 0)
> +		ret = nfs_revalidate_mapping(inode, filp->f_mapping);
> +
> +out:
> +	return ret;
> +}
> +
> +static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl
> +__user *argp) {
> +	u64 cmd;
> +
> +	if (!(filp->f_mode & (FMODE_READ|FMODE_WRITE)))
> +		return -EBADF;
> +	if (get_user(cmd, &argp->cmd))
> +		return -EFAULT;
> +	switch (cmd) {
> +	case NFS_CACHECTL_REVALIDATE_ALL:
> +		return nfs_ioctl_cache_revalidate(filp, true, true);
> +	case NFS_CACHECTL_REVALIDATE_METADATA:
> +		return nfs_ioctl_cache_revalidate(filp, true, false);
> +	case NFS_CACHECTL_REVALIDATE_DATA:
> +		return nfs_ioctl_cache_revalidate(filp, false, true);
> +	}
> +	return -EINVAL;
> +}
> +
> +long nfs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
> +{
> +	void __user *argp = (void __user *)arg;
> +
> +	switch (cmd) {
> +	case NFS_IOC_CACHECTL:
> +		return nfs_ioctl_cachectl(filp, argp);
> +	}
> +	return -ENOTTY;
> +}
> diff --git a/fs/nfs/ioctl.h b/fs/nfs/ioctl.h new file mode 100644 index
> 0000000..cf79f0d
> --- /dev/null
> +++ b/fs/nfs/ioctl.h
> @@ -0,0 +1,35 @@
> +/*
> + * linux/fs/nfs/ioctl.h
> + *
> + * Copyright (C) 2012 Trond Myklebust <Trond.Myklebust@netapp.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public
> + * License v2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public
> + * License along with this program; if not, write to the
> + * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
> + * Boston, MA 021110-1307, USA.
> + *
> + * nfs ioctl definitions
> + *
> + */
> +
> +#include <uapi/linux/ioctl.h>
> +
> +/* Cache revalidation modes */
> +#define NFS_CACHECTL_REVALIDATE_ALL		1
> +#define NFS_CACHECTL_REVALIDATE_METADATA	2
> +#define NFS_CACHECTL_REVALIDATE_DATA		3
> +
> +struct nfs_cachectl {
> +	u64 cmd;
> +};
> +
> +#define NFS_IOC_CACHECTL	_IOW('N', 1, struct nfs_cachectl)
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c index e769930..b221690 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -133,4 +133,8 @@ const struct file_operations nfs4_file_operations = {
>  	.splice_write	= nfs_file_splice_write,
>  	.check_flags	= nfs_check_flags,
>  	.setlease	= nfs_setlease,
> +	.unlocked_ioctl = nfs_ioctl,
> +#ifdef CONFIG_COMPAT
> +	.compat_ioctl	= nfs_ioctl,
> +#endif
>  };
> --
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
