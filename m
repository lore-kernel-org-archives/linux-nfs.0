Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:55302 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab1IHK1z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 06:27:55 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, agruen@linbit.com
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 14/26] richacl: Permission mapping functions
In-Reply-To: <20110907212400.GH8074@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110907212400.GH8074@fieldses.org>
Date: Thu, 08 Sep 2011 15:57:37 +0530
Message-ID: <87aaaf5nxi.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 7 Sep 2011 17:24:00 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Sep 05, 2011 at 10:55:36PM +0530, Aneesh Kumar K.V wrote:
> > From: Andreas Gruenbacher <agruen@kernel.org>
> > 
> > We need to map from POSIX permissions to NFSv4 permissions when a
> > chmod() is done, from NFSv4 permissions to POSIX permissions when an acl
> > is set (which implicitly sets the file permission bits), and from the
> > MAY_READ/MAY_WRITE/MAY_EXEC/MAY_APPEND flags to NFSv4 permissions when
> > doing an access check in a richacl.
> > 
> > Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  fs/richacl_base.c       |  118 +++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/richacl.h |   46 ++++++++++++++++++
> >  2 files changed, 164 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> > index 3536626..d55b436 100644
> > --- a/fs/richacl_base.c
> > +++ b/fs/richacl_base.c
> > @@ -69,6 +69,124 @@ richacl_clone(const struct richacl *acl)
> >  }
> >  
> >  /**
> > + * richacl_mask_to_mode  -  compute the file permission bits which correspond to @mask
> > + * @mask:	%ACE4_* permission mask
> > + *
> > + * See richacl_masks_to_mode().
> > + */
> > +static int
> > +richacl_mask_to_mode(unsigned int mask)
> > +{
> > +	int mode = 0;
> > +
> > +	if (mask & ACE4_POSIX_MODE_READ)
> > +		mode |= MAY_READ;
> > +	if (mask & ACE4_POSIX_MODE_WRITE)
> > +		mode |= MAY_WRITE;
> > +	if (mask & ACE4_POSIX_MODE_EXEC)
> > +		mode |= MAY_EXEC;
> > +
> > +	return mode;
> > +}
> > +
> > +/**
> > + * richacl_masks_to_mode  -  compute the file permission bits from the file masks
> > + *
> > + * When setting a richacl, we set the file permission bits to indicate maximum
> > + * permissions: for example, we set the Write permission when a mask contains
> > + * ACE4_APPEND_DATA even if it does not also contain ACE4_WRITE_DATA.
> > + *
> > + * Permissions which are not in ACE4_POSIX_MODE_READ, ACE4_POSIX_MODE_WRITE, or
> > + * ACE4_POSIX_MODE_EXEC cannot be represented in the file permission bits.
> > + * Such permissions can still be effective, but not for new files or after a
> > + * chmod(), and only if they were set explicitly, for example, by setting a
> > + * richacl.
> > + */
> > +int
> > +richacl_masks_to_mode(const struct richacl *acl)
> > +{
> > +	return richacl_mask_to_mode(acl->a_owner_mask) << 6 |
> > +	       richacl_mask_to_mode(acl->a_group_mask) << 3 |
> > +	       richacl_mask_to_mode(acl->a_other_mask);
> > +}
> > +EXPORT_SYMBOL_GPL(richacl_masks_to_mode);
> > +
> > +/**
> > + * richacl_mode_to_mask  - compute a file mask from the lowest three mode bits
> > + *
> > + * When the file permission bits of a file are set with chmod(), this specifies
> > + * the maximum permissions that processes will get.  All permissions beyond
> > + * that will be removed from the file masks, and become ineffective.
> > + *
> > + * We also add in the permissions which are always allowed no matter what the
> > + * acl says.
> > + */
> > +unsigned int
> > +richacl_mode_to_mask(mode_t mode)
> > +{
> > +	unsigned int mask = ACE4_POSIX_ALWAYS_ALLOWED;
> > +
> > +	if (mode & MAY_READ)
> > +		mask |= ACE4_POSIX_MODE_READ;
> > +	if (mode & MAY_WRITE)
> > +		mask |= ACE4_POSIX_MODE_WRITE;
> > +	if (mode & MAY_EXEC)
> > +		mask |= ACE4_POSIX_MODE_EXEC;
> > +
> > +	return mask;
> > +}
> > +
> > +/**
> > + * richacl_want_to_mask  - convert the iop->permission want argument to a mask
> > + * @want:	@want argument of the permission inode operation
> > + *
> > + * When checking for append, @want is (MAY_WRITE | MAY_APPEND).
> > + *
> > + * Richacls use the iop->may_create and iop->may_delete hooks which are
> > + * used for checking if creating and deleting files is allowed.  These hooks do
> > + * not use richacl_want_to_mask(), so we do not have to deal with mapping
> > + * MAY_WRITE to ACE4_ADD_FILE, ACE4_ADD_SUBDIRECTORY, and ACE4_DELETE_CHILD
> > + * here.
> > + */
> > +unsigned int
> > +richacl_want_to_mask(int want)
> > +{
> > +	unsigned int mask = 0;
> > +
> > +	if (want & MAY_READ)
> > +		mask |= ACE4_READ_DATA;
> > +	if (want & (MAY_APPEND |
> > +		    MAY_CREATE_FILE | MAY_CREATE_DIR |
> > +		    MAY_DELETE_CHILD | MAY_DELETE_SELF |
> > +		    MAY_TAKE_OWNERSHIP | MAY_CHMOD | MAY_SET_TIMES)) {
> > +		if (want & MAY_APPEND)
> > +			mask |= ACE4_APPEND_DATA;
> > +		else if (want & MAY_DELETE_SELF)
> > +			mask |= ACE4_DELETE;
> > +		else if (want & MAY_TAKE_OWNERSHIP)
> > +			mask |= ACE4_WRITE_OWNER;
> > +		else if (want & MAY_CHMOD)
> > +			mask |= ACE4_WRITE_ACL;
> > +		else if (want & MAY_SET_TIMES)
> > +			mask |= ACE4_WRITE_ATTRIBUTES;
> > +		else {
> > +			if (want & MAY_CREATE_FILE)
> > +				mask |= ACE4_ADD_FILE;
> > +			if (want & MAY_CREATE_DIR)
> > +				mask |= ACE4_ADD_SUBDIRECTORY;
> > +			if (want & MAY_DELETE_CHILD)
> > +				mask |= ACE4_DELETE_CHILD;
> > +		}
> 
> Possibly dumb question: why isn't this whole function a simple series of
> if's, one for each MAY_ bit?
> 
> I guess you're using knowledge about the callers to know that, for
> example, no one will ask for MAY_APPEND and MAY_TAKE_OWNERSHIP at the
> same time?
> 
> And adding that big "if (want & (MAY_APPEND | .. | MAY_SET_TIMES))" to
> let you skip over a bunch of checks in the common case?
> 
> Does this help measurably?  It seems complicated and, to the extent it
> makes assumptions about the callers, possibly fragile with respect to
> future changes.
> 

Not the complete function. But I guess we can do the below change. 
We still want to keep  MAY_WRITE check separate, because VFS do add
MAY_WRITE request to different type of request other than write.

Andreas,

Do you see any issue in doing below ?

richacl_want_to_mask(int want)
{
	unsigned int mask = 0;

	if (want & MAY_READ)
		mask |= ACE4_READ_DATA;
	if (want & MAY_DELETE_SELF)
		mask |= ACE4_DELETE;
	if (want & MAY_TAKE_OWNERSHIP)
		mask |= ACE4_WRITE_OWNER;
	if (want & MAY_CHMOD)
		mask |= ACE4_WRITE_ACL;
	if (want & MAY_SET_TIMES)
		mask |= ACE4_WRITE_ATTRIBUTES;
	if (want & MAY_EXEC)
		mask |= ACE4_EXECUTE;
	/*
	 * differentiate MAY_WRITE from these request
	 */
	if (want & (MAY_APPEND |
		    MAY_CREATE_FILE | MAY_CREATE_DIR |
		    MAY_DELETE_CHILD)) {
		if (want & MAY_APPEND)
			mask |= ACE4_APPEND_DATA;
		if (want & MAY_CREATE_FILE)
			mask |= ACE4_ADD_FILE;
		if (want & MAY_CREATE_DIR)
			mask |= ACE4_ADD_SUBDIRECTORY;
		if (want & MAY_DELETE_CHILD)
			mask |= ACE4_DELETE_CHILD;
	} else if (want & MAY_WRITE)
		mask |= ACE4_WRITE_DATA;
	return mask;
}

-aneesh
