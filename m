Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46321 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934627AbbEOUvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 16:51:41 -0400
Date: Fri, 15 May 2015 16:51:40 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 19/45] richacl: Also recognize nontrivial
 mode-equivalent acls
Message-ID: <20150515205140.GD29627@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <5e9ee3b123b3d648487cd18dc906b6a2cd23085b.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5e9ee3b123b3d648487cd18dc906b6a2cd23085b.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:04:16PM +0200, Andreas Gruenbacher wrote:
> So far, richacl_equiv_mode() is relatively limited in the types of acl it
> considers equivalent to a file mode: it only accepts masked acls with a single
> everyone@:rwpxd::allow entry.
> 
> Change this to consider all acls equivalent to file modes if they only consist
> of owner@, group@, and everyone@ entries and the owner@ permissions do not
> depend on whether the owner is a member in the owning group.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_base.c       | 150 ++++++++++++++++++++++++++++++++++++++----------
>  include/linux/richacl.h |   1 +
>  2 files changed, 122 insertions(+), 29 deletions(-)
> 
> diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> index db27542..54cb482 100644
> --- a/fs/richacl_base.c
> +++ b/fs/richacl_base.c
> @@ -439,49 +439,141 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
>  }
>  
>  /**
> - * richacl_equiv_mode  -  check if @acl is equivalent to file permission bits
> - * @mode_p:	the file mode (including the file type)
> + * __richacl_equiv_mode  -  compute the mode equivalent of @acl
>   *
> - * If @acl can be fully represented by file permission bits, this function
> - * returns 0, and the file permission bits in @mode_p are set to the equivalent
> - * of @acl.

This comment is a little confusing:

> + * This function does not consider the masks in @acl.

Given that we do this later:

> +	if (acl->a_flags & RICHACL_MASKED) {
> +		owner.allowed &= acl->a_owner_mask;
> +		group.allowed &= acl->a_group_mask;
> +		everyone.allowed &= acl->a_other_mask;
> +	}

I think the difference is that here you're checking that the end result
after applying masks is mode-equivalent, whereas in riachacl_equiv_mode:

> +	if (acl->a_flags & RICHACL_MASKED) {
> +		mode_t mask = richacl_masks_to_mode(acl);
> +		unsigned int x;
> +
> +		/* Mask flags we can ignore */
> +		x = ~(RICHACE_POSIX_ALWAYS_ALLOWED |
> +		      (S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD));
> +
> +		if (((acl->a_group_mask ^ richacl_mode_to_mask(mask >> 3)) & x) ||
> +		    ((acl->a_other_mask ^ richacl_mode_to_mask(mask)) & x))
> +			return -1;
> +
> +		x &= ~RICHACE_POSIX_OWNER_ALLOWED;
> +		if ((acl->a_owner_mask ^ richacl_mode_to_mask(mask >> 6)) & x)
> +			return -1;
> +
> +		mode &= ~S_IRWXUGO | mask;
> +	}

... you're also checking whether the masks themselves are
mode-equivalent?  Is that the right thing to do?

I've probably misread the code again....

--b.
