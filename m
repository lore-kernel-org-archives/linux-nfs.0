Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60801 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932428AbbIUVAl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 17:00:41 -0400
Date: Mon, 21 Sep 2015 17:00:41 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v7 23/41] richacl: Set the owner permissions to the owner
 mask
Message-ID: <20150921210041.GB12968@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-24-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441448856-13478-24-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 05, 2015 at 12:27:18PM +0200, Andreas Gruenbacher wrote:
> Change the acl so that owner@ is granted the permissions set in the
> owner mask.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_compat.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 46 insertions(+)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 9b76fc0..14a1b4b 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -413,3 +413,49 @@ richacl_propagate_everyone(struct richacl_alloc *alloc)
>  	}
>  	return 0;
>  }
> +
> +/**
> + * richacl_set_owner_permissions  -  set the owner permissions to the owner mask
> + *
> + * Change the acl so that owner@ is granted the permissions set in the owner
> + * mask.  This leaves at most one efective owner@ allow entry at the beginning
> + * of the acl.

Perhaps also worth nothing here that it's a no-op in the !MASKED or
!WRITE_THROUGH cases and that this does not change the permissions that
the ACL grants.  (The latter wasn't obvious to me at first....  But
this only modifies OWNER@ aces, and in the MASKED & WRITE_THROUGH case
modification of OWNER@ aces doesn't affect permissions.)

Anyway, code looks right to me:

	Reviewed-by: J. Bruce Fields <bfields@redhat.com>

--b.

> + */
> +static int
> +richacl_set_owner_permissions(struct richacl_alloc *alloc)
> +{
> +	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
> +	unsigned int owner_mask = alloc->acl->a_owner_mask & ~x;
> +	unsigned int denied = 0;
> +	struct richace *ace;
> +
> +	if (!((alloc->acl->a_flags & RICHACL_WRITE_THROUGH) &&
> +	      (alloc->acl->a_flags & RICHACL_MASKED)))
> +		return 0;
> +
> +	richacl_for_each_entry(ace, alloc->acl) {
> +		if (richace_is_owner(ace)) {
> +			if (richace_is_allow(ace) && !(owner_mask & denied)) {
> +				richace_change_mask(alloc, &ace, owner_mask);
> +				owner_mask = 0;
> +			} else
> +				richace_change_mask(alloc, &ace, 0);
> +		} else {
> +			if (richace_is_deny(ace))
> +				denied |= ace->e_mask;
> +		}
> +	}
> +
> +	if (owner_mask & (denied |
> +			  ~alloc->acl->a_other_mask |
> +			  ~alloc->acl->a_group_mask)) {
> +		ace = alloc->acl->a_entries;
> +		if (richacl_insert_entry(alloc, &ace))
> +			return -1;
> +		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
> +		ace->e_flags = RICHACE_SPECIAL_WHO;
> +		ace->e_mask = owner_mask;
> +		ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
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
