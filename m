Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44769 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755673Ab1JQV4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/8] nfsd4: simplify process_open1 logic
Date: Mon, 17 Oct 2011 17:55:52 -0400
Message-Id: <1318888557-14719-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

No change in behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d90461e..62aa91a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2506,7 +2506,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_openowner *oo = NULL;
-	__be32 status;
 
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
@@ -2515,30 +2514,25 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	oo = find_openstateowner_str(strhashval, open);
 	open->op_openowner = oo;
 	if (!oo) {
-		/* Make sure the client's lease hasn't expired. */
 		clp = find_confirmed_client(clientid);
 		if (clp == NULL)
 			return nfserr_expired;
-		goto renew;
+		goto new_owner;
 	}
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
 		/* Replace unconfirmed owners without checking for replay. */
 		clp = oo->oo_owner.so_client;
 		release_openowner(oo);
 		open->op_openowner = NULL;
-		goto renew;
-	}
-	status = nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
-	if (status)
-		return status;
-renew:
-	if (open->op_openowner == NULL) {
-		oo = alloc_init_open_stateowner(strhashval, clp, open);
-		if (oo == NULL)
-			return nfserr_jukebox;
-		open->op_openowner = oo;
+		goto new_owner;
 	}
 	list_del_init(&oo->oo_close_lru);
+	return nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
+new_owner:
+	oo = alloc_init_open_stateowner(strhashval, clp, open);
+	if (oo == NULL)
+		return nfserr_jukebox;
+	open->op_openowner = oo;
 	return nfs_ok;
 }
 
-- 
1.7.5.4

