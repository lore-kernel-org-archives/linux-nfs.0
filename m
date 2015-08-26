Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:38688 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751363AbbHZWtL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 18:49:11 -0400
Date: Thu, 27 Aug 2015 08:48:53 +1000
From: Dave Chinner <david@fromorbit.com>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH-RFC-RESEND 5/9] nfs42: add .copy_range file operation
Message-ID: <20150826224853.GW714@dastard>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-6-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1440577010-122867-6-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 04:16:46PM +0800, Peng Tao wrote:
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/nfs4file.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 50 insertions(+)
> 
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index dcd39d4..c335cb0 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -4,6 +4,7 @@
>   *  Copyright (C) 1992  Rick Sladkey
>   */
>  #include <linux/fs.h>
> +#include <linux/file.h>
>  #include <linux/falloc.h>
>  #include <linux/nfs_fs.h>
>  #include "internal.h"
> @@ -166,6 +167,54 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
>  		return nfs42_proc_deallocate(filep, offset, len);
>  	return nfs42_proc_allocate(filep, offset, len);
>  }
> +
> +static noinline int
> +nfs42_file_clone_range(struct file *src_file, struct file *dst_file,
> +		       loff_t src_off, size_t dst_off, loff_t count)
> +{
> +	struct inode *dst_inode = file_inode(dst_file);
> +	struct inode *src_inode = file_inode(src_file);
> +	int ret;
> +
> +	/* src and dst must be different files */
> +	if (src_inode == dst_inode)
> +		return -EINVAL;
> +
> +	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
> +	if (dst_inode < src_inode) {
> +		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
> +		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
> +	} else {
> +		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_PARENT);
> +		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_CHILD);
> +	}

Is that safe? Between two operations, the inode code be reclaimed
and re-instantiated, resulting in the second operation having a
different locking order for the same files compared to the
first operation...

> +out_unlock:
> +	if (dst_inode < src_inode) {
> +		mutex_unlock(&src_inode->i_mutex);
> +		mutex_unlock(&dst_inode->i_mutex);
> +	} else {
> +		mutex_unlock(&dst_inode->i_mutex);
> +		mutex_unlock(&src_inode->i_mutex);
> +	}

You don't have to care about lock order on unlock.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
