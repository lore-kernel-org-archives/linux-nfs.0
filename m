Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53712 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbbE1TYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2015 15:24:14 -0400
Date: Thu, 28 May 2015 15:24:13 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v3 30/45] richacl: Create richacl from mode values
Message-ID: <20150528192413.GA31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <b435787dd651572f42984f9dec2a68cbf38bc7bf.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b435787dd651572f42984f9dec2a68cbf38bc7bf.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:04:27PM +0200, Andreas Gruenbacher wrote:
> Create a richacl that corresponds to given file mode permission bits.
> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> ---
>  fs/richacl_compat.c     | 38 ++++++++++++++++++++++++++++++++++++++
>  include/linux/richacl.h |  1 +
>  2 files changed, 39 insertions(+)
> 
> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> index 49af600..8ebe772 100644
> --- a/fs/richacl_compat.c
> +++ b/fs/richacl_compat.c
> @@ -750,3 +750,41 @@ richacl_apply_masks(struct richacl **acl)
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(richacl_apply_masks);
> +
> +/**
> + * richacl_from_mode_unmasked  -  create an acl which corresponds to @mode
> + *
> + * The resulting acl doesn't have the RICHACL_MASKED flag set.

That seems to disagree with:

> + *
> + * @mode:	file mode including the file type
> + */
> +struct richacl *
> +richacl_from_mode_unmasked(mode_t mode)
> +{
> +	struct richacl *acl;
> +	struct richace *ace;
> +
> +	acl = richacl_alloc(1, GFP_KERNEL);
> +	if (!acl)
> +		return NULL;
> +	acl->a_flags = RICHACL_MASKED;

this line?

--b.

> +	acl->a_owner_mask = richacl_mode_to_mask(mode >> 6) |
> +			    RICHACE_POSIX_OWNER_ALLOWED;
> +	acl->a_group_mask = richacl_mode_to_mask(mode >> 3);
> +	acl->a_other_mask = richacl_mode_to_mask(mode);
> +
> +	ace = acl->a_entries;
> +	ace->e_type  = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
> +	ace->e_flags = RICHACE_SPECIAL_WHO;
> +	ace->e_mask = RICHACE_POSIX_ALWAYS_ALLOWED |
> +		      RICHACE_POSIX_MODE_ALL |
> +		      RICHACE_POSIX_OWNER_ALLOWED;
> +	/* RICHACE_DELETE_CHILD is meaningless for non-directories. */
> +	if (!S_ISDIR(mode))
> +		ace->e_mask &= ~RICHACE_DELETE_CHILD;
> +	ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
> +
> +	return acl;
> +
> +}
> +EXPORT_SYMBOL_GPL(richacl_from_mode_unmasked);
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index 6a97dca..25ff4df 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -327,5 +327,6 @@ extern struct richacl *richacl_create(struct inode *, struct inode *);
>  
>  /* richacl_compat.c */
>  extern int richacl_apply_masks(struct richacl **);
> +extern struct richacl *richacl_from_mode_unmasked(mode_t);
>  
>  #endif /* __RICHACL_H */
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
