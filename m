Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33579 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590AbbIWODH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2015 10:03:07 -0400
Date: Wed, 23 Sep 2015 10:03:07 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v7 24/41] richacl: Set the other permissions to the other
 mask
Message-ID: <20150923140307.GB27083@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-25-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441448856-13478-25-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 05, 2015 at 12:27:19PM +0200, Andreas Gruenbacher wrote:
> Change the acl so that everyone@ is granted the permissions set in the
> other mask.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_compat.c | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 14a1b4b..30bdc95 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -459,3 +459,38 @@ richacl_set_owner_permissions(struct richacl_alloc *alloc)
>  	}
>  	return 0;
>  }
> +
> +/**
> + * richacl_set_other_permissions  -  set the other permissions to the other mask
> + *
> + * Change the acl so that everyone@ is granted the permissions set in the other
> + * mask.  This leaves at most one efective everyone@ allow entry at the end of
> + * the acl.
> + */
> +static int
> +richacl_set_other_permissions(struct richacl_alloc *alloc)
> +{
> +	struct richacl *acl = alloc->acl;
> +	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
> +	unsigned int other_mask = acl->a_other_mask & ~x;
> +	struct richace *ace = acl->a_entries + acl->a_count - 1;
> +
> +	if (!(other_mask &&
> +	      (acl->a_flags & RICHACL_WRITE_THROUGH) &&
> +	      (acl->a_flags & RICHACL_MASKED)))
> +		return 0;

By the way, I think this is only called after checking MASKED--so the
MASKED check here could be a WARN_ON, or could just be dropped.  Ditto
for the following patch.

--b.

> +
> +	if (acl->a_count == 0 ||
> +	    !richace_is_everyone(ace) ||
> +	    richace_is_inherit_only(ace)) {
> +		ace++;
> +		if (richacl_insert_entry(alloc, &ace))
> +			return -1;
> +		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
> +		ace->e_flags = RICHACE_SPECIAL_WHO;
> +		ace->e_mask = other_mask;
> +		ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
> +	} else
> +		richace_change_mask(alloc, &ace, other_mask);
> +	return 0;
> +}
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
