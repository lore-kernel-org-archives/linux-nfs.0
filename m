Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60457 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756435Ab3LBU5r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 15:57:47 -0500
Date: Mon, 2 Dec 2013 21:57:44 +0100
From: Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/18] fs: add a set_acl inode operation
Message-ID: <20131202205744.GD12253@quack.suse.cz>
References: <20131201115903.910559036@bombadil.infradead.org>
 <20131201120654.027611567@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131201120654.027611567@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun 01-12-13 03:59:06, Christoph Hellwig wrote:
> This will allow moving all the Posix ACL handling into the VFS and clean
> up tons of cruft in the filesystems.
  Looks good. Btw I'd merge this with the following patch... Anyway:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/fs.h |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 121f11f..09f553c 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1580,6 +1580,7 @@ struct inode_operations {
>  			   struct file *, unsigned open_flag,
>  			   umode_t create_mode, int *opened);
>  	int (*tmpfile) (struct inode *, struct dentry *, umode_t);
> +	int (*set_acl)(struct inode *, struct posix_acl *, int);
>  } ____cacheline_aligned;
>  
>  ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
> -- 
> 1.7.10.4
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
