Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58568 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbbIQShY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 14:37:24 -0400
Date: Thu, 17 Sep 2015 14:37:22 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v7 13/41] richacl: Check if an acl is equivalent to a file
 mode
Message-ID: <20150917183722.GC13825@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-14-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441448856-13478-14-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 05, 2015 at 12:27:08PM +0200, Andreas Gruenbacher wrote:
> ACLs are considered equivalent to file modes if they only consist of
> owner@, group@, and everyone@ entries, the owner@ permissions do not
> depend on whether the owner is a member in the owning group, and no
> inheritance flags are set.  This test is used to avoid storing richacls
> if the acl can be computed from the file permission bits.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_base.c       | 104 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/richacl.h |   1 +
>  2 files changed, 105 insertions(+)
> 
> diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> index 3163152..106e988 100644
> --- a/fs/richacl_base.c
> +++ b/fs/richacl_base.c
> @@ -379,3 +379,107 @@ richacl_chmod(struct richacl *acl, mode_t mode)
>  	return clone;
>  }
>  EXPORT_SYMBOL_GPL(richacl_chmod);
> +
> +/**
> + * richacl_equiv_mode  -  compute the mode equivalent of @acl
> + *
> + * An acl is considered equivalent to a file mode if it only consists of
> + * owner@, group@, and everyone@ entries and the owner@ permissions do not
> + * depend on whether the owner is a member in the owning group.
> + */
> +int
> +richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
> +{
> +	mode_t mode = *mode_p;
> +
> +	/*
> +	 * The RICHACE_DELETE_CHILD flag is meaningless for non-directories, so
> +	 * we ignore it.
> +	 */
> +	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
> +	struct {
> +		unsigned int allowed;
> +		unsigned int defined;  /* allowed or denied */
> +	} owner = {
> +		.defined = RICHACE_POSIX_ALWAYS_ALLOWED |
> +			   RICHACE_POSIX_OWNER_ALLOWED  | x,
> +	}, group = {
> +		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
> +	}, everyone = {
> +		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
> +	};
> +	const struct richace *ace;
> +
> +	if (acl->a_flags & ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED))
> +		return -1;
> +
> +	richacl_for_each_entry(ace, acl) {
> +		if (ace->e_flags & ~RICHACE_SPECIAL_WHO)
> +			return -1;

Couldn't this just be

		if (ace->e_flags != RICHACE_SPECIAL_WHO)
			return -1

I guess the only difference is that you're letting the named-user case
through to get caught by the final "else" clause below.... Still, the !=
test seems possibly simpler to me.

--b.

> +
> +		if (richace_is_owner(ace) || richace_is_everyone(ace)) {
> +			x = ace->e_mask & ~owner.defined;
> +			if (richace_is_allow(ace)) {
> +				unsigned int group_denied =
> +					group.defined & ~group.allowed;
> +
> +				if (x & group_denied)
> +					return -1;
> +				owner.allowed |= x;
> +			} else /* if (richace_is_deny(ace)) */ {
> +				if (x & group.allowed)
> +					return -1;
> +			}
> +			owner.defined |= x;
> +
> +			if (richace_is_everyone(ace)) {
> +				x = ace->e_mask;
> +				if (richace_is_allow(ace)) {
> +					group.allowed |=
> +						x & ~group.defined;
> +					everyone.allowed |=
> +						x & ~everyone.defined;
> +				}
> +				group.defined |= x;
> +				everyone.defined |= x;
> +			}
> +		} else if (richace_is_group(ace)) {
> +			x = ace->e_mask & ~group.defined;
> +			if (richace_is_allow(ace))
> +				group.allowed |= x;
> +			group.defined |= x;
> +		} else
> +			return -1;
> +	}
> +
> +	if (group.allowed & ~owner.defined)
> +		return -1;
> +
> +	if (acl->a_flags & RICHACL_MASKED) {
> +		if (acl->a_flags & RICHACL_WRITE_THROUGH) {
> +			owner.allowed = acl->a_owner_mask;
> +			everyone.allowed = acl->a_other_mask;
> +		} else {
> +			owner.allowed &= acl->a_owner_mask;
> +			everyone.allowed &= acl->a_other_mask;
> +		}
> +		group.allowed &= acl->a_group_mask;
> +	}
> +
> +	mode = (mode & ~S_IRWXUGO) |
> +	       (richacl_mask_to_mode(owner.allowed) << 6) |
> +	       (richacl_mask_to_mode(group.allowed) << 3) |
> +		richacl_mask_to_mode(everyone.allowed);
> +
> +	/* Mask flags we can ignore */
> +	x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
> +
> +	if (((richacl_mode_to_mask(mode >> 6) ^ owner.allowed)    & ~x) ||
> +	    ((richacl_mode_to_mask(mode >> 3) ^ group.allowed)    & ~x) ||
> +	    ((richacl_mode_to_mask(mode)      ^ everyone.allowed) & ~x))
> +		return -1;
> +
> +	*mode_p = mode;
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(richacl_equiv_mode);
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index d4a576c..6535ce5 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -304,6 +304,7 @@ extern unsigned int richacl_mode_to_mask(mode_t);
>  extern unsigned int richacl_want_to_mask(unsigned int);
>  extern void richacl_compute_max_masks(struct richacl *);
>  extern struct richacl *richacl_chmod(struct richacl *, mode_t);
> +extern int richacl_equiv_mode(const struct richacl *, mode_t *);
>  
>  /* richacl_inode.c */
>  extern int richacl_permission(struct inode *, const struct richacl *, int);
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
