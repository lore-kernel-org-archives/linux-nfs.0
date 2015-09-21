Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60729 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147AbbIURsr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 13:48:47 -0400
Date: Mon, 21 Sep 2015 13:48:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org
Subject: Re: [RFC v7 13/41] richacl: Check if an acl is equivalent to a file
 mode
Message-ID: <20150921174846.GA11747@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-14-git-send-email-agruenba@redhat.com>
 <20150917182219.GB13825@fieldses.org>
 <20150918005607.GB16699@fieldses.org>
 <56000D2B.6000705@gmail.com>
 <20150921143817.GA11256@fieldses.org>
 <560037B8.1070803@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <560037B8.1070803@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 21, 2015 at 01:00:40PM -0400, Austin S Hemmelgarn wrote:
> On 2015-09-21 10:38, J. Bruce Fields wrote:
> >On Mon, Sep 21, 2015 at 09:59:07AM -0400, Austin S Hemmelgarn wrote:
> >>On 2015-09-17 20:56, J. Bruce Fields wrote:
> >>>On Thu, Sep 17, 2015 at 02:22:19PM -0400, bfields wrote:
> >>>>On Sat, Sep 05, 2015 at 12:27:08PM +0200, Andreas Gruenbacher wrote:
> >>>>>ACLs are considered equivalent to file modes if they only consist of
> >>>>>owner@, group@, and everyone@ entries, the owner@ permissions do not
> >>>>>depend on whether the owner is a member in the owning group, and no
> >>>>>inheritance flags are set.  This test is used to avoid storing richacls
> >>>>>if the acl can be computed from the file permission bits.
> >>>>
> >>>>We're assuming here that it's OK for us to silently rearrange an ACL as
> >>>>long as the result is still equivalent (in the sense that the permission
> >>>>algorithm would always produce the same result).
> >>>>
> >>>>I guess that's OK by me, but it might violate user expectations in some
> >>>>simple common cases, so may be worth mentioning in documentation
> >>>>someplace if we don't already.
> >>>
> >>>Also your notion of mode-equivalence here is interesting, it's actually
> >>>a strict subset of the ACLs that produce the same permission results as
> >>>a mode.  (For example, everyone:rwx,bfields:rwx is equivalent to 0777
> >>>but won't be considered mode-equivalent by this algorithm.)
> >>Although it could also be equivalent to 0707, or (if bfields is the
> >>group name also) 0077, or even (if bfields isn't the group or owner
> >>of the file) 0007.
> >
> >I disagree.  I think you've misread my example ACL (may be my sloppy
> >notation, sorry) or misunderstood the ACL evalutation algorithm.
> I'm just saying in general that there isn't enough information
> without knowing not only the ACL, but also the ownership
> information, to determine exact mode-equivalence.

Note the first ACE in that ACL gives everyone all permissions, the
second ACE is never even consulted.  There's no doubt that 0777 is the
only mode we could consider that equivalent to.

--b.

