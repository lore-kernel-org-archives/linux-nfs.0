From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/6] nfsd4: remove some debugging code
Date: Thu, 24 Jun 2010 12:29:08 -0400
Message-ID: <1277396950-18298-5-git-send-email-bfields@citi.umich.edu>
References: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-3-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-4-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051Ab0FXQ3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:29:10 -0400
In-Reply-To: <1277396950-18298-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is overkill.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 603076f..182448f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -591,10 +591,8 @@ find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid)
 
 	dump_sessionid(__func__, sessionid);
 	idx = hash_sessionid(sessionid);
-	dprintk("%s: idx is %d\n", __func__, idx);
 	/* Search in the appropriate list */
 	list_for_each_entry(elem, &sessionid_hashtbl[idx], se_hash) {
-		dump_sessionid("list traversal", &elem->se_sessionid);
 		if (!memcmp(elem->se_sessionid.data, sessionid->data,
 			    NFS4_MAX_SESSIONID_LEN)) {
 			return elem;
-- 
1.7.0.4

