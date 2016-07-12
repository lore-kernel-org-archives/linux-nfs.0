Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36640 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbcGLTLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2016 15:11:44 -0400
Date: Tue, 12 Jul 2016 15:11:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v23 17/22] richacl: Automatic Inheritance
Message-ID: <20160712191142.GE449@fieldses.org>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
 <1467294433-3222-18-git-send-email-agruenba@redhat.com>
 <1468324560.7798.14.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1468324560.7798.14.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 12, 2016 at 07:56:00AM -0400, Jeff Layton wrote:
> On Thu, 2016-06-30 at 15:47 +0200, Andreas Gruenbacher wrote:
> > Automatic Inheritance (AI) allows changes to the acl of a directory to
> > propagate down to children.
> > 
> > This is mostly implemented in user space: when a process changes the
> > permissions of a directory and Automatic Inheritance is enabled for that
> > directory, the process must propagate those changes to all children,
> > recursively.
> > 
> > The kernel enables this by keeping track of which permissions have been
> > inherited at create time.  In addition, it makes sure that permission
> > propagation is turned off when the permissions are set explicitly (for
> > example, upon create or chmod).
> > 
> > Automatic Inheritance works as follows:
> > 
> >  - When the RICHACL_AUTO_INHERIT flag in the acl of a file or directory
> >    is not set, the file or directory is not affected by AI.
> > 
> >  - When the RICHACL_AUTO_INHERIT flag in the acl of a directory is set
> >    and a file or subdirectory is created in that directory, the
> >    inherited acl will have the RICHACL_AUTO_INHERIT flag set, and all
> >    inherited aces will have the RICHACE_INHERITED_ACE flag set.  This
> >    allows user space to distinguish between aces which have been
> >    inherited and aces which have been explicitly added.
> > 
> >  - When the RICHACL_PROTECTED acl flag in the acl of a file or directory
> >    is set, AI will not modify the acl.  This does not affect propagation
> >    of permissions from the file to its children (if the file is a
> >    directory).
> > 
> > Linux does not have a way of creating files or directories without setting the
> > file permission bits, so all files created inside a directory with
> > RICHACL_AUTO_INHERIT set will have the RICHACL_PROTECTED flag set.  This
> > effectively disables Automatic Inheritance.
> > 
> > Protocols which support creating files without specifying permissions can
> > explicitly clear the RICHACL_PROTECTED flag after creating a file and reset the
> > file masks to "undo" applying the create mode; see richacl_compute_max_masks().
> > They should set the RICHACL_DEFAULTED flag.  (A mechanism that would allow to
> > indicate to the kernel to ignore the create mode in the first place when there
> > are inherited permissions would be nice to have.)
> > 
> > Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> > ---
> >  fs/richacl.c                 | 20 +++++++++++++++++++-
> >  include/linux/richacl.h      | 12 ++++++++++++
> >  include/uapi/linux/richacl.h | 11 ++++++++++-
> >  3 files changed, 41 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/richacl.c b/fs/richacl.c
> > index 29eaf89..40e4af9 100644
> > --- a/fs/richacl.c
> > +++ b/fs/richacl.c
> > @@ -573,7 +573,8 @@ __richacl_chmod(struct richacl *acl, umode_t mode)
> >  	    acl->a_group_mask == group_mask &&
> >  	    acl->a_other_mask == other_mask &&
> >  	    (acl->a_flags & RICHACL_MASKED) &&
> > -	    (acl->a_flags & RICHACL_WRITE_THROUGH))
> > +	    (acl->a_flags & RICHACL_WRITE_THROUGH) &&
> > +	    (!richacl_is_auto_inherit(acl) || richacl_is_protected(acl)))
> >  		return acl;
> >  
> >  	clone = richacl_clone(acl, GFP_KERNEL);
> > @@ -585,6 +586,8 @@ __richacl_chmod(struct richacl *acl, umode_t mode)
> >  	clone->a_owner_mask = owner_mask;
> >  	clone->a_group_mask = group_mask;
> >  	clone->a_other_mask = other_mask;
> > +	if (richacl_is_auto_inherit(clone))
> > +		clone->a_flags |= RICHACL_PROTECTED;
> >  
> >  	return clone;
> >  }
> > @@ -800,6 +803,14 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
> >  			ace++;
> >  		}
> >  	}
> > +	if (richacl_is_auto_inherit(dir_acl)) {
> > +		acl->a_flags = RICHACL_AUTO_INHERIT;
> > +		richacl_for_each_entry(ace, acl)
> > +			ace->e_flags |= RICHACE_INHERITED_ACE;
> > +	} else {
> > +		richacl_for_each_entry(ace, acl)
> > +			ace->e_flags &= ~RICHACE_INHERITED_ACE;
> > +	}
> >  
> >  	return acl;
> >  }
> > @@ -828,6 +839,13 @@ richacl_inherit_inode(const struct richacl *dir_acl, umode_t *mode_p)
> >  			richacl_put(acl);
> >  			acl = NULL;
> >  		} else {
> > +			/*
> > +			 * We need to set RICHACL_PROTECTED because we are
> > +			 * doing an implicit chmod
> > +			 */
> > +			if (richacl_is_auto_inherit(acl))
> > +				acl->a_flags |= RICHACL_PROTECTED;
> > +
> >  			richacl_compute_max_masks(acl);
> >  			/*
> >  			 * Ensure that the acl will not grant any permissions
> > diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> > index 7aca1a3..a442372 100644
> > --- a/include/linux/richacl.h
> > +++ b/include/linux/richacl.h
> > @@ -81,6 +81,18 @@ extern void set_cached_richacl(struct inode *, struct richacl *);
> >  extern void forget_cached_richacl(struct inode *);
> >  extern struct richacl *get_richacl(struct inode *);
> >  
> > +static inline int
> > +richacl_is_auto_inherit(const struct richacl *acl)
> > +{
> > +	return acl->a_flags & RICHACL_AUTO_INHERIT;
> > +}
> > +
> > +static inline int
> > +richacl_is_protected(const struct richacl *acl)
> > +{
> > +	return acl->a_flags & RICHACL_PROTECTED;
> > +}
> > +
> >  /**
> >   * richace_is_owner  -  check if @ace is an OWNER@ entry
> >   */
> > diff --git a/include/uapi/linux/richacl.h b/include/uapi/linux/richacl.h
> > index 1ed48ac..8849a53 100644
> > --- a/include/uapi/linux/richacl.h
> > +++ b/include/uapi/linux/richacl.h
> > @@ -18,6 +18,9 @@
> >  #define __UAPI_RICHACL_H
> >  
> >  /* a_flags values */
> > +#define RICHACL_AUTO_INHERIT			0x01
> > +#define RICHACL_PROTECTED			0x02
> > +#define RICHACL_DEFAULTED			0x04
> >  #define RICHACL_WRITE_THROUGH			0x40
> >  #define RICHACL_MASKED				0x80
> >  
> > @@ -31,6 +34,7 @@
> >  #define RICHACE_NO_PROPAGATE_INHERIT_ACE	0x0004
> >  #define RICHACE_INHERIT_ONLY_ACE		0x0008
> >  #define RICHACE_IDENTIFIER_GROUP		0x0040
> > +#define RICHACE_INHERITED_ACE			0x0080
> >  #define RICHACE_SPECIAL_WHO			0x4000
> >  
> >  /* e_mask bitflags */
> > @@ -60,6 +64,9 @@
> >  #define RICHACE_EVERYONE_SPECIAL_ID		2
> >  
> >  #define RICHACL_VALID_FLAGS (					\
> > +	RICHACL_AUTO_INHERIT |					\
> > +	RICHACL_PROTECTED |					\
> > +	RICHACL_DEFAULTED |					\
> >  	RICHACL_WRITE_THROUGH |					\
> >  	RICHACL_MASKED )
> >  
> > @@ -69,13 +76,15 @@
> >  	RICHACE_NO_PROPAGATE_INHERIT_ACE |			\
> >  	RICHACE_INHERIT_ONLY_ACE |				\
> >  	RICHACE_IDENTIFIER_GROUP |				\
> > +	RICHACE_INHERITED_ACE |					\
> >  	RICHACE_SPECIAL_WHO )
> >  
> >  #define RICHACE_INHERITANCE_FLAGS (				\
> >  	RICHACE_FILE_INHERIT_ACE |				\
> >  	RICHACE_DIRECTORY_INHERIT_ACE |				\
> >  	RICHACE_NO_PROPAGATE_INHERIT_ACE |			\
> > -	RICHACE_INHERIT_ONLY_ACE )
> > +	RICHACE_INHERIT_ONLY_ACE |				\
> > +	RICHACE_INHERITED_ACE )
> >  
> >  /* Valid RICHACE_* flags for directories and non-directories */
> >  #define RICHACE_VALID_MASK (					
> > \
> 
> Barf. AI seems like a trainwreck waiting to happen. What are the
> chances that userland is going to get this right?

This is just taken from Windows, so presumably Samba should do the right
thing (with one workaround required--see the discussion of PROTECTED in
the changelog).

> Still, I do applaud the fact that you're just doing the bare minimum in
> kernel to support userland apps that want this. Thanks for not trying
> to push the propagation of the changed ACEs into the kernel.

Agreed.  But, again, this is just what Windows does.  (I wonder whether
there's an OS that's actually tried do any sort of atomic propagation.)

--b.
