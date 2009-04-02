From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 14/21] SQUASHME: nfsd41: allocate struct nfsd4_session and slot table in one piece
Date: Fri,  3 Apr 2009 01:38:34 +0300
Message-ID: <1238711914-22458-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28043 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764231AbZDBWik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:40 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

as per Bruce's review comment.

squash into "nfsd41: create_session operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   23 ++++++++++-------------
 include/linux/nfsd/state.h |    2 +-
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 610d918..53ed144 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -494,23 +494,23 @@ static int
 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 		   struct nfsd4_create_session *cses)
 {
-	struct nfsd4_session *new;
+	struct nfsd4_session *new, tmp;
 	int idx, status = nfserr_resource, slotsize, i;
 
-	new = kzalloc(sizeof(*new), GFP_KERNEL);
-	if (!new)
-		goto out;
+	memset(&tmp, 0, sizeof(tmp));
 
 	/* FIXME: For now, we just accept the client back channel attributes. */
-	status = init_forechannel_attrs(rqstp, new, &cses->fore_channel);
+	status = init_forechannel_attrs(rqstp, &tmp, &cses->fore_channel);
 	if (status)
-		goto out_free;
+		goto out;
 
-	slotsize = new->se_fnumslots * sizeof(struct nfsd4_slot);
-	new->se_slots = kzalloc(slotsize, GFP_KERNEL);
-	if (!new->se_slots)
-		goto out_free;
+	/* allocate struct nfsd4_session and slot table in one piece */
+	slotsize = tmp.se_fnumslots * sizeof(struct nfsd4_slot);
+	new = kzalloc(sizeof(*new) + slotsize, GFP_KERNEL);
+	if (!new)
+		goto out;
 
+	memcpy(new, &tmp, sizeof(*new));
 	for (i = 0; i < new->se_fnumslots; i++)
 		new->se_slots[i].sl_session = new;
 
@@ -532,9 +532,6 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 	status = nfs_ok;
 out:
 	return status;
-out_free:
-	kfree(new);
-	goto out;
 }
 
 /* caller must hold sessionid_lock */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 365cc4b..ddf9ac6 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -141,7 +141,7 @@ struct nfsd4_session {
 	u32			se_fmaxresp_cached;
 	u32			se_fmaxops;
 	u32			se_fnumslots;
-	struct nfsd4_slot	*se_slots;	/* forward channel slots */
+	struct nfsd4_slot	se_slots[];	/* forward channel slots */
 };
 
 static inline void
-- 
1.6.2.1

