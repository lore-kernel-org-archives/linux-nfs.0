Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44902 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757170Ab1IGVvH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Sep 2011 17:51:07 -0400
Date: Wed, 7 Sep 2011 17:50:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 17/26] richacl: Permission check algorithm
Message-ID: <20110907215022.GI8074@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1315243548-18664-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315243548-18664-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 05, 2011 at 10:55:39PM +0530, Aneesh Kumar K.V wrote:
> From: Andreas Gruenbacher <agruen@kernel.org>
> 
> As in the standard POSIX file permission model, each process is the
> owner, group, or other file class.  A process is
> 
>   - in the owner file class if it owns the file,
>   - in the group file class if it is in the file's owning group or it
>     matches any of the user or group entries, and
>   - in the other file class otherwise.
> 
> Each file class is associated with a file mask.
> 
> A richacl grants a requested access if the NFSv4 acl in the richacl
> grants the requested permissions (according to the NFSv4 permission
> check algorithm) and the file mask that applies to the process includes
> the requested permissions.

I assume that by default any ui normally recalculates an upper-bound
mask automatically when you add an ace, as the posix setfacl does, so
the user doesn't have to think about masks too much?

Patch looks right.

--b.

> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/richacl_base.c       |   99 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/richacl.h |    2 +
>  2 files changed, 101 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> index 60a65d7..1f885ad 100644
> --- a/fs/richacl_base.c
> +++ b/fs/richacl_base.c
> @@ -393,3 +393,102 @@ richacl_chmod(struct richacl *acl, mode_t mode)
>  	return clone;
>  }
>  EXPORT_SYMBOL_GPL(richacl_chmod);
> +
> +/**
> + * richacl_permission  -  richacl permission check algorithm
> + * @inode:	inode to check
> + * @acl:	rich acl of the inode
> + * @mask:	requested access (ACE4_* bitmask)
> + *
> + * Checks if the current process is granted @mask flags in @acl.
> + */
> +int
> +richacl_permission(struct inode *inode, const struct richacl *acl,
> +		   unsigned int mask)
> +{
> +	const struct richace *ace;
> +	unsigned int requested = mask, denied = 0;
> +	int in_owning_group = in_group_p(inode->i_gid);
> +	int in_owner_or_group_class = in_owning_group;
> +
> +	/*
> +	 * We don't need to know which class the process is in when the acl is
> +	 * not masked.
> +	 */
> +	if (!(acl->a_flags & ACL4_MASKED))
> +		in_owner_or_group_class = 1;
> +
> +	/*
> +	 * A process is
> +	 *   - in the owner file class if it owns the file,
> +	 *   - in the group file class if it is in the file's owning group or
> +	 *     it matches any of the user or group entries, and
> +	 *   - in the other file class otherwise.
> +	 */
> +
> +	/*
> +	 * Check if the acl grants the requested access and determine which
> +	 * file class the process is in.
> +	 */
> +	richacl_for_each_entry(ace, acl) {
> +		unsigned int ace_mask = ace->e_mask;
> +
> +		if (richace_is_inherit_only(ace))
> +			continue;
> +		if (richace_is_owner(ace)) {
> +			if (current_fsuid() != inode->i_uid)
> +				continue;
> +			goto is_owner;
> +		} else if (richace_is_group(ace)) {
> +			if (!in_owning_group)
> +				continue;
> +		} else if (richace_is_unix_id(ace)) {
> +			if (ace->e_flags & ACE4_IDENTIFIER_GROUP) {
> +				if (!in_group_p(ace->u.e_id))
> +					continue;
> +			} else {
> +				if (current_fsuid() != ace->u.e_id)
> +					continue;
> +			}
> +		} else
> +			goto is_everyone;
> +
> +is_owner:
> +		/* The process is in the owner or group file class. */
> +		in_owner_or_group_class = 1;
> +
> +is_everyone:
> +		/* Check which mask flags the ACE allows or denies. */
> +		if (richace_is_deny(ace))
> +			denied |= ace_mask & mask;
> +		mask &= ~ace_mask;
> +
> +		/*
> +		 * Keep going until we know which file class
> +		 * the process is in.
> +		 */
> +		if (!mask && in_owner_or_group_class)
> +			break;
> +	}
> +	denied |= mask;
> +
> +	if (acl->a_flags & ACL4_MASKED) {
> +		unsigned int file_mask;
> +
> +		/*
> +		 * The file class a process is in determines which file mask
> +		 * applies.  Check if that file mask also grants the requested
> +		 * access.
> +		 */
> +		if (current_fsuid() == inode->i_uid)
> +			file_mask = acl->a_owner_mask;
> +		else if (in_owner_or_group_class)
> +			file_mask = acl->a_group_mask;
> +		else
> +			file_mask = acl->a_other_mask;
> +		denied |= requested & ~file_mask;
> +	}
> +
> +	return denied ? -EACCES : 0;
> +}
> +EXPORT_SYMBOL_GPL(richacl_permission);
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index 6dd8eb2..f46e797 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -289,5 +289,7 @@ extern unsigned int richacl_mode_to_mask(mode_t);
>  extern unsigned int richacl_want_to_mask(int);
>  extern void richacl_compute_max_masks(struct richacl *);
>  extern struct richacl *richacl_chmod(struct richacl *, mode_t);
> +extern int richacl_permission(struct inode *, const struct richacl *,
> +			      unsigned int);
>  
>  #endif /* __RICHACL_H */
> -- 
> 1.7.4.1
> 
