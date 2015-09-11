Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbbIKUfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 16:35:31 -0400
Date: Fri, 11 Sep 2015 16:35:30 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v7 09/41] richacl: Update the file masks in chmod()
Message-ID: <20150911203530.GE11677@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-10-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441448856-13478-10-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 05, 2015 at 12:27:04PM +0200, Andreas Gruenbacher wrote:
> Doing a chmod() sets the file mode, which includes the file permission
> bits.  When a file has a richacl, the permissions that the richacl
> grants need to be limited to what the new file permission bits allow.
> 
> This is done by setting the file masks in the richacl to what the file
> permission bits map to.  The richacl access check algorithm takes the
> file masks into account, which ensures that the richacl cannot grant too
> many permissions.
> 
> It is possible to explicitly add permissions to the file masks which go
> beyond what the file permission bits can grant (like the
> RICHACE_WRITE_ACL permission).  The POSIX.1 standard calls this an
> alternate file access control mechanism.  A subsequent chmod() would
> ensure that those permissions are disabled again.
> 

Reviewed-by: J. Bruce Fields <bfields@redhat.com>

> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_base.c       | 40 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/richacl.h |  1 +
>  2 files changed, 41 insertions(+)
> 
> diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> index fc544f7..6c69234 100644
> --- a/fs/richacl_base.c
> +++ b/fs/richacl_base.c
> @@ -339,3 +339,43 @@ restart:
>  	acl->a_flags &= ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED);
>  }
>  EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
> +
> +/**
> + * richacl_chmod  -  update the file masks to reflect the new mode
> + * @mode:	new file permission bits including the file type
> + *
> + * Return a copy of @acl where the file masks have been replaced by the file
> + * masks corresponding to the file permission bits in @mode, or returns @acl
> + * itself if the file masks are already up to date.  Takes over a reference
> + * to @acl.
> + */
> +struct richacl *
> +richacl_chmod(struct richacl *acl, mode_t mode)
> +{
> +	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
> +	unsigned int owner_mask, group_mask, other_mask;
> +	struct richacl *clone;
> +
> +	owner_mask = richacl_mode_to_mask(mode >> 6) & ~x;
> +	group_mask = richacl_mode_to_mask(mode >> 3) & ~x;
> +	other_mask = richacl_mode_to_mask(mode)      & ~x;
> +
> +	if (acl->a_owner_mask == owner_mask &&
> +	    acl->a_group_mask == group_mask &&
> +	    acl->a_other_mask == other_mask &&
> +	    (acl->a_flags & (RICHACL_WRITE_THROUGH | RICHACL_MASKED)))
> +		return acl;
> +
> +	clone = richacl_clone(acl, GFP_KERNEL);
> +	richacl_put(acl);
> +	if (!clone)
> +		return ERR_PTR(-ENOMEM);
> +
> +	clone->a_flags |= (RICHACL_WRITE_THROUGH | RICHACL_MASKED);
> +	clone->a_owner_mask = owner_mask;
> +	clone->a_group_mask = group_mask;
> +	clone->a_other_mask = other_mask;
> +
> +	return clone;
> +}
> +EXPORT_SYMBOL_GPL(richacl_chmod);
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index e81144a..e00f313 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -298,5 +298,6 @@ extern int richacl_masks_to_mode(const struct richacl *);
>  extern unsigned int richacl_mode_to_mask(mode_t);
>  extern unsigned int richacl_want_to_mask(unsigned int);
>  extern void richacl_compute_max_masks(struct richacl *);
> +extern struct richacl *richacl_chmod(struct richacl *, mode_t);
>  
>  #endif /* __RICHACL_H */
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
