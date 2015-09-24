Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34345 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755488AbbIXSdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 14:33:11 -0400
Date: Thu, 24 Sep 2015 14:33:10 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v7 26/41] richacl: Apply the file masks to a richacl
Message-ID: <20150924183310.GE3823@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-27-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441448856-13478-27-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 05, 2015 at 12:27:21PM +0200, Andreas Gruenbacher wrote:
> Put all the pieces of the acl transformation puzzle together for
> computing a richacl which has the file masks "applied" so that the
> standard nfsv4 access check algorithm can be used on the richacl.
> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> ---
>  fs/richacl_compat.c     | 110 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/richacl.h |   3 ++
>  2 files changed, 113 insertions(+)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 412844c..9681efe 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -730,3 +730,113 @@ richacl_isolate_group_class(struct richacl_alloc *alloc)
>  	}
>  	return 0;
>  }
> +
> +/**
> + * __richacl_apply_masks  -  apply the file masks to all aces
> + * @alloc:	acl and number of allocated entries
> + *
> + * Apply the owner mask to owner@ aces, the other mask to
> + * everyone@ aces, and the group mask to all other aces.
> + *
> + * The previous transformations have brought the acl into a
> + * form in which applying the masks will not lead to the
> + * accidental loss of permissions anymore.
> + */
> +static int
> +__richacl_apply_masks(struct richacl_alloc *alloc, kuid_t owner)
> +{
> +	struct richace *ace;
> +
> +	richacl_for_each_entry(ace, alloc->acl) {
> +		unsigned int mask;
> +
> +		if (richace_is_inherit_only(ace) || !richace_is_allow(ace))
> +			continue;
> +		if (richace_is_owner(ace) ||
> +		    (richace_is_unix_user(ace) && uid_eq(owner, ace->e_id.uid)))
> +			mask = alloc->acl->a_owner_mask;
> +		else if (richace_is_everyone(ace))
> +			mask = alloc->acl->a_other_mask;
> +		else
> +			mask = alloc->acl->a_group_mask;
> +		if (richace_change_mask(alloc, &ace, ace->e_mask & mask))
> +			return -1;
> +	}
> +	return 0;
> +}
> +
> +/**
> + * richacl_apply_masks  -  apply the masks to the acl
> + *
> + * Transform @acl so that the standard NFSv4 permission check algorithm (which
> + * is not aware of file masks) will compute the same access decisions as the
> + * richacl permission check algorithm (which looks at the acl and the file
> + * masks).
> + *
> + * This algorithm is split into several steps:
> + *
> + *   - Move everyone@ aces to the end of the acl.  This simplifies the other
> + *     transformations, and allows the everyone@ allow ace at the end of the
> + *     acl to eventually allow permissions to the other class only.
> + *
> + *   - Propagate everyone@ permissions up the acl.  This transformation makes
> + *     sure that the owner and group class aces won't lose any permissions when
> + *     we apply the other mask to the everyone@ allow ace at the end of the acl.
> + *
> + *   - Apply the file masks to all aces.
> + *
> + *   - Make sure the owner is granted the owner mask permissions.
> + *
> + *   - Make sure everyone is granted the other mask permissions.
> + *
> + *   - Make sure that the owner is not granted any permissions beyond the owner
> + *     mask from group class aces or from everyone@.
> + *
> + *   - Make sure that the group class is not granted any permissions from
> + *     everyone@.
> + *
> + * The algorithm is exact except for richacls which cannot be represented as an
> + * acl alone: for example, given this acl:
> + *
> + *    group@:rw::allow
> + *
> + * when file masks corresponding to mode 0600 are applied, the owner would only
> + * get rw access if he is a member of the owning group.  This algorithm would
> + * produce an empty acl in this case.  We fix this case by modifying
> + * richacl_permission() so that the group mask is always applied to group class
> + * aces.  With this fix, the owner would not have any access (beyond the
> + * implicit permissions always granted to owners).
> + *
> + * NOTE: Depending on the acl and file masks, this algorithm can increase the
> + * number of aces by almost a factor of three in the worst case. This may make
> + * the acl too large for some purposes.
> + */
> +int
> +richacl_apply_masks(struct richacl **acl, kuid_t owner)
> +{
> +	if ((*acl)->a_flags & RICHACL_MASKED) {
> +		struct richacl_alloc alloc = {
> +			.acl = richacl_clone(*acl, GFP_KERNEL),
> +			.count = (*acl)->a_count,
> +		};
> +		if (!alloc.acl)
> +			return -ENOMEM;
> +
> +		if (richacl_move_everyone_aces_down(&alloc) ||
> +		    richacl_propagate_everyone(&alloc) ||
> +		    __richacl_apply_masks(&alloc, owner) ||
> +		    richacl_set_owner_permissions(&alloc) ||
> +		    richacl_set_other_permissions(&alloc) ||

Hm, I'm a little unsure about this step: it seems like the one step that
can actually change the permissions (making them more permissive, in
this case), whereas the others are neutral.

The following two steps should fix that, but I'm not sure they do.

E.g. if I have an ACL like

	mask 0777, WRITE_THROUGH
	GROUP@:r--::allow

I think it should result in

	OWNER@:   rwx::allow
	GROUP@:   -wx::deny
	GROUP@:   r--::allow
	EVERYONE@:rwx::allow

But does the GROUP@ deny actually get in there?  It looks to me like the
denies inserted by richacl_isolate_group_class only take into account
the group mask, not the actual permissions granted to any group class
user.

I may be mising something.

--b.

> +		    richacl_isolate_owner_class(&alloc) ||
> +		    richacl_isolate_group_class(&alloc)) {
> +			richacl_put(alloc.acl);
> +			return -ENOMEM;
> +		}
> +
> +		alloc.acl->a_flags &= ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED);
> +		richacl_put(*acl);
> +		*acl = alloc.acl;
> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(richacl_apply_masks);
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index 832b06c..a945f3c 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -332,4 +332,7 @@ extern struct richacl *richacl_inherit(const struct richacl *, int);
>  extern int richacl_permission(struct inode *, const struct richacl *, int);
>  extern struct richacl *richacl_create(struct inode *, struct inode *);
>  
> +/* richacl_compat.c */
> +extern int richacl_apply_masks(struct richacl **, kuid_t);
> +
>  #endif /* __RICHACL_H */
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
