Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:48618 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318Ab2EKNpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 09:45:40 -0400
Received: by qcro28 with SMTP id o28so1953866qcr.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2012 06:45:39 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] nfsd: consolidate set_access and set_deny
Date: Fri, 11 May 2012 09:45:11 -0400
Message-Id: <1336743914-944-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336743914-944-1-git-send-email-jlayton@redhat.com>
References: <1336743914-944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These functions are identical. Also, rename them to bmap_to_share_mode
to better reflect what they do, and have them just return the result
instead of passing in a pointer to the storage location.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   24 +++++++-----------------
 1 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7f71c69..64aeaa0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -447,34 +447,24 @@ static struct list_head close_lru;
  *
  * which we should reject.
  */
-static void
-set_access(unsigned int *access, unsigned long bmap) {
+static unsigned int
+bmap_to_share_mode(unsigned long bmap) {
 	int i;
+	unsigned int access = 0;
 
-	*access = 0;
 	for (i = 1; i < 4; i++) {
 		if (test_bit(i, &bmap))
-			*access |= i;
-	}
-}
-
-static void
-set_deny(unsigned int *deny, unsigned long bmap) {
-	int i;
-
-	*deny = 0;
-	for (i = 0; i < 4; i++) {
-		if (test_bit(i, &bmap))
-			*deny |= i ;
+			access |= i;
 	}
+	return access;
 }
 
 static int
 test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
 	unsigned int access, deny;
 
-	set_access(&access, stp->st_access_bmap);
-	set_deny(&deny, stp->st_deny_bmap);
+	access = bmap_to_share_mode(stp->st_access_bmap);
+	deny = bmap_to_share_mode(stp->st_deny_bmap);
 	if ((access & open->op_share_deny) || (deny & open->op_share_access))
 		return 0;
 	return 1;
-- 
1.7.7.6

