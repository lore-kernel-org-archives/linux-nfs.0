Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494Ab3I0Oov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Sep 2013 10:44:51 -0400
Date: Fri, 27 Sep 2013 10:44:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 08/49] pnfsd: layout verify
Message-ID: <20130927144448.GD9946@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220824-13047-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220824-13047-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:40:24PM -0400, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> Verify whether the server and file system support the given layout type.
> 
> [was pnfsd: Streamline error code checking for non-pnfs filesystems]
> Signed-off-by: Dean Hildebrand <seattleplus@gmail.com>
> [pnfsd: Add super block to layout_type()]
> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> [pnfsd: Fix order of ops in nfsd4_layout_verify]
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> [pnfsd: convert generic code to use new pnfs api]
> [pnfsd: define pnfs_export_operations]
> [pnfsd: obliterate old vfs api]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfsd: layout verify all layout types]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [pnfsd: tone nfsd4_layout_verify printk down to dprintk]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfsd: check ex_pnfs in nfsd4_verify_layout]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [pnfsd: handle s_pnfs_op==NULL]
> [pnfsd: verify export option only if svc_export is present]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/export.c                |  6 ++++++
>  fs/nfsd/nfs4proc.c              | 39 +++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/pnfsd.h                 |  2 ++
>  include/linux/nfsd/nfsd4_pnfs.h |  5 ++++-
>  4 files changed, 51 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 7730dfd..d803414 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -376,6 +376,12 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
>  		return -EINVAL;
>  	}
>  
> +	if (inode->i_sb->s_pnfs_op &&
> +	    !inode->i_sb->s_pnfs_op->layout_type) {
> +		dprintk("exp_export: export of invalid fs pnfs export ops.\n");
> +		return -EINVAL;
> +	}
> +

If you haven't already done it you may want to look at modifying
nfs-utils/utils/exportfs/exportfs.c:test_export() to add the pnfs option
when appropriate so the error can be returned at exportfs time.

>  	return 0;
>  
>  }
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 419572f..576b635 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -41,6 +41,7 @@
>  #include "vfs.h"
>  #include "current_stateid.h"
>  #include "netns.h"
> +#include "pnfsd.h"
>  
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>  #include <linux/security.h>
> @@ -1109,6 +1110,44 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  	return status == nfserr_same ? nfs_ok : status;
>  }
>  
> +#if defined(CONFIG_PNFSD)
> +static __be32
> +nfsd4_layout_verify(struct super_block *sb, struct svc_export *exp,
> +		    unsigned int layout_type)
> +{
> +	int status, type;
> +
> +	/* check to see if pNFS  is supported. */
> +	status = nfserr_layoutunavailable;
> +	if (exp && exp->ex_pnfs == 0) {

Can this really be called with exp == NULL?  If so don't you want to
fail that as well?

> +		dprintk("%s: Underlying file system "
> +			"is not exported over pNFS\n", __func__);
> +		goto out;
> +	}
> +	if (!sb->s_pnfs_op || !sb->s_pnfs_op->layout_type) {
> +		dprintk("%s: Underlying file system "
> +			"does not support pNFS\n", __func__);
> +		goto out;
> +	}
> +
> +	type = sb->s_pnfs_op->layout_type(sb);
> +
> +	/* check to see if requested layout type is supported. */
> +	status = nfserr_unknown_layouttype;
> +	if (!type)
> +		dprintk("BUG: %s: layout_type 0 is reserved and must not be "
> +			"used by filesystem\n", __func__);
> +	else if (type != layout_type)
> +		dprintk("%s: requested layout type %d "
> +		       "does not match supported type %d\n",
> +			__func__, layout_type, type);
> +	else
> +		status = nfs_ok;
> +out:
> +	return status;
> +}
> +#endif /* CONFIG_PNFSD */
> +
>  /*
>   * NULL call.
>   */
> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
> index 65fb57e..7c46791 100644
> --- a/fs/nfsd/pnfsd.h
> +++ b/fs/nfsd/pnfsd.h
> @@ -34,4 +34,6 @@
>  #ifndef LINUX_NFSD_PNFSD_H
>  #define LINUX_NFSD_PNFSD_H
>  
> +#include <linux/nfsd/nfsd4_pnfs.h>
> +
>  #endif /* LINUX_NFSD_PNFSD_H */
> diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
> index ff6613e..d44669e 100644
> --- a/include/linux/nfsd/nfsd4_pnfs.h
> +++ b/include/linux/nfsd/nfsd4_pnfs.h
> @@ -34,6 +34,8 @@
>  #ifndef _LINUX_NFSD_NFSD4_PNFS_H
>  #define _LINUX_NFSD_NFSD4_PNFS_H
>  
> +#include <linux/exportfs.h>
> +
>  /*
>   * pNFS export operations vector.
>   *
> @@ -45,7 +47,8 @@
>   * All other methods are optional and can be set to NULL if not implemented.
>   */
>  struct pnfs_export_operations {
> -	/* stub */
> +	/* Returns the supported pnfs_layouttype4. */
> +	int (*layout_type) (struct super_block *);
>  };
>  
>  #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
> -- 
> 1.8.3.1
> 
