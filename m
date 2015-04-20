Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbbDTV2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Apr 2015 17:28:11 -0400
Date: Mon, 20 Apr 2015 17:28:10 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC 11/39] richacl: Compute maximum file masks from an acl
Message-ID: <20150420212810.GB27895@fieldses.org>
References: <cover.1427471526.git.agruenba@redhat.com>
 <75f97eb880b1bbb47b0aa146d3f528e32de06744.1427471526.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <75f97eb880b1bbb47b0aa146d3f528e32de06744.1427471526.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 05:50:09PM +0100, Andreas Gruenbacher wrote:
> Compute upper bound owner, group, and other file masks with as few
> permissions as possible without denying any permissions that the NFSv4
> acl in a richacl grants.
> 
> This algorithm is used when a file inherits an acl at create time and
> when an acl is set via a mechanism that does not specify file modes
> (such as via nfsd).  When user-space sets an acl, the file masks are
> passed in as part of the xattr.
> 
> When setting a richacl, the file masks determine what the file
> permission bits will be set to; see richacl_masks_to_mode().
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_base.c       | 128 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/richacl.h |   1 +
>  2 files changed, 129 insertions(+)
> 
> diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> index 9cd15ca..d9e557a 100644
> --- a/fs/richacl_base.c
> +++ b/fs/richacl_base.c
> @@ -173,3 +173,131 @@ richacl_want_to_mask(unsigned int want)
>  	return mask;
>  }
>  EXPORT_SYMBOL_GPL(richacl_want_to_mask);
> +
> +/**
> + * richacl_allowed_to_who  -  mask flags allowed to a specific who value
> + *
> + * Computes the mask values allowed to a specific who value, taking
> + * EVERYONE@ entries into account.
> + */
> +static unsigned int richacl_allowed_to_who(struct richacl *acl,
> +					   struct richace *who)
> +{
> +	struct richace *ace;
> +	unsigned int allowed = 0;
> +
> +	richacl_for_each_entry_reverse(ace, acl) {
> +		if (richace_is_inherit_only(ace))
> +			continue;
> +		if (richace_is_same_identifier(ace, who) ||
> +		    richace_is_everyone(ace)) {
> +			if (richace_is_allow(ace))
> +				allowed |= ace->e_mask;
> +			else if (richace_is_deny(ace))
> +				allowed &= ~ace->e_mask;
> +		}
> +	}
> +	return allowed;
> +}
> +
> +/**
> + * richacl_group_class_allowed  -  maximum permissions the group class is allowed
> + *
> + * See richacl_compute_max_masks().
> + */
> +static unsigned int richacl_group_class_allowed(struct richacl *acl)
> +{
> +	struct richace *ace;
> +	unsigned int everyone_allowed = 0, group_class_allowed = 0;
> +	int had_group_ace = 0;
> +
> +	richacl_for_each_entry_reverse(ace, acl) {
> +		if (richace_is_inherit_only(ace) ||
> +		    richace_is_owner(ace))
> +			continue;
> +
> +		if (richace_is_everyone(ace)) {
> +			if (richace_is_allow(ace))
> +				everyone_allowed |= ace->e_mask;
> +			else if (richace_is_deny(ace))
> +				everyone_allowed &= ~ace->e_mask;
> +		} else {
> +			group_class_allowed |=
> +				richacl_allowed_to_who(acl, ace);
> +
> +			if (richace_is_group(ace))
> +				had_group_ace = 1;
> +		}
> +	}
> +	if (!had_group_ace)
> +		group_class_allowed |= everyone_allowed;
> +	return group_class_allowed;
> +}
> +
> +/**
> + * richacl_compute_max_masks  -  compute upper bound masks
> + *
> + * Computes upper bound owner, group, and other masks so that none of
> + * the mask flags allowed by the acl are disabled (for any choice of the
> + * file owner or group membership).
> + */
> +void richacl_compute_max_masks(struct richacl *acl)
> +{
> +	unsigned int gmask = ~0;
> +	struct richace *ace;
> +
> +	/*
> +	 * @gmask contains all permissions which the group class is ever
> +	 * allowed.  We use it to avoid adding permissions to the group mask
> +	 * from everyone@ allow aces which the group class is always denied
> +	 * through other aces.  For example, the following acl would otherwise
> +	 * result in a group mask or rw:
> +	 *
> +	 *	group@:w::deny
> +	 *	everyone@:rw::allow
> +	 *
> +	 * Avoid computing @gmask for acls which do not include any group class
> +	 * deny aces: in such acls, the group class is never denied any
> +	 * permissions from everyone@ allow aces.
> +	 */

Cripes, by the time I got to this point I'd already written one response
where I complained this was wrong, another where I explained why it was
right, and gone back and forth a couple more times.

Feel free to add a

	Reviewed-by: J. Bruce Fields <bfields@redhat.com>

but maybe we could use a couple more examples here.  Or a paper.

--b.

> +
> +restart:
> +	acl->a_owner_mask = 0;
> +	acl->a_group_mask = 0;
> +	acl->a_other_mask = 0;
> +
> +	richacl_for_each_entry_reverse(ace, acl) {
> +		if (richace_is_inherit_only(ace))
> +			continue;
> +
> +		if (richace_is_owner(ace)) {
> +			if (richace_is_allow(ace))
> +				acl->a_owner_mask |= ace->e_mask;
> +			else if (richace_is_deny(ace))
> +				acl->a_owner_mask &= ~ace->e_mask;
> +		} else if (richace_is_everyone(ace)) {
> +			if (richace_is_allow(ace)) {
> +				acl->a_owner_mask |= ace->e_mask;
> +				acl->a_group_mask |= ace->e_mask & gmask;
> +				acl->a_other_mask |= ace->e_mask;
> +			} else if (richace_is_deny(ace)) {
> +				acl->a_owner_mask &= ~ace->e_mask;
> +				acl->a_group_mask &= ~ace->e_mask;
> +				acl->a_other_mask &= ~ace->e_mask;
> +			}
> +		} else {
> +			if (richace_is_allow(ace)) {
> +				acl->a_owner_mask |= ace->e_mask & gmask;
> +				acl->a_group_mask |= ace->e_mask & gmask;
> +			} else if (richace_is_deny(ace) && gmask == ~0) {
> +				gmask = richacl_group_class_allowed(acl);
> +				if (likely(gmask != ~0))
> +					/* should always be true */
> +					goto restart;
> +			}
> +		}
> +	}
> +
> +	acl->a_flags &= ~RICHACL_MASKED;
> +}
> +EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index 2120aa6..25f45f7 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -288,5 +288,6 @@ extern struct richacl *richacl_alloc(int, gfp_t);
>  extern int richacl_masks_to_mode(const struct richacl *);
>  extern unsigned int richacl_mode_to_mask(mode_t);
>  extern unsigned int richacl_want_to_mask(unsigned int);
> +extern void richacl_compute_max_masks(struct richacl *);
>  
>  #endif /* __RICHACL_H */
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
