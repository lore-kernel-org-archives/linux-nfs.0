Return-Path: linux-nfs-owner@vger.kernel.org
Received: from i118-21-156-233.s30.a048.ap.plala.or.jp ([118.21.156.233]:45618
	"EHLO rinabert.homeip.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751706Ab1LSOxr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2011 09:53:47 -0500
From: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, jkosina@suse.cz, Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [Trivial]: nfs : Fix typo in dir.c
Date: Mon, 19 Dec 2011 23:17:03 +0900
Message-Id: <1324304223-10047-1-git-send-email-standby24x7@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix typo "iff" -> "if" in dir.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
To: Jiri Kosina <jkosina@suse.cz>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
---
 fs/nfs/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ac28990..ad32d4e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1127,7 +1127,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 	if (nfs_have_delegation(inode, FMODE_READ))
 		goto out_set_verifier;
 
-	/* Force a full look up iff the parent directory has changed */
+	/* Force a full look up if the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, nd) && nfs_check_verifier(dir, dentry)) {
 		if (nfs_lookup_verify_inode(inode, nd))
 			goto out_zap_parent;
-- 
1.7.6.4

