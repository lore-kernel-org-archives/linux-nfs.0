Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756438AbbIYQf6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 12:35:58 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [PATCH] richacl: Possible other write-through fix
Date: Fri, 25 Sep 2015 18:21:13 +0200
Message-Id: <1443198073-2344-1-git-send-email-agruenba@redhat.com>
In-Reply-To: <20150924183310.GE3823@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-24 20:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:21PM +0200, Andreas Gruenbacher wrote:
>> +int
>> +richacl_apply_masks(struct richacl **acl, kuid_t owner)
>> +{
>> +     if ((*acl)->a_flags & RICHACL_MASKED) {
>> +             struct richacl_alloc alloc = {
>> +                     .acl = richacl_clone(*acl, GFP_KERNEL),
>> +                     .count = (*acl)->a_count,
>> +             };
>> +             if (!alloc.acl)
>> +                     return -ENOMEM;
>> +
>> +             if (richacl_move_everyone_aces_down(&alloc) ||
>> +                 richacl_propagate_everyone(&alloc) ||
>> +                 __richacl_apply_masks(&alloc, owner) ||
>> +                 richacl_set_owner_permissions(&alloc) ||
>> +                 richacl_set_other_permissions(&alloc) ||
>
> Hm, I'm a little unsure about this step: it seems like the one step that
> can actually change the permissions (making them more permissive, in
> this case), whereas the others are neutral.
>
> The following two steps should fix that, but I'm not sure they do.
>
> E.g. if I have an ACL like
>
>         mask 0777, WRITE_THROUGH
>         GROUP@:r--::allow
>
> I think it should result in
>
>         OWNER@:   rwx::allow
>         GROUP@:   -wx::deny
>         GROUP@:   r--::allow
>         EVERYONE@:rwx::allow
>
> But does the GROUP@ deny actually get in there?  It looks to me like the
> denies inserted by richacl_isolate_group_class only take into account
> the group mask, not the actual permissions granted to any group class
> user.
>
> I may be mising something.

Thanks for the test case and analysis. The group@ deny ace that should be
inserted here actually doesn't get inserted. I'm attaching a fix.

---

By the way, all those scenarios can easily be tries out using the test
suite in the user-space richacl package, even without a richacl enabled
kernel. In this case, without the fix, we get:

  $ make tests/richacl-apply-masks
  $ tests/richacl-apply-masks -m 777 group@:r::allow
  group@:r::allow
  everyone@:rwpx::allow

With the fix, we are now getting:

  $ tests/richacl-apply-masks -m 777 group@:r::allow
  owner@:rwpx::allow
  group@:r::allow
  group@:wpx::deny
  everyone@:rwpx::allow

Thanks,
Andreas

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 726d796..bc0bcfe 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -463,23 +463,28 @@ richacl_set_owner_permissions(struct richacl_alloc *alloc)
 
 /**
  * richacl_set_other_permissions  -  set the other permissions to the other mask
+ * @alloc:	acl and number of allocated entries
+ * @added:	permissions added for everyone@
  *
  * Change the acl so that everyone@ is granted the permissions set in the other
  * mask.  This leaves at most one efective everyone@ allow entry at the end of
- * the acl.
+ * the acl.  If everyone@ end up being granted additional permissions, these
+ * permissions are returned in @added.
  */
 static int
-richacl_set_other_permissions(struct richacl_alloc *alloc)
+richacl_set_other_permissions(struct richacl_alloc *alloc, unsigned int *added)
 {
 	struct richacl *acl = alloc->acl;
 	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
 	unsigned int other_mask = acl->a_other_mask & ~x;
-	struct richace *ace = acl->a_entries + acl->a_count - 1;
+	struct richace *ace;
 
 	if (!(other_mask &&
 	      (acl->a_flags & RICHACL_WRITE_THROUGH)))
 		return 0;
 
+	*added = other_mask;
+	ace = acl->a_entries + acl->a_count - 1;
 	if (acl->a_count == 0 ||
 	    !richace_is_everyone(ace) ||
 	    richace_is_inherit_only(ace)) {
@@ -490,8 +495,10 @@ richacl_set_other_permissions(struct richacl_alloc *alloc)
 		ace->e_flags = RICHACE_SPECIAL_WHO;
 		ace->e_mask = other_mask;
 		ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
-	} else
+	} else {
+		*added &= ~ace->e_mask;
 		richace_change_mask(alloc, &ace, other_mask);
+	}
 	return 0;
 }
 
@@ -645,6 +652,7 @@ __richacl_isolate_who(struct richacl_alloc *alloc, struct richace *who,
 /**
  * richacl_isolate_group_class  -  limit the group class to the group file mask
  * @alloc:	acl and number of allocated entries
+ * @deny:	additional permissions to deny
  *
  * POSIX requires that after a chmod, the group class is granted no more
  * permissions than the group file permission bits.  For richacls, this
@@ -679,21 +687,20 @@ __richacl_isolate_who(struct richacl_alloc *alloc, struct richace *who,
  *    everyone@:rw::allow
  */
 static int
-richacl_isolate_group_class(struct richacl_alloc *alloc)
+richacl_isolate_group_class(struct richacl_alloc *alloc, unsigned int deny)
 {
 	struct richace who = {
 		.e_flags = RICHACE_SPECIAL_WHO,
 		.e_id.special = RICHACE_GROUP_SPECIAL_ID,
 	};
 	struct richace *ace;
-	unsigned int deny;
 
 	if (!alloc->acl->a_count)
 		return 0;
 	ace = alloc->acl->a_entries + alloc->acl->a_count - 1;
 	if (richace_is_inherit_only(ace) || !richace_is_everyone(ace))
 		return 0;
-	deny = ace->e_mask & ~alloc->acl->a_group_mask;
+	deny |= ace->e_mask & ~alloc->acl->a_group_mask;
 
 	if (deny) {
 		unsigned int n;
@@ -806,16 +813,17 @@ richacl_apply_masks(struct richacl **acl, kuid_t owner)
 			.acl = richacl_clone(*acl, GFP_KERNEL),
 			.count = (*acl)->a_count,
 		};
+		unsigned int added = 0;
+
 		if (!alloc.acl)
 			return -ENOMEM;
-
 		if (richacl_move_everyone_aces_down(&alloc) ||
 		    richacl_propagate_everyone(&alloc) ||
 		    __richacl_apply_masks(&alloc, owner) ||
+		    richacl_set_other_permissions(&alloc, &added) ||
+		    richacl_isolate_group_class(&alloc, added) ||
 		    richacl_set_owner_permissions(&alloc) ||
-		    richacl_set_other_permissions(&alloc) ||
-		    richacl_isolate_owner_class(&alloc) ||
-		    richacl_isolate_group_class(&alloc)) {
+		    richacl_isolate_owner_class(&alloc)) {
 			richacl_put(alloc.acl);
 			return -ENOMEM;
 		}
-- 
2.4.3

