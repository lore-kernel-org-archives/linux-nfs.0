Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbaEOT0Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 May 2014 15:26:24 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1Wl1IN-00049k-Pw
	for linux-nfs@vger.kernel.org; Thu, 15 May 2014 15:26:23 -0400
Date: Thu, 15 May 2014 15:26:23 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix corruption on setting an ACL.
Message-ID: <20140515192623.GA15684@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As of 06f9cc12caa862f5bc86ebdb4f77568a4bef0167 "nfsd4: don't create
unnecessary mask acl", any non-trivial ACL will be left with an
unitialized entry, and a trivial ACL may write one entry beyond what's
allocated.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4acl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I'll submit this for 3.15.

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index c06cad5e..f69f56b 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -590,7 +590,7 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 		add_to_mask(state, &state->groups->aces[i].perms);
 	}
 
-	if (!state->users->n && !state->groups->n) {
+	if (state->users->n || state->groups->n) {
 		pace++;
 		pace->e_tag = ACL_MASK;
 		low_mode_from_nfs4(state->mask.allow, &pace->e_perm, flags);
-- 
1.9.0

