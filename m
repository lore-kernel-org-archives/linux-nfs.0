Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35303 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbHMPpx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Aug 2015 11:45:53 -0400
Received: by igbjg10 with SMTP id jg10so66103451igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2015 08:45:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pNFS: Fix borken function _same_data_server_addrs_locked()
Date: Thu, 13 Aug 2015 11:45:49 -0400
Message-Id: <1439480749-54600-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Switch back to using list_for_each_entry(). To fix an incorrect test
  for list NULL termination.
- Do not assume that lists are sorted.
- Finally, consider an existing entry to match if it consists of a subset
  of the addresses in the new entry.

Cc: stable@vger.kernel.org # 4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index cd3c0403101b..bbd407b6bc1f 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -373,26 +373,31 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 	return false;
 }
 
+/*
+ * Checks if 'dsaddrs1' contains a subset of 'dsaddrs2'. If it does,
+ * declare a match.
+ */
 static bool
 _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 			       const struct list_head *dsaddrs2)
 {
 	struct nfs4_pnfs_ds_addr *da1, *da2;
-
-	/* step through both lists, comparing as we go */
-	for (da1 = list_first_entry(dsaddrs1, typeof(*da1), da_node),
-	     da2 = list_first_entry(dsaddrs2, typeof(*da2), da_node);
-	     da1 != NULL && da2 != NULL;
-	     da1 = list_entry(da1->da_node.next, typeof(*da1), da_node),
-	     da2 = list_entry(da2->da_node.next, typeof(*da2), da_node)) {
-		if (!same_sockaddr((struct sockaddr *)&da1->da_addr,
-				   (struct sockaddr *)&da2->da_addr))
-			return false;
+	struct sockaddr *sa1, *sa2;
+	bool match = false;
+
+	list_for_each_entry(da1, dsaddrs1, da_node) {
+		sa1 = (struct sockaddr *)&da1->da_addr;
+		match = false;
+		list_for_each_entry(da2, dsaddrs2, da_node) {
+			sa2 = (struct sockaddr *)&da2->da_addr;
+			match = same_sockaddr(sa1, sa2);
+			if (match)
+				break;
+		}
+		if (!match)
+			break;
 	}
-	if (da1 == NULL && da2 == NULL)
-		return true;
-
-	return false;
+	return match;
 }
 
 /*
-- 
2.4.3

