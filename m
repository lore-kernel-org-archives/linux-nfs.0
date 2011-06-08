Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40139 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab1FHCBn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 22:01:43 -0400
Received: by vws1 with SMTP id 1so35573vws.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 19:01:42 -0700 (PDT)
Message-ID: <4DEED80A.4000102@panasas.com>
Date: Tue, 07 Jun 2011 22:01:46 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
In-Reply-To: <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NAK.
This affects all layout types.  In particular it is undesired
for write layouts that extend the file with the objects layout.
The server can extend the layout segments range
over what the client requested so why would the client
ask for artificially large layouts?

Benny

On 2011-06-07 13:36, Jim Rees wrote:
> From: Peng Tao <peng_tao@emc.com>
> 
> pnfs_layout_prefetch_kb can be modified via sysctl.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/pnfs.c   |   17 +++++++++++++++++
>  fs/nfs/pnfs.h   |    1 +
>  fs/nfs/sysctl.c |   10 ++++++++++
>  3 files changed, 28 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 9920bff..9c2b569 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -46,6 +46,11 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
>   */
>  static LIST_HEAD(pnfs_modules_tbl);
>  
> +/*
> + * layoutget prefetch size
> + */
> +unsigned int pnfs_layout_prefetch_kb = 2 << 10;
> +
>  /* Return the registered pnfs layout driver module matching given id */
>  static struct pnfs_layoutdriver_type *
>  find_pnfs_driver_locked(u32 id)
> @@ -906,6 +911,16 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
>  }
>  
>  /*
> + * Set layout prefetch length.
> + */
> +static void
> +pnfs_set_layout_prefetch(struct pnfs_layout_range *range)
> +{
> +	if (range->length < (pnfs_layout_prefetch_kb << 10))
> +		range->length = pnfs_layout_prefetch_kb << 10;
> +}
> +
> +/*
>   * Layout segment is retreived from the server if not cached.
>   * The appropriate layout segment is referenced and returned to the caller.
>   */
> @@ -956,6 +971,8 @@ pnfs_update_layout(struct inode *ino,
>  
>  	if (pnfs_layoutgets_blocked(lo, NULL, 0))
>  		goto out_unlock;
> +
> +	pnfs_set_layout_prefetch(&arg);
>  	atomic_inc(&lo->plh_outstanding);
>  
>  	get_layout_hdr(lo);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 28d57c9..563c67b 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -182,6 +182,7 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>  extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
>  
>  /* pnfs.c */
> +extern unsigned int pnfs_layout_prefetch_kb;
>  void get_layout_hdr(struct pnfs_layout_hdr *lo);
>  void put_lseg(struct pnfs_layout_segment *lseg);
>  struct pnfs_layout_segment *
> diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
> index 978aaeb..79a5134 100644
> --- a/fs/nfs/sysctl.c
> +++ b/fs/nfs/sysctl.c
> @@ -14,6 +14,7 @@
>  #include <linux/nfs_fs.h>
>  
>  #include "callback.h"
> +#include "pnfs.h"
>  
>  #ifdef CONFIG_NFS_V4
>  static const int nfs_set_port_min = 0;
> @@ -42,6 +43,15 @@ static ctl_table nfs_cb_sysctls[] = {
>  	},
>  #endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
>  #endif
> +#ifdef CONFIG_NFS_V4_1
> +	{
> +		.procname	= "pnfs_layout_prefetch_kb",
> +		.data		= &pnfs_layout_prefetch_kb,
> +		.maxlen		= sizeof(pnfs_layout_prefetch_kb),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +#endif
>  	{
>  		.procname	= "nfs_mountpoint_timeout",
>  		.data		= &nfs_mountpoint_expiry_timeout,
