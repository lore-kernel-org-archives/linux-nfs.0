Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46316 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934443AbbEOUEd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 16:04:33 -0400
Date: Fri, 15 May 2015 16:04:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 19/45] richacl: Also recognize nontrivial
 mode-equivalent acls
Message-ID: <20150515200430.GC29627@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <5e9ee3b123b3d648487cd18dc906b6a2cd23085b.1429868795.git.agruenba@redhat.com>
 <20150514192806.GG12861@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150514192806.GG12861@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 14, 2015 at 03:28:06PM -0400, bfields wrote:
> On Fri, Apr 24, 2015 at 01:04:16PM +0200, Andreas Gruenbacher wrote:
> > So far, richacl_equiv_mode() is relatively limited in the types of acl it
> > considers equivalent to a file mode: it only accepts masked acls with a single
> > everyone@:rwpxd::allow entry.
> > 
> > Change this to consider all acls equivalent to file modes if they only consist
> > of owner@, group@, and everyone@ entries and the owner@ permissions do not
> > depend on whether the owner is a member in the owning group.
> > 
> > Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> > ---
> >  fs/richacl_base.c       | 150 ++++++++++++++++++++++++++++++++++++++----------
> >  include/linux/richacl.h |   1 +
> >  2 files changed, 122 insertions(+), 29 deletions(-)
> > 
> > diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> > index db27542..54cb482 100644
> > --- a/fs/richacl_base.c
> > +++ b/fs/richacl_base.c
> > @@ -439,49 +439,141 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
> >  }
> >  
> >  /**
> > - * richacl_equiv_mode  -  check if @acl is equivalent to file permission bits
> > - * @mode_p:	the file mode (including the file type)
> > + * __richacl_equiv_mode  -  compute the mode equivalent of @acl
> >   *
> > - * If @acl can be fully represented by file permission bits, this function
> > - * returns 0, and the file permission bits in @mode_p are set to the equivalent
> > - * of @acl.
> > + * This function does not consider the masks in @acl.
> >   *
> > - * This function is used to avoid storing richacls on disk if the acl can be
> > - * computed from the file permission bits.  It allows user-space to make sure
> > - * that a file has no explicit richacl set.
> > + * An acl is considered equivalent to a file mode if it only consists of
> > + * owner@, group@, and everyone@ entries and the owner@ permissions do not
> > + * depend on whether the owner is a member in the owning group.
> >   */
> >  int
> > -richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
> > +__richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
> >  {
> > -	const struct richace *ace = acl->a_entries;
> > -	unsigned int x;
> > -	mode_t mask;
> > -
> > -	if (acl->a_count != 1 ||
> > -	    acl->a_flags != RICHACL_MASKED ||
> > -	    !richace_is_everyone(ace) ||
> > -	    !richace_is_allow(ace) ||
> > -	    ace->e_flags & ~RICHACE_SPECIAL_WHO)
> > +	mode_t mode = *mode_p;
> > +
> > +	/*
> > +	 * The RICHACE_DELETE_CHILD flag is meaningless for non-directories, so
> > +	 * we ignore it.
> > +	 */
> > +	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
> > +	struct {
> > +		unsigned int allowed;
> > +		unsigned int defined;  /* allowed or denied */
> > +	} owner = {
> > +		.allowed = RICHACE_POSIX_ALWAYS_ALLOWED,
> > +		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | RICHACE_POSIX_OWNER_ALLOWED | x,
> > +	}, group = {
> > +		.allowed = RICHACE_POSIX_ALWAYS_ALLOWED,
> > +		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
> > +	}, everyone = {
> > +		.allowed = RICHACE_POSIX_ALWAYS_ALLOWED,
> > +		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
> > +	};
> > +	const struct richace *ace;
> > +
> 
> I'm having trouble following this code.  Some comments just to see if I
> can figure it out:
> 
> > +	richacl_for_each_entry(ace, acl) {
> > +		if (ace->e_flags & ~RICHACE_SPECIAL_WHO)
> > +			return -1;
> > +
> > +		if (richace_is_owner(ace) || richace_is_everyone(ace)) {
> > +			x = ace->e_mask & ~owner.defined;
> 
> So x is now the acl mask with the always-permitted bits ignored.

No, I was confused: that's only true the first time through, on
subsequent runs it's basically "everything in this mask that's not
already been allowed or denied to the owner".

> 
> > +			if (richace_is_allow(ace)) {
> > +				unsigned int group_denied = group.defined & ~group.allowed;
> > +
> > +				if (x & group_denied)
> > +					return -1;
> 
> If we've already denied something to the group we don't want to later
> allow it to the owner, because that could make the ACL behave
> differently depending on whether the owner was a member of the group,
> not something a mode can do.  OK, understood.
> 
> (This is possibly overkill, since it rejects e.g.
> 
> 	deny owner all
> 	deny group all
> 	allow everyone all

So in this example, by the time we get down here, owner.defined has all
bits set, so x is 0, so I was wrong, this wouldn't be rejected.

> 
> which is equivalent to 007?  But some overkill's OK.)
> 
> 
> > +				owner.allowed |= x;
> > +			} else /* if (richace_is_deny(ace)) */ {
> > +				if (x & group.allowed)
> > +					return -1;
> 
> Uh, so same rationale as above, I guess, this might lead to different
> results depending on whether the owner's also a member of the group.

And what the above test and this one are saying is:

	- could this ace allow something to the owner previously denied
	  to the group?
	- could this ace deny something to the owner previously allowed
	  to the group?

And checking this at each step is the same as testing whether the result
might vary depending whether the owner's in the group.  Got it!  Sorry
it took me a while to puzzle through....

Couldn't you also do this by doing the usual reverse scan through the
acl applying permissions, but separately tracking:

	- mask that would be allowed to the owner assuming it's a member
	  of the group
	- mask that would be allowed to the owner assuming it's not a
	  member of the group

and then comparing the two at the end?

Admittedly I don't know if that'd be simpler or not.

--b.

> 
> > +			}
> > +			owner.defined |= x;
> > +
> > +			if (richace_is_everyone(ace)) {
> > +				x = ace->e_mask;
> > +				if (richace_is_allow(ace)) {
> > +					group.allowed |= x & ~group.defined;
> > +					everyone.allowed |= x & ~everyone.defined;
> > +				}
> > +				group.defined |= x;
> > +				everyone.defined |= x;
> > +			}
> > +		} else if (richace_is_group(ace)) {
> > +			x = ace->e_mask & ~group.defined;
> > +			if (richace_is_allow(ace))
> > +				group.allowed |= x;
> > +			group.defined |= x;
> > +		} else
> > +			return -1;
> 
> This last else clause is redundant with the first RICHACE_SPECIAL_WHO
> check, right?  Not that I necessarily object.
> 
> --b.
> 
> > +	}
> > +
> > +	if (group.allowed & ~owner.defined)
> >  		return -1;
> >  
> > -	/* Mask flags we can ignore */
> > -	x = ~RICHACE_POSIX_ALWAYS_ALLOWED;
> > -	if (!S_ISDIR(*mode_p))
> > -		x &= ~RICHACE_DELETE_CHILD;
> > +	if (acl->a_flags & RICHACL_MASKED) {
> > +		owner.allowed &= acl->a_owner_mask;
> > +		group.allowed &= acl->a_group_mask;
> > +		everyone.allowed &= acl->a_other_mask;
> > +	}
> >  
> > -	mask = richacl_masks_to_mode(acl);
> > -	if (((acl->a_group_mask ^ richacl_mode_to_mask(mask >> 3)) & x) ||
> > -	    ((acl->a_other_mask ^ richacl_mode_to_mask(mask)) & x))
> > +	mode = (mode & ~S_IRWXUGO) |
> > +	       (richacl_mask_to_mode(owner.allowed) << 6) |
> > +	       (richacl_mask_to_mode(group.allowed) << 3) |
> > +		richacl_mask_to_mode(everyone.allowed);
> > +
> > +	/* Mask flags we can ignore */
> > +	x = ~(S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD);
> > +	if (((richacl_mode_to_mask(mode >> 6) ^ owner.allowed) & x) ||
> > +	    ((richacl_mode_to_mask(mode >> 3) ^ group.allowed) & x) ||
> > +	    ((richacl_mode_to_mask(mode)      ^ everyone.allowed) & x))
> >  		return -1;
> >  
> > -	x &= ~RICHACE_POSIX_OWNER_ALLOWED;
> > -	if ((acl->a_owner_mask ^ richacl_mode_to_mask(mask >> 6)) & x)
> > +	*mode_p = mode;
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(__richacl_equiv_mode);
> > +
> > +/**
> > + * richacl_equiv_mode  -  determine if @acl is equivalent to a file mode
> > + * @mode_p:	the file mode
> > + *
> > + * The file type in @mode_p must be set when calling richacl_equiv_mode().
> > + *
> > + * Returns with 0 if @acl is equivalent to a file mode; in that case, the
> > + * file permission bits in @mode_p are set to the mode equivalent of @acl.
> > + */
> > +int
> > +richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
> > +{
> > +	mode_t mode = *mode_p;
> > +
> > +	if (acl->a_flags & ~RICHACL_MASKED)
> >  		return -1;
> >  
> > -	if ((ace->e_mask ^ RICHACE_POSIX_MODE_ALL) & x)
> > +	if (__richacl_equiv_mode(acl, &mode))
> >  		return -1;
> >  
> > -	*mode_p = (*mode_p & ~S_IRWXUGO) | mask;
> > +	if (acl->a_flags & RICHACL_MASKED) {
> > +		mode_t mask = richacl_masks_to_mode(acl);
> > +		unsigned int x;
> > +
> > +		/* Mask flags we can ignore */
> > +		x = ~(RICHACE_POSIX_ALWAYS_ALLOWED |
> > +		      (S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD));
> > +
> > +		if (((acl->a_group_mask ^ richacl_mode_to_mask(mask >> 3)) & x) ||
> > +		    ((acl->a_other_mask ^ richacl_mode_to_mask(mask)) & x))
> > +			return -1;
> > +
> > +		x &= ~RICHACE_POSIX_OWNER_ALLOWED;
> > +		if ((acl->a_owner_mask ^ richacl_mode_to_mask(mask >> 6)) & x)
> > +			return -1;
> > +
> > +		mode &= ~S_IRWXUGO | mask;
> > +	}
> > +
> > +	*mode_p = mode;
> >  	return 0;
> >  }
> >  EXPORT_SYMBOL_GPL(richacl_equiv_mode);
> > diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> > index c6fd0a1..8a92b89 100644
> > --- a/include/linux/richacl.h
> > +++ b/include/linux/richacl.h
> > @@ -297,6 +297,7 @@ extern unsigned int richacl_want_to_mask(unsigned int);
> >  extern void richacl_compute_max_masks(struct richacl *);
> >  extern struct richacl *richacl_chmod(struct richacl *, mode_t);
> >  extern struct richacl *richacl_inherit(const struct richacl *, int);
> > +extern int __richacl_equiv_mode(const struct richacl *, mode_t *);
> >  extern int richacl_equiv_mode(const struct richacl *, mode_t *);
> >  
> >  /* richacl_inode.c */
> > -- 
> > 2.1.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
