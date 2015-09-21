Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60775 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756124AbbIUTYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 15:24:42 -0400
Date: Mon, 21 Sep 2015 15:24:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v7 22/41] richacl: Propagate everyone@ permissions to other
 aces
Message-ID: <20150921192441.GA12968@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-23-git-send-email-agruenba@redhat.com>
 <20150918215611.GD22671@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150918215611.GD22671@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 18, 2015 at 05:56:11PM -0400, bfields wrote:
> On Sat, Sep 05, 2015 at 12:27:17PM +0200, Andreas Gruenbacher wrote:
> > The trailing everyone@ allow ace can grant permissions to all file
> > classes including the owner and group class.  Before we can apply the
> > other mask to this entry to turn it into an "other class" entry, we need
> > to ensure that members of the owner or group class will not lose any
> > permissions from that ace.
> > 
> > Conceptually, we do this by inserting additional <who>:<allow>::allow
> > entries before the trailing everyone@ allow ace with the same
> > permissions as the trailing everyone@ allow ace for owner@, group@, and
> > all explicitly mentioned users and groups.  (In practice, we will rarely
> > need to insert any additional aces in this step.)
> > 
> > Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> > ---
> >  fs/richacl_compat.c | 195 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 195 insertions(+)
> > 
> > diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> > index 4f0acf5..9b76fc0 100644
> > --- a/fs/richacl_compat.c
> > +++ b/fs/richacl_compat.c
> > @@ -218,3 +218,198 @@ richacl_move_everyone_aces_down(struct richacl_alloc *alloc)
> >  	}
> >  	return 0;
> >  }
> > +
> > +/**
> > + * __richacl_propagate_everyone  -  propagate everyone@ permissions up for @who
> > + * @alloc:	acl and number of allocated entries
> > + * @who:	identifier to propagate permissions for
> > + * @allow:	permissions to propagate up
> > + *
> > + * Propagate the permissions in @allow up from the end of the acl to the start
> > + * for the specified principal @who.
> > + *
> > + * The simplest possible approach to achieve this would be to insert a
> > + * "<who>:<allow>::allow" ace before the final everyone@ allow ace.  Since this
> > + * would often result in aces which are not needed or which could be merged
> > + * with an existing ace, we make the following optimizations:
> > + *
> > + *   - We go through the acl and determine which permissions are already
> > + *     allowed or denied to @who, and we remove those permissions from
> > + *     @allow.
> > + *
> > + *   - If the acl contains an allow ace for @who and no aces after this entry
> > + *     deny permissions in @allow, we add the permissions in @allow to this
> > + *     ace.  (Propagating permissions across a deny ace which can match the
> > + *     process can elevate permissions.)
> > + *
> > + * This transformation does not alter the permissions that the acl grants.
> > + */
> > +static int
> > +__richacl_propagate_everyone(struct richacl_alloc *alloc, struct richace *who,
> > +			     unsigned int allow)
> > +{
> > +	struct richace *allow_last = NULL, *ace;
> > +	struct richacl *acl = alloc->acl;
> > +
> > +	/*
> > +	 * Remove the permissions from allow that are already determined for
> > +	 * this who value, and figure out if there is an allow entry for
> > +	 * this who value that is "reachable" from the trailing everyone@
> > +	 * allow ace.
> > +	 */
> > +	richacl_for_each_entry(ace, acl) {
> > +		if (richace_is_inherit_only(ace))
> > +			continue;
> > +		if (richace_is_allow(ace)) {
> > +			if (richace_is_same_identifier(ace, who)) {
> > +				allow &= ~ace->e_mask;
> > +				allow_last = ace;
> > +			}
> > +		} else if (richace_is_deny(ace)) {
> > +			if (richace_is_same_identifier(ace, who))
> > +				allow &= ~ace->e_mask;
> > +			else if (allow & ace->e_mask)
> > +				allow_last = NULL;
> > +		}
> > +	}
> > +	ace--;
> > +
> > +	/*
> > +	 * If for group class entries, all the remaining permissions will
> > +	 * remain granted by the trailing everyone@ ace, no additional entry is
> > +	 * needed.
> > +	 */
> > +	if (!richace_is_owner(who) &&
> > +	    richace_is_everyone(ace) && richace_is_allow(ace) &&
> > +	    !(allow & ~(ace->e_mask & acl->a_other_mask)))
> > +		allow = 0;
> > +
> > +	if (allow) {
> > +		if (allow_last)
> > +			return richace_change_mask(alloc, &allow_last,
> > +						   allow_last->e_mask | allow);
> > +		else {
> > +			struct richace who_copy;
> > +
> > +			richace_copy(&who_copy, who);
> > +			ace = acl->a_entries + acl->a_count - 1;
> > +			if (richacl_insert_entry(alloc, &ace))
> > +				return -1;
> > +			richace_copy(ace, &who_copy);
> > +			ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
> > +			ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
> > +			ace->e_mask = allow;
> > +		}
> > +	}
> > +	return 0;
> > +}
> > +
> > +/**
> > + * richacl_propagate_everyone  -  propagate everyone@ permissions up the acl
> > + * @alloc:	acl and number of allocated entries
> > + *
> > + * Make sure that group@ and all other users and groups mentioned in the acl
> > + * will not lose any permissions when finally applying the other mask to the
> > + * everyone@ allow ace at the end of the acl.  We modify the permissions of
> > + * existing entries or add new entries before the final everyone@ allow ace to
> > + * achieve that.
> > + *
> > + * For example, the following acl implicitly grants everyone rwpx access:
> > + *
> > + *    joe:r::allow
> > + *    everyone@:rwpx::allow
> > + *
> > + * When applying mode 0660 to this acl, group@ would lose rwp access, and joe
> > + * would lose wp access even though the mode does not exclude those
> > + * permissions.  After propagating the everyone@ permissions, the result for
> > + * applying mode 0660 becomes:
> > + *
> > + *    owner@:rwp::allow
> > + *    joe:rwp::allow
> > + *    group@:rwp::allow
> > + *
> > + * Deny aces complicate the matter.  For example, the following acl grants
> > + * everyone but joe write access:
> > + *
> > + *    joe:wp::deny
> > + *    everyone@:rwpx::allow
> > + *
> > + * When applying mode 0660 to this acl, group@ would lose rwp access, and joe
> > + * would lose r access.  After propagating the everyone@ permissions, the
> > + * result for applying mode 0660 becomes:
> > + *
> > + *    owner@:rwp::allow
> > + *    joe:w::deny
> > + *    group@:rwp::allow
> > + *    joe:r::allow
> > + */
> > +static int
> > +richacl_propagate_everyone(struct richacl_alloc *alloc)
> > +{
> > +	struct richace who = { .e_flags = RICHACE_SPECIAL_WHO };
> > +	struct richacl *acl = alloc->acl;
> > +	struct richace *ace;
> > +	unsigned int owner_allow, group_allow;
> > +
> > +	/*
> > +	 * If the owner mask contains permissions which are not in the group
> > +	 * mask, the group mask contains permissions which are not in the other
> > +	 * mask, or the owner class contains permissions which are not in the
> 
> s/owner class/owner mask?
> 
> > +	 * other mask, we may need to propagate permissions up from the
> > +	 * everyone@ allow ace.  The third condition is implied by the first
> > +	 * two.
> > +	 */
> > +	if (!((acl->a_owner_mask & ~acl->a_group_mask) ||
> > +	      (acl->a_group_mask & ~acl->a_other_mask)))
> > +		return 0;
> 
> The code looks right, but I don't understand the preceding comment.
> 
> For example, 
> 
> 	owner mask: rw
> 	group mask:  wx
> 	other mask: rw
> 
> satisfies the first two conditions, but not the third.
> 
> Also, I don't understand why the first condition would imply that we
> might need to propagate permissions.

OK, maybe I get the part about the owner mask containing permissions
not in the group mask: we'll need to insert a deny ace for the bits in
the other mask but not in the group mask, and then we'll need an allow
ace for the owner to get those bits back.  I think?

> > +			if (richace_is_allow(ace) || richace_is_deny(ace)) {

The v4 spec allows aces other than allow and deny aces (audit and
alarm), but I didn't think you were implementing those.

--b.
