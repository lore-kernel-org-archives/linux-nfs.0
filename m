Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54131 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754AbcCKO1X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 09:27:23 -0500
Date: Fri, 11 Mar 2016 06:27:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 21/22] ext4: Add richacl support
Message-ID: <20160311142719.GG14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-22-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456733847-17982-22-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static inline int
> +ext4_acl_chmod(struct inode *inode, umode_t mode)
> +{
> +	if (IS_RICHACL(inode))
> +		return richacl_chmod(inode, inode->i_mode);
> +	return posix_acl_chmod(inode, inode->i_mode);
> +}

Thi isn't ext4-specific and potentially duplicated in every caller.
Please provide this as a common helper.

Also while we're at it, the mode argument is ignore and the function
always uses inode->i_mode instead.

> +ext4_get_richacl(struct inode *inode)
> +{
> +	const int name_index = EXT4_XATTR_INDEX_RICHACL;
> +	void *value = NULL;
> +	struct richacl *acl = NULL;
> +	int retval;
> +
> +	retval = ext4_xattr_get(inode, name_index, "", NULL, 0);
> +	if (retval > 0) {
> +		value = kmalloc(retval, GFP_NOFS);
> +		if (!value)
> +			return ERR_PTR(-ENOMEM);
> +		retval = ext4_xattr_get(inode, name_index, "", value, retval);
> +	}
> +	if (retval > 0) {
> +		acl = richacl_from_xattr(&init_user_ns, value, retval);
> +		if (acl == ERR_PTR(-EINVAL))
> +			acl = ERR_PTR(-EIO);

Shouldn't richacl_from_xattr return the error pointer that ->get_richacl
callers expect?

> +static int
> +__ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
> +{
> +	const int name_index = EXT4_XATTR_INDEX_RICHACL;
> +	umode_t mode = inode->i_mode;
> +	int retval, size;
> +	void *value;
> +
> +	if (richacl_equiv_mode(acl, &mode) == 0) {
> +		inode->i_ctime = ext4_current_time(inode);
> +		inode->i_mode = mode;
> +		ext4_mark_inode_dirty(handle, inode);
> +		return __ext4_remove_richacl(handle, inode);
> +	}

Should this check for a NULL acl instead of special casing that
in ext4_set_richacl?

> +int
> +ext4_init_richacl(handle_t *handle, struct inode *inode, struct inode *dir)
> +{
> +	struct richacl *acl = richacl_create(&inode->i_mode, dir);
> +	int error;
> +
> +	error = PTR_ERR(acl);
> +	if (IS_ERR(acl))
> +		return error;

	if (IS_ERR(acl))
		return PTR_ERR(acl);

> +	if (acl) {
> +		error = __ext4_set_richacl(handle, inode, acl);
> +		richacl_put(acl);
> +	}

Shouldn't richacl_create return NULL if the ACL is equivalent to the
mode bits instead of letting every filesystem figure that out on it's
own?

