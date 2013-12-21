Return-Path: linux-nfs-owner@vger.kernel.org
Received: from alt-proxy6.mail.unifiedlayer.com ([66.147.245.65]:57440 "HELO
	alt-proxy6.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754190Ab3LUQL7 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Dec 2013 11:11:59 -0500
Subject: Re: [PATCH 21/21] hfsplus: remove can_set_xattr
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Vyacheslav Dubeyko <slava@dubeyko.com>
In-Reply-To: <20131220132524.900291394@bombadil.infradead.org>
Date: Sat, 21 Dec 2013 20:07:51 +0300
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Message-Id: <636E01BC-12FD-452B-8B1C-320B6EADAEFD@dubeyko.com>
References: <20131220131635.650823732@bombadil.infradead.org> <20131220132524.900291394@bombadil.infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 20, 2013, at 4:16 PM, Christoph Hellwig wrote:

> When using the per-superblock xattr handlers permission checking is
> done by the generic code.  hfsplus just needs to check for the magic
> osx attribute not to leak into protected namespaces.
> 
> Also given that the code was obviously copied from JFS the proper
> attribution was missing.
> 

I don't think that this code changing is correct. Current modification
breaks logic. Please, see my comments below.

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/hfsplus/xattr.c |   87 ++--------------------------------------------------
> 1 file changed, 3 insertions(+), 84 deletions(-)
> 
> diff --git a/fs/hfsplus/xattr.c b/fs/hfsplus/xattr.c
> index bf88baa..0b4a5c9 100644
> --- a/fs/hfsplus/xattr.c
> +++ b/fs/hfsplus/xattr.c
> @@ -52,82 +52,6 @@ static inline int is_known_namespace(const char *name)
> 	return true;
> }
> 
> -static int can_set_system_xattr(struct inode *inode, const char *name,
> -				const void *value, size_t size)

I agree that it makes sense to remove this code if permission checking
is done by generic code.

> -{
> -#ifdef CONFIG_HFSPLUS_FS_POSIX_ACL
> -	struct posix_acl *acl;
> -	int err;
> -
> -	if (!inode_owner_or_capable(inode))
> -		return -EPERM;
> -
> -	/*
> -	 * POSIX_ACL_XATTR_ACCESS is tied to i_mode
> -	 */
> -	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0) {
> -		acl = posix_acl_from_xattr(&init_user_ns, value, size);
> -		if (IS_ERR(acl))
> -			return PTR_ERR(acl);
> -		if (acl) {
> -			err = posix_acl_equiv_mode(acl, &inode->i_mode);
> -			posix_acl_release(acl);
> -			if (err < 0)
> -				return err;
> -			mark_inode_dirty(inode);
> -		}
> -		/*
> -		 * We're changing the ACL.  Get rid of the cached one
> -		 */
> -		forget_cached_acl(inode, ACL_TYPE_ACCESS);
> -
> -		return 0;
> -	} else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0) {
> -		acl = posix_acl_from_xattr(&init_user_ns, value, size);
> -		if (IS_ERR(acl))
> -			return PTR_ERR(acl);
> -		posix_acl_release(acl);
> -
> -		/*
> -		 * We're changing the default ACL.  Get rid of the cached one
> -		 */
> -		forget_cached_acl(inode, ACL_TYPE_DEFAULT);
> -
> -		return 0;
> -	}
> -#endif /* CONFIG_HFSPLUS_FS_POSIX_ACL */
> -	return -EOPNOTSUPP;
> -}
> -
> -static int can_set_xattr(struct inode *inode, const char *name,
> -				const void *value, size_t value_len)

This function works for all handlers. So, I don't think that it makes sense
to delete it.

> -{
> -	if (!strncmp(name, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
> -		return can_set_system_xattr(inode, name, value, value_len);
> -

I agree that it needs to remove this check for XATTR_SYSTEM_PREFIX case.

> -	if (!strncmp(name, XATTR_MAC_OSX_PREFIX, XATTR_MAC_OSX_PREFIX_LEN)) {
> -		/*
> -		 * This makes sure that we aren't trying to set an
> -		 * attribute in a different namespace by prefixing it
> -		 * with "osx."
> -		 */
> -		if (is_known_namespace(name + XATTR_MAC_OSX_PREFIX_LEN))
> -			return -EOPNOTSUPP;

I think that this check is important. It forbids such combinations as "osx.system.*" or
"osx.trusted.*", for example. Because "osx.*" is virtual namespace for xattrs that
it can be under Mac OS X. If you want to set xattr from "system.*" namespace, for example,
then you need to use another handler. And such namespace should be without
addition of "osx." prefix.

> -
> -		return 0;
> -	}
> -
> -	/*
> -	 * Don't allow setting an attribute in an unknown namespace.
> -	 */
> -	if (strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN) &&
> -	    strncmp(name, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN) &&
> -	    strncmp(name, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN))
> -		return -EOPNOTSUPP;
> -
> -	return 0;
> -}
> -
> static void hfsplus_init_header_node(struct inode *attr_file,
> 					u32 clump_size,
> 					char *buf, u16 node_size)
> @@ -350,10 +274,6 @@ int __hfsplus_setxattr(struct inode *inode, const char *name,
> 				HFSPLUS_IS_RSRC(inode))
> 		return -EOPNOTSUPP;
> 
> -	err = can_set_xattr(inode, name, value, size);

The __hfsplus_setxattr() is common method for all handlers. So, removing
this call means that we don't check validity of namespace. I don't think
that such modification is a right way.

> -	if (err)
> -		return err;
> -
> 	if (strncmp(name, XATTR_MAC_OSX_PREFIX,
> 				XATTR_MAC_OSX_PREFIX_LEN) == 0)
> 		name += XATTR_MAC_OSX_PREFIX_LEN;
> @@ -841,10 +761,6 @@ int hfsplus_removexattr(struct dentry *dentry, const char *name)
> 	if (!HFSPLUS_SB(inode->i_sb)->attr_tree)
> 		return -EOPNOTSUPP;
> 
> -	err = can_set_xattr(inode, name, NULL, 0);

Ditto. Moreover, it is used namely hfsplus_removexattr() and not
__hfsplus_setxattr() for removing xattrs in hfsplus driver. So, removing
this check is not good way.

> -	if (err)
> -		return err;
> -
> 	if (strncmp(name, XATTR_MAC_OSX_PREFIX,
> 				XATTR_MAC_OSX_PREFIX_LEN) == 0)
> 		name += XATTR_MAC_OSX_PREFIX_LEN;
> @@ -941,6 +857,9 @@ static int hfsplus_osx_setxattr(struct dentry *dentry, const char *name,
> 	if (len > HFSPLUS_ATTR_MAX_STRLEN)
> 		return -EOPNOTSUPP;
> 
> +	if (is_known_namespace(name))
> +		return -EOPNOTSUPP;

If common check in __hfsplus_setxattr() will be on the same place then
this addition doesn't make sense.

Thanks,
Vyacheslav Dubeyko.

> +
> 	strcpy(xattr_name, XATTR_MAC_OSX_PREFIX);
> 	strcpy(xattr_name + XATTR_MAC_OSX_PREFIX_LEN, name);
> 
> -- 
> 1.7.10.4
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

