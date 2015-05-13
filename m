Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:40078 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752871AbbEMSOE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 14:14:04 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Andreas Gruenbacher'" <andreas.gruenbacher@gmail.com>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <cover.1429868795.git.agruenba@redhat.com> <28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
In-Reply-To: <28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
Subject: RE: [RFC v3 20/45] richacl: Automatic Inheritance
Date: Wed, 13 May 2015 11:01:35 -0700
Message-ID: <0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Andreas Gruenbacher
> Sent: Friday, April 24, 2015 4:04 AM
> To: linux-kernel@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-
> nfs@vger.kernel.org
> Subject: [RFC v3 20/45] richacl: Automatic Inheritance
> 
> Automatic Inheritance (AI) allows changes to the acl of a directory to
> recursively propagate down to files and directories in the directory.
> 
> To implement this, the kernel keeps track of which permissions have been
> inherited, and makes sure that permission propagation is turned off when
> the file permission bits of a file are changed (upon create or chmod).
> 
> The actual permission propagation is implemented in user space.
> 
> Automatic Inheritance works as follows:
> 
>  - When the ACL4_AUTO_INHERIT flag in the acl of a file is not set, the
>    file is not affected by AI.
> 
>  - When the ACL4_AUTO_INHERIT flag in the acl of a directory is set and
>    a file or subdirectory is created in that directory, files created in
>    the directory will have the ACL4_AUTO_INHERIT flag set, and all
>    inherited aces will have the ACE4_INHERITED_ACE flag set.  This
>    allows user space to distinguish between aces which have been
>    inherited and aces which have been explicitly added.
> 
>  - When the ACL4_PROTECTED acl flag in the acl of a file is set, AI will
>    not modify the acl of the file.  This does not affect propagation of
>    permissions from the file to its children (if the file is a
>    directory).

You might want to edit your commit message to use RICHACL_ instead of ACL4_
constants...

> Linux does not have a way of creating files without setting the file
permission
> bits, so all files created inside a directory with ACL4_AUTO_INHERIT set
will
> also have the ACL4_PROTECTED flag set.  This effectively disables
Automatic
> Inheritance.
> 
> Protocols which support creating files without specifying permissions can
> explicitly clear the ACL4_PROTECTED flag after creating a file and reset
the file
> masks to "undo" applying the create mode; see
> richacl_compute_max_masks().
> This is a workaround; a mechanism that would allow a process to indicate
to
> the kernel to ignore the create mode when there are inherited permissions
> would fix this problem.

I'm unclear what will actually be supported for inherited ACLs here. Is this
saying that on a pure-Linux system even with Linux NFS client and Linux NFS
server, we still would not see inheritance since the mode will always be
present on create?

My interest here is in how we will tie the Ganesha user space NFS server
into this feature.

Frank

> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/richacl_base.c       | 10 +++++++++-
>  fs/richacl_inode.c      |  7 ++++++-
>  include/linux/richacl.h | 25 +++++++++++++++++++++++--
>  3 files changed, 38 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/richacl_base.c b/fs/richacl_base.c index 54cb482..572f1b8
> 100644
> --- a/fs/richacl_base.c
> +++ b/fs/richacl_base.c
> @@ -352,7 +352,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
>  	if (acl->a_owner_mask == owner_mask &&
>  	    acl->a_group_mask == group_mask &&
>  	    acl->a_other_mask == other_mask &&
> -	    (acl->a_flags & RICHACL_MASKED))
> +	    (acl->a_flags & RICHACL_MASKED) &&
> +	    (!richacl_is_auto_inherit(acl) || richacl_is_protected(acl)))
>  		return acl;
> 
>  	clone = richacl_clone(acl, GFP_KERNEL); @@ -364,6 +365,8 @@
> richacl_chmod(struct richacl *acl, mode_t mode)
>  	clone->a_owner_mask = owner_mask;
>  	clone->a_group_mask = group_mask;
>  	clone->a_other_mask = other_mask;
> +	if (richacl_is_auto_inherit(clone))
> +		clone->a_flags |= RICHACL_PROTECTED;
> 
>  	return clone;
>  }
> @@ -434,6 +437,11 @@ richacl_inherit(const struct richacl *dir_acl, int
isdir)
>  			ace++;
>  		}
>  	}
> +	if (richacl_is_auto_inherit(dir_acl)) {
> +		acl->a_flags = RICHACL_AUTO_INHERIT;
> +		richacl_for_each_entry(ace, acl)
> +			ace->e_flags |= RICHACE_INHERITED_ACE;
> +	}
> 
>  	return acl;
>  }
> diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c index
1a5b868..dfbb15a
> 100644
> --- a/fs/richacl_inode.c
> +++ b/fs/richacl_inode.c
> @@ -223,9 +223,14 @@ richacl_inherit_inode(const struct richacl *dir_acl,
> struct inode *inode)
> 
>  	acl = richacl_inherit(dir_acl, S_ISDIR(inode->i_mode));
>  	if (acl) {
> +		/*
> +		 * We need to set RICHACL_PROTECTED because we are
> +		 * doing an implicit chmod
> +		 */
> +		if (richacl_is_auto_inherit(acl))
> +			acl->a_flags |= RICHACL_PROTECTED;
> 
>  		richacl_compute_max_masks(acl);
> -
>  		/*
>  		 * Ensure that the acl will not grant any permissions beyond
>  		 * the create mode.
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h index
> 8a92b89..bcc2b64 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -53,9 +53,15 @@ struct richacl {
>  	     _ace--)
> 
>  /* a_flag values */
> +#define RICHACL_AUTO_INHERIT			0x01
> +#define RICHACL_PROTECTED			0x02
> +#define RICHACL_DEFAULTED			0x04
>  #define RICHACL_MASKED				0x80
> 
> -#define RICHACL_VALID_FLAGS (					\
> +#define RICHACL_VALID_FLAGS (			\
> +		RICHACL_AUTO_INHERIT |		\
> +		RICHACL_PROTECTED |		\
> +		RICHACL_DEFAULTED |		\
>  		RICHACL_MASKED)
> 
>  /* e_type values */
> @@ -68,6 +74,7 @@ struct richacl {
>  #define RICHACE_NO_PROPAGATE_INHERIT_ACE	0x0004
>  #define RICHACE_INHERIT_ONLY_ACE		0x0008
>  #define RICHACE_IDENTIFIER_GROUP		0x0040
> +#define RICHACE_INHERITED_ACE			0x0080
>  #define RICHACE_SPECIAL_WHO			0x4000
> 
>  #define RICHACE_VALID_FLAGS (					\
> @@ -76,6 +83,7 @@ struct richacl {
>  	RICHACE_NO_PROPAGATE_INHERIT_ACE |			\
>  	RICHACE_INHERIT_ONLY_ACE |				\
>  	RICHACE_IDENTIFIER_GROUP |				\
> +	RICHACE_INHERITED_ACE |					\
>  	RICHACE_SPECIAL_WHO)
> 
>  /* e_mask bitflags */
> @@ -187,6 +195,18 @@ extern void set_cached_richacl(struct inode *, struct
> richacl *);  extern void forget_cached_richacl(struct inode *);  extern
struct
> richacl *get_richacl(struct inode *);
> 
> +static inline int
> +richacl_is_auto_inherit(const struct richacl *acl) {
> +	return acl->a_flags & RICHACL_AUTO_INHERIT; }
> +
> +static inline int
> +richacl_is_protected(const struct richacl *acl) {
> +	return acl->a_flags & RICHACL_PROTECTED; }
> +
>  /**
>   * richace_is_owner  -  check if @ace is an OWNER@ entry
>   */
> @@ -257,7 +277,8 @@ richace_clear_inheritance_flags(struct richace *ace)
>  	ace->e_flags &= ~(RICHACE_FILE_INHERIT_ACE |
>  			  RICHACE_DIRECTORY_INHERIT_ACE |
>  			  RICHACE_NO_PROPAGATE_INHERIT_ACE |
> -			  RICHACE_INHERIT_ONLY_ACE);
> +			  RICHACE_INHERIT_ONLY_ACE |
> +			  RICHACE_INHERITED_ACE);
>  }
> 
>  /**
> --
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

