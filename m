Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48237 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbbERVUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2015 17:20:18 -0400
Date: Mon, 18 May 2015 17:20:17 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v3 26/45] richacl: Move everyone@ aces down the acl
Message-ID: <20150518212017.GD31295@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <b9fe1ea3ac5acdb5d2672d1522ff746f42c831be.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b9fe1ea3ac5acdb5d2672d1522ff746f42c831be.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks OK.

On Fri, Apr 24, 2015 at 01:04:23PM +0200, Andreas Gruenbacher wrote:
> The POSIX standard puts processes which are not the owner or a member in
> the owning group or which match any ace other then everyone@ on the
> other file class.  We only know if a process is in the other class after
> processing the entire acl.
> 
> Move all everyone@ aces in the acl down in the acl so that at most a
> single everyone@ allow ace remains at the end.  Permissions which are
> not explicitly allowed are implicitly denied, so everyone@ deny ace is
> needed.

Should be "an everyone@ deny ace is unneeded".

> The everyone@ aces can be moved down the acl without changing the
> permissions that the acl grants.  This transformation simplifies the
> following algorithms, and eventually allows us to turn the final
> everyone@ allow ace into an entry for the other class.
> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> ---
>  fs/richacl_compat.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 65 insertions(+)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 2ea6658..63f4373 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -159,3 +159,68 @@ richace_change_mask(struct richacl_alloc *x, struct richace **ace,
>  	}
>  	return 0;
>  }
> +
> +/**
> + * richacl_move_everyone_aces_down  -  move everyone@ aces to the end of the acl
> + * @x:		acl and number of allocated entries
> + *
> + * Move all everyone aces to the end of the acl so that only a single everyone@
> + * allow ace remains at the end, and update the mask fields of all aces on the
> + * way.  The last ace of the resulting acl will be an everyone@ allow ace only
> + * if @acl grants any permissions to @everyone.  No @everyone deny aces will
> + * remain.
> + *
> + * This transformation does not alter the permissions that the acl grants.
> + * Having at most one everyone@ allow ace at the end of the acl helps us in the
> + * following algorithms.

May be worth documenting the return convention (0 == success, -1 == out
of memory?), though I guess it's the same for everything here.

Looks fine otherwise.

--b.

> + */
> +static int
> +richacl_move_everyone_aces_down(struct richacl_alloc *x)
> +{
> +	struct richace *ace;
> +	unsigned int allowed = 0, denied = 0;
> +
> +	richacl_for_each_entry(ace, x->acl) {
> +		if (richace_is_inherit_only(ace))
> +			continue;
> +		if (richace_is_everyone(ace)) {
> +			if (richace_is_allow(ace))
> +				allowed |= (ace->e_mask & ~denied);
> +			else if (richace_is_deny(ace))
> +				denied |= (ace->e_mask & ~allowed);
> +			else
> +				continue;
> +			if (richace_change_mask(x, &ace, 0))
> +				return -1;
> +		} else {
> +			if (richace_is_allow(ace)) {
> +				if (richace_change_mask(x, &ace, allowed |
> +						(ace->e_mask & ~denied)))
> +					return -1;
> +			} else if (richace_is_deny(ace)) {
> +				if (richace_change_mask(x, &ace, denied |
> +						(ace->e_mask & ~allowed)))
> +					return -1;
> +			}
> +		}
> +	}
> +	if (allowed & ~RICHACE_POSIX_ALWAYS_ALLOWED) {
> +		struct richace *last_ace = ace - 1;
> +
> +		if (x->acl->a_entries &&
> +		    richace_is_everyone(last_ace) &&
> +		    richace_is_allow(last_ace) &&
> +		    richace_is_inherit_only(last_ace) &&
> +		    last_ace->e_mask == allowed)
> +			last_ace->e_flags &= ~RICHACE_INHERIT_ONLY_ACE;
> +		else {
> +			if (richacl_insert_entry(x, &ace))
> +				return -1;
> +			ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
> +			ace->e_flags = RICHACE_SPECIAL_WHO;
> +			ace->e_mask = allowed;
> +			ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
> +		}
> +	}
> +	return 0;
> +}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
