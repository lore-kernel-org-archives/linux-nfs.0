Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753375AbbIRV4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Sep 2015 17:56:13 -0400
Date: Fri, 18 Sep 2015 17:56:11 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v7 22/41] richacl: Propagate everyone@ permissions to other
 aces
Message-ID: <20150918215611.GD22671@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-23-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441448856-13478-23-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 05, 2015 at 12:27:17PM +0200, Andreas Gruenbacher wrote:
> The trailing everyone@ allow ace can grant permissions to all file
> classes including the owner and group class.  Before we can apply the
> other mask to this entry to turn it into an "other class" entry, we need
> to ensure that members of the owner or group class will not lose any
> permissions from that ace.
> 
> Conceptually, we do this by inserting additional <who>:<allow>::allow
> entries before the trailing everyone@ allow ace with the same
> permissions as the trailing everyone@ allow ace for owner@, group@, and
> all explicitly mentioned users and groups.  (In practice, we will rarely
> need to insert any additional aces in this step.)
> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> ---
>  fs/richacl_compat.c | 195 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 195 insertions(+)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 4f0acf5..9b76fc0 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -218,3 +218,198 @@ richacl_move_everyone_aces_down(struct richacl_alloc *alloc)
>  	}
>  	return 0;
>  }
> +
> +/**
> + * __richacl_propagate_everyone  -  propagate everyone@ permissions up for @who
> + * @alloc:	acl and number of allocated entries
> + * @who:	identifier to propagate permissions for
> + * @allow:	permissions to propagate up
> + *
> + * Propagate the permissions in @allow up from the end of the acl to the start
> + * for the specified principal @who.
> + *
> + * The simplest possible approach to achieve this would be to insert a
> + * "<who>:<allow>::allow" ace before the final everyone@ allow ace.  Since this
> + * would often result in aces which are not needed or which could be merged
> + * with an existing ace, we make the following optimizations:
> + *
> + *   - We go through the acl and determine which permissions are already
> + *     allowed or denied to @who, and we remove those permissions from
> + *     @allow.
> + *
> + *   - If the acl contains an allow ace for @who and no aces after this entry
> + *     deny permissions in @allow, we add the permissions in @allow to this
> + *     ace.  (Propagating permissions across a deny ace which can match the
> + *     process can elevate permissions.)
> + *
> + * This transformation does not alter the permissions that the acl grants.
> + */
> +static int
> +__richacl_propagate_everyone(struct richacl_alloc *alloc, struct richace *who,
> +			     unsigned int allow)
> +{
> +	struct richace *allow_last = NULL, *ace;
> +	struct richacl *acl = alloc->acl;
> +
> +	/*
> +	 * Remove the permissions from allow that are already determined for
> +	 * this who value, and figure out if there is an allow entry for
> +	 * this who value that is "reachable" from the trailing everyone@
> +	 * allow ace.
> +	 */
> +	richacl_for_each_entry(ace, acl) {
> +		if (richace_is_inherit_only(ace))
> +			continue;
> +		if (richace_is_allow(ace)) {
> +			if (richace_is_same_identifier(ace, who)) {
> +				allow &= ~ace->e_mask;
> +				allow_last = ace;
> +			}
> +		} else if (richace_is_deny(ace)) {
> +			if (richace_is_same_identifier(ace, who))
> +				allow &= ~ace->e_mask;
> +			else if (allow & ace->e_mask)
> +				allow_last = NULL;
> +		}
> +	}
> +	ace--;
> +
> +	/*
> +	 * If for group class entries, all the remaining permissions will
> +	 * remain granted by the trailing everyone@ ace, no additional entry is
> +	 * needed.
> +	 */
> +	if (!richace_is_owner(who) &&
> +	    richace_is_everyone(ace) && richace_is_allow(ace) &&
> +	    !(allow & ~(ace->e_mask & acl->a_other_mask)))
> +		allow = 0;
> +
> +	if (allow) {
> +		if (allow_last)
> +			return richace_change_mask(alloc, &allow_last,
> +						   allow_last->e_mask | allow);
> +		else {
> +			struct richace who_copy;
> +
> +			richace_copy(&who_copy, who);
> +			ace = acl->a_entries + acl->a_count - 1;
> +			if (richacl_insert_entry(alloc, &ace))
> +				return -1;
> +			richace_copy(ace, &who_copy);
> +			ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
> +			ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
> +			ace->e_mask = allow;
> +		}
> +	}
> +	return 0;
> +}
> +
> +/**
> + * richacl_propagate_everyone  -  propagate everyone@ permissions up the acl
> + * @alloc:	acl and number of allocated entries
> + *
> + * Make sure that group@ and all other users and groups mentioned in the acl
> + * will not lose any permissions when finally applying the other mask to the
> + * everyone@ allow ace at the end of the acl.  We modify the permissions of
> + * existing entries or add new entries before the final everyone@ allow ace to
> + * achieve that.
> + *
> + * For example, the following acl implicitly grants everyone rwpx access:
> + *
> + *    joe:r::allow
> + *    everyone@:rwpx::allow
> + *
> + * When applying mode 0660 to this acl, group@ would lose rwp access, and joe
> + * would lose wp access even though the mode does not exclude those
> + * permissions.  After propagating the everyone@ permissions, the result for
> + * applying mode 0660 becomes:
> + *
> + *    owner@:rwp::allow
> + *    joe:rwp::allow
> + *    group@:rwp::allow
> + *
> + * Deny aces complicate the matter.  For example, the following acl grants
> + * everyone but joe write access:
> + *
> + *    joe:wp::deny
> + *    everyone@:rwpx::allow
> + *
> + * When applying mode 0660 to this acl, group@ would lose rwp access, and joe
> + * would lose r access.  After propagating the everyone@ permissions, the
> + * result for applying mode 0660 becomes:
> + *
> + *    owner@:rwp::allow
> + *    joe:w::deny
> + *    group@:rwp::allow
> + *    joe:r::allow
> + */
> +static int
> +richacl_propagate_everyone(struct richacl_alloc *alloc)
> +{
> +	struct richace who = { .e_flags = RICHACE_SPECIAL_WHO };
> +	struct richacl *acl = alloc->acl;
> +	struct richace *ace;
> +	unsigned int owner_allow, group_allow;
> +
> +	/*
> +	 * If the owner mask contains permissions which are not in the group
> +	 * mask, the group mask contains permissions which are not in the other
> +	 * mask, or the owner class contains permissions which are not in the

s/owner class/owner mask?

> +	 * other mask, we may need to propagate permissions up from the
> +	 * everyone@ allow ace.  The third condition is implied by the first
> +	 * two.
> +	 */
> +	if (!((acl->a_owner_mask & ~acl->a_group_mask) ||
> +	      (acl->a_group_mask & ~acl->a_other_mask)))
> +		return 0;

The code looks right, but I don't understand the preceding comment.

For example, 

	owner mask: rw
	group mask:  wx
	other mask: rw

satisfies the first two conditions, but not the third.

Also, I don't understand why the first condition would imply that we
might need to propagate permissions.

--b.

> +	if (!acl->a_count)
> +		return 0;
> +	ace = acl->a_entries + acl->a_count - 1;
> +	if (richace_is_inherit_only(ace) || !richace_is_everyone(ace))
> +		return 0;
> +
> +	owner_allow = ace->e_mask & acl->a_owner_mask;
> +	group_allow = ace->e_mask & acl->a_group_mask;
> +
> +	if (owner_allow & ~(acl->a_group_mask & acl->a_other_mask)) {
> +		/* Propagate everyone@ permissions through to owner@. */
> +		who.e_id.special = RICHACE_OWNER_SPECIAL_ID;
> +		if (__richacl_propagate_everyone(alloc, &who, owner_allow))
> +			return -1;
> +		acl = alloc->acl;
> +	}
> +
> +	if (group_allow & ~acl->a_other_mask) {
> +		int n;
> +
> +		/* Propagate everyone@ permissions through to group@. */
> +		who.e_id.special = RICHACE_GROUP_SPECIAL_ID;
> +		if (__richacl_propagate_everyone(alloc, &who, group_allow))
> +			return -1;
> +		acl = alloc->acl;
> +
> +		/*
> +		 * Start from the entry before the trailing everyone@ allow
> +		 * entry. We will not hit everyone@ entries in the loop.
> +		 */
> +		for (n = acl->a_count - 2; n != -1; n--) {
> +			ace = acl->a_entries + n;
> +
> +			if (richace_is_inherit_only(ace) ||
> +			    richace_is_owner(ace) ||
> +			    richace_is_group(ace))
> +				continue;
> +			if (richace_is_allow(ace) || richace_is_deny(ace)) {
> +				/*
> +				 * Any inserted entry will end up below the
> +				 * current entry
> +				 */
> +				if (__richacl_propagate_everyone(alloc, ace,
> +								 group_allow))
> +					return -1;
> +				acl = alloc->acl;
> +			}
> +		}
> +	}
> +	return 0;
> +}
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
