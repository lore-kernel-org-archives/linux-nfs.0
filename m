Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60511 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753814Ab3LBU7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 15:59:34 -0500
Date: Mon, 2 Dec 2013 21:59:32 +0100
From: Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/18] fs: add generic xattr_acl handlers
Message-ID: <20131202205932.GE12253@quack.suse.cz>
References: <20131201115903.910559036@bombadil.infradead.org>
 <20131201120654.211328224@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131201120654.211328224@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun 01-12-13 03:59:07, Christoph Hellwig wrote:
> With the ->set_acl inode operation we can implement the Posix ACL
> xattr handlers in generic code instead of duplicating them all
> over the tree.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

							Honza

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/xattr_acl.c                  |   95 +++++++++++++++++++++++++++++++++++++++
>  include/linux/posix_acl_xattr.h |    3 ++
>  2 files changed, 98 insertions(+)
> 
> diff --git a/fs/xattr_acl.c b/fs/xattr_acl.c
> index 9fbea87..932ec76 100644
> --- a/fs/xattr_acl.c
> +++ b/fs/xattr_acl.c
> @@ -10,6 +10,7 @@
>  #include <linux/posix_acl_xattr.h>
>  #include <linux/gfp.h>
>  #include <linux/user_namespace.h>
> +#include <linux/xattr.h>
>  
>  /*
>   * Fix up the uids and gids in posix acl extended attributes in place.
> @@ -178,3 +179,97 @@ posix_acl_to_xattr(struct user_namespace *user_ns, const struct posix_acl *acl,
>  	return real_size;
>  }
>  EXPORT_SYMBOL (posix_acl_to_xattr);
> +
> +static int
> +posix_acl_xattr_get(struct dentry *dentry, const char *name,
> +		void *value, size_t size, int type)
> +{
> +	struct posix_acl *acl;
> +	int error;
> +
> +	if (!IS_POSIXACL(dentry->d_inode))
> +		return -EOPNOTSUPP;
> +
> +	acl = get_acl(dentry->d_inode, type);
> +	if (IS_ERR(acl))
> +		return PTR_ERR(acl);
> +	if (acl == NULL)
> +		return -ENODATA;
> +
> +	error = posix_acl_to_xattr(&init_user_ns, acl, value, size);
> +	posix_acl_release(acl);
> +
> +	return error;
> +}
> +
> +static int
> +posix_acl_xattr_set(struct dentry *dentry, const char *name,
> +		const void *value, size_t size, int flags, int type)
> +{
> +	struct inode *inode = dentry->d_inode;
> +	struct posix_acl *acl = NULL;
> +	int ret;
> +
> +	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
> +		return value ? -EACCES : 0;
> +	if (!inode_owner_or_capable(inode))
> +		return -EPERM;
> +	if (!IS_POSIXACL(inode))
> +		return -EOPNOTSUPP;
> +
> +	if (value) {
> +		acl = posix_acl_from_xattr(&init_user_ns, value, size);
> +		if (IS_ERR(acl))
> +			return PTR_ERR(acl);
> +
> +		if (acl) {
> +			ret = posix_acl_valid(acl);
> +			if (ret)
> +				goto out;
> +		}
> +	}
> +
> +	ret = inode->i_op->set_acl(inode, acl, type);
> +out:
> +	posix_acl_release(acl);
> +	return ret;
> +}
> +
> +static size_t
> +posix_acl_xattr_list(struct dentry *dentry, char *list, size_t list_size,
> +		const char *name, size_t name_len, int type)
> +{
> +	const char *xname;
> +	size_t size;
> +
> +	if (!IS_POSIXACL(dentry->d_inode))
> +		return -EOPNOTSUPP;
> +
> +	if (type == ACL_TYPE_ACCESS)
> +		xname = POSIX_ACL_XATTR_ACCESS;
> +	else
> +		xname = POSIX_ACL_XATTR_DEFAULT;
> +
> +	size = strlen(xname) + 1;
> +	if (list && size <= list_size)
> +		memcpy(list, xname, size);
> +	return size;
> +}
> +
> +const struct xattr_handler posix_acl_access_xattr_handler = {
> +	.prefix = POSIX_ACL_XATTR_ACCESS,
> +	.flags = ACL_TYPE_ACCESS,
> +	.list = posix_acl_xattr_list,
> +	.get = posix_acl_xattr_get,
> +	.set = posix_acl_xattr_set,
> +};
> +EXPORT_SYMBOL_GPL(posix_acl_access_xattr_handler);
> +
> +const struct xattr_handler posix_acl_default_xattr_handler = {
> +	.prefix = POSIX_ACL_XATTR_DEFAULT,
> +	.flags = ACL_TYPE_DEFAULT,
> +	.list = posix_acl_xattr_list,
> +	.get = posix_acl_xattr_get,
> +	.set = posix_acl_xattr_set,
> +};
> +EXPORT_SYMBOL_GPL(posix_acl_default_xattr_handler);
> diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
> index ad93ad0..6f14ee2 100644
> --- a/include/linux/posix_acl_xattr.h
> +++ b/include/linux/posix_acl_xattr.h
> @@ -69,4 +69,7 @@ struct posix_acl *posix_acl_from_xattr(struct user_namespace *user_ns,
>  int posix_acl_to_xattr(struct user_namespace *user_ns,
>  		       const struct posix_acl *acl, void *buffer, size_t size);
>  
> +extern const struct xattr_handler posix_acl_access_xattr_handler;
> +extern const struct xattr_handler posix_acl_default_xattr_handler;
> +
>  #endif	/* _POSIX_ACL_XATTR_H */
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