> I didn't phrase it well to convey this though.
> 
> I can kind of understand the more I think about it why an ACL only
> covering the owner and everyone permissions would not be considered
> equivalent to 0777 (strictly speaking it's 0707, even though (I
> think) this behaves like 0777).
> >
> >>Mode equivalence get's even trickier when you
> >>throw in permissions just beyond rwx (for example, by Windows
> >>standards, the usage of the execute bit on directories is weird
> >>(they have a separate permission in their ACE's for directory
> >>listing), or by VMS standards, write permission on a directory
> >>doesn't mean that you can delete things in it (VMS actually had a
> >>separate bit for the delete permission, and even had separate
> >>permissions for system access)).
> >
> >I believe these patches handle all of those details correctly; if you
> >see anything to the contrary, please do speak up.
> I see absolutely nothing wrong with them, I was just trying to point
> out that when you consider all the permissions allowed under the
> proposed system, mode-equivalence get's really tricky.
> >Note that Windows also has a DELETE bit, though it is ORed with the
> >directory permission not ANDed (so it is sufficient for the directory to
> >allow MAY_DELETE_CHILD *or* for the file to allow DELETE).
> Yeah, which has ironically caused issues for a number of people I
> know before.  There's all kinds of weird things you can do with
> Windows ACE's, for example, I'm pretty sure it's possible to let
> someone read just the file contents, but nothing else about it, or
> make it so that someone can modify the timestamps on it but not do
> anything else to it.
> >
> >(But I believe you're correct that VMS required both permissions, if
> >e.g. http://www.djesys.com/vms/freevms/mentor/vms_prot.html is correct).
> >
> >--b.
> >
> >>>
> >>>I think the choices you've made probably make the most sense, they just
> >>>wouldn't have been obvious to me.  Anyway, so, OK by me:
> >>>
> >>>	Reviewed-by: J. Bruce Fields <bfields@redhat.com>
> >>>
> >>>--b.
> >>>
> >>>>
> >>>>--b.
> >>>>
> >>>>>
> >>>>>Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> >>>>>---
> >>>>>  fs/richacl_base.c       | 104 ++++++++++++++++++++++++++++++++++++++++++++++++
> >>>>>  include/linux/richacl.h |   1 +
> >>>>>  2 files changed, 105 insertions(+)
> >>>>>
> >>>>>diff --git a/fs/richacl_base.c b/fs/richacl_base.c
> >>>>>index 3163152..106e988 100644
> >>>>>--- a/fs/richacl_base.c
> >>>>>+++ b/fs/richacl_base.c
> >>>>>@@ -379,3 +379,107 @@ richacl_chmod(struct richacl *acl, mode_t mode)
> >>>>>  	return clone;
> >>>>>  }
> >>>>>  EXPORT_SYMBOL_GPL(richacl_chmod);
> >>>>>+
> >>>>>+/**
> >>>>>+ * richacl_equiv_mode  -  compute the mode equivalent of @acl
> >>>>>+ *
> >>>>>+ * An acl is considered equivalent to a file mode if it only consists of
> >>>>>+ * owner@, group@, and everyone@ entries and the owner@ permissions do not
> >>>>>+ * depend on whether the owner is a member in the owning group.
> >>>>>+ */
> >>>>>+int
> >>>>>+richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
> >>>>>+{
> >>>>>+	mode_t mode = *mode_p;
> >>>>>+
> >>>>>+	/*
> >>>>>+	 * The RICHACE_DELETE_CHILD flag is meaningless for non-directories, so
> >>>>>+	 * we ignore it.
> >>>>>+	 */
> >>>>>+	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
> >>>>>+	struct {
> >>>>>+		unsigned int allowed;
> >>>>>+		unsigned int defined;  /* allowed or denied */
> >>>>>+	} owner = {
> >>>>>+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED |
> >>>>>+			   RICHACE_POSIX_OWNER_ALLOWED  | x,
> >>>>>+	}, group = {
> >>>>>+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
> >>>>>+	}, everyone = {
> >>>>>+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
> >>>>>+	};
> >>>>>+	const struct richace *ace;
> >>>>>+
> >>>>>+	if (acl->a_flags & ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED))
> >>>>>+		return -1;
> >>>>>+
> >>>>>+	richacl_for_each_entry(ace, acl) {
> >>>>>+		if (ace->e_flags & ~RICHACE_SPECIAL_WHO)
> >>>>>+			return -1;
> >>>>>+
> >>>>>+		if (richace_is_owner(ace) || richace_is_everyone(ace)) {
> >>>>>+			x = ace->e_mask & ~owner.defined;
> >>>>>+			if (richace_is_allow(ace)) {
> >>>>>+				unsigned int group_denied =
> >>>>>+					group.defined & ~group.allowed;
> >>>>>+
> >>>>>+				if (x & group_denied)
> >>>>>+					return -1;
> >>>>>+				owner.allowed |= x;
> >>>>>+			} else /* if (richace_is_deny(ace)) */ {
> >>>>>+				if (x & group.allowed)
> >>>>>+					return -1;
> >>>>>+			}
> >>>>>+			owner.defined |= x;
> >>>>>+
> >>>>>+			if (richace_is_everyone(ace)) {
> >>>>>+				x = ace->e_mask;
> >>>>>+				if (richace_is_allow(ace)) {
> >>>>>+					group.allowed |=
> >>>>>+						x & ~group.defined;
> >>>>>+					everyone.allowed |=
> >>>>>+						x & ~everyone.defined;
> >>>>>+				}
> >>>>>+				group.defined |= x;
> >>>>>+				everyone.defined |= x;
> >>>>>+			}
> >>>>>+		} else if (richace_is_group(ace)) {
> >>>>>+			x = ace->e_mask & ~group.defined;
> >>>>>+			if (richace_is_allow(ace))
> >>>>>+				group.allowed |= x;
> >>>>>+			group.defined |= x;
> >>>>>+		} else
> >>>>>+			return -1;
> >>>>>+	}
> >>>>>+
> >>>>>+	if (group.allowed & ~owner.defined)
> >>>>>+		return -1;
> >>>>>+
> >>>>>+	if (acl->a_flags & RICHACL_MASKED) {
> >>>>>+		if (acl->a_flags & RICHACL_WRITE_THROUGH) {
> >>>>>+			owner.allowed = acl->a_owner_mask;
> >>>>>+			everyone.allowed = acl->a_other_mask;
> >>>>>+		} else {
> >>>>>+			owner.allowed &= acl->a_owner_mask;
> >>>>>+			everyone.allowed &= acl->a_other_mask;
> >>>>>+		}
> >>>>>+		group.allowed &= acl->a_group_mask;
> >>>>>+	}
> >>>>>+
> >>>>>+	mode = (mode & ~S_IRWXUGO) |
> >>>>>+	       (richacl_mask_to_mode(owner.allowed) << 6) |
> >>>>>+	       (richacl_mask_to_mode(group.allowed) << 3) |
> >>>>>+		richacl_mask_to_mode(everyone.allowed);
> >>>>>+
> >>>>>+	/* Mask flags we can ignore */
> >>>>>+	x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
> >>>>>+
> >>>>>+	if (((richacl_mode_to_mask(mode >> 6) ^ owner.allowed)    & ~x) ||
> >>>>>+	    ((richacl_mode_to_mask(mode >> 3) ^ group.allowed)    & ~x) ||
> >>>>>+	    ((richacl_mode_to_mask(mode)      ^ everyone.allowed) & ~x))
> >>>>>+		return -1;
> >>>>>+
> >>>>>+	*mode_p = mode;
> >>>>>+	return 0;
> >>>>>+}
> >>>>>+EXPORT_SYMBOL_GPL(richacl_equiv_mode);
> >>>>>diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> >>>>>index d4a576c..6535ce5 100644
> >>>>>--- a/include/linux/richacl.h
> >>>>>+++ b/include/linux/richacl.h
> >>>>>@@ -304,6 +304,7 @@ extern unsigned int richacl_mode_to_mask(mode_t);
> >>>>>  extern unsigned int richacl_want_to_mask(unsigned int);
> >>>>>  extern void richacl_compute_max_masks(struct richacl *);
> >>>>>  extern struct richacl *richacl_chmod(struct richacl *, mode_t);
> >>>>>+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
> >>>>>
> >>>>>  /* richacl_inode.c */
> >>>>>  extern int richacl_permission(struct inode *, const struct richacl *, int);
> >>>>>--
> >>>>>2.4.3
> >>>>>
> >>>>>--
> >>>>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>>>the body of a message to majordomo@vger.kernel.org
> >>>>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>--
> >>>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >>>the body of a message to majordomo@vger.kernel.org
> >>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>Please read the FAQ at  http://www.tux.org/lkml/
> >>>
> >>
> >>
> >
> >
> 
> 


