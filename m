Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37086 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbaDDVfy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 17:35:54 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1WWBmE-0003LA-0J
	for linux-nfs@vger.kernel.org; Fri, 04 Apr 2014 17:35:54 -0400
Date: Fri, 4 Apr 2014 17:35:53 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: don't create unnecessary mask acl
Message-ID: <20140404213553.GG17594@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Any setattr of the ACL attribute, even if it sets just the basic 3-ACE
ACL exactly as it was returned from a file with only mode bits, creates
a mask entry, and it is only the mask, not group, entry that is changed
by subsequent modifications of the mode bits.

So, for example, it's surprising that GROUP@ is left without read or
write permissions after a chmod 0666:

  touch test
  chmod 0600 test
  nfs4_getfacl test
        A::OWNER@:rwatTcCy
        A::GROUP@:tcy
        A::EVERYONE@:tcy
  nfs4_getfacl test | nfs4_setfacl -S - test #
  chmod 0666 test
  nfs4_getfacl test
        A::OWNER@:rwatTcCy
        A::GROUP@:tcy
        D::GROUP@:rwa
        A::EVERYONE@:rwatcy

So, let's stop creating the unnecessary mask ACL.

A mask will still be created on non-trivial ACLs (ACLs with actual named
user and group ACEs), so the odd posix-acl behavior of chmod modifying
only the mask will still be left in that case; but that's consistent
with local behavior.

Reported-by: Soumya Koduri <skoduri@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4acl.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index d190e33..6f3f392 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -542,7 +542,10 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 	 * up setting a 3-element effective posix ACL with all
 	 * permissions zero.
 	 */
-	nace = 4 + state->users->n + state->groups->n;
+	if (!state->users->n && !state->groups->n)
+		nace = 3;
+	else /* Note we also include a MASK ACE in this case: */
+		nace = 4 + state->users->n + state->groups->n;
 	pacl = posix_acl_alloc(nace, GFP_KERNEL);
 	if (!pacl)
 		return ERR_PTR(-ENOMEM);
@@ -586,9 +589,11 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 		add_to_mask(state, &state->groups->aces[i].perms);
 	}
 
-	pace++;
-	pace->e_tag = ACL_MASK;
-	low_mode_from_nfs4(state->mask.allow, &pace->e_perm, flags);
+	if (!state->users->n && !state->groups->n) {
+		pace++;
+		pace->e_tag = ACL_MASK;
+		low_mode_from_nfs4(state->mask.allow, &pace->e_perm, flags);
+	}
 
 	pace++;
 	pace->e_tag = ACL_OTHER;
-- 
1.7.9.5

