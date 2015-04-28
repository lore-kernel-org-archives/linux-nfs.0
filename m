Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44526 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965547AbbD1MCA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 08:02:00 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd: don't allocate odstates unless pNFS is enabled
Date: Tue, 28 Apr 2015 14:00:49 +0200
Message-Id: <1430222449-3921-3-git-send-email-hch@lst.de>
In-Reply-To: <1430222449-3921-1-git-send-email-hch@lst.de>
References: <1430222449-3921-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f417362..9072964 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -475,8 +475,10 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 
 /*
  * Allocate a new open/delegation state counter. This is needed for
- * pNFS for proper return on close semantics. For v4.0 however, it's
- * not needed.
+ * pNFS for proper return on close semantics.
+ *
+ * Note that we only allocate it for pNFS-enabled exports, otherwise
+ * all pointers to struct nfs4_clnt_odstate are always NULL.
  */
 static struct nfs4_clnt_odstate *
 alloc_clnt_odstate(struct nfs4_client *clp)
@@ -503,7 +505,6 @@ hash_clnt_odstate_locked(struct nfs4_clnt_odstate *co)
 static inline void
 get_clnt_odstate(struct nfs4_clnt_odstate *co)
 {
-	/* This is always NULL in v4.0 */
 	if (co)
 		atomic_inc(&co->co_odcount);
 }
@@ -513,7 +514,6 @@ put_clnt_odstate(struct nfs4_clnt_odstate *co)
 {
 	struct nfs4_file *fp;
 
-	/* This is always NULL in v4.0 */
 	if (!co)
 		return;
 
@@ -533,7 +533,6 @@ find_or_hash_clnt_odstate(struct nfs4_file *fp, struct nfs4_clnt_odstate *new)
 	struct nfs4_clnt_odstate *co;
 	struct nfs4_client *cl;
 
-	/* This is always NULL in v4.0 */
 	if (!new)
 		return NULL;
 
@@ -3680,7 +3679,8 @@ alloc_stateid:
 	if (!open->op_stp)
 		return nfserr_jukebox;
 
-	if (nfsd4_has_session(cstate)) {
+	if (nfsd4_has_session(cstate) &&
+	    (cstate->current_fh.fh_export->ex_flags & NFSEXP_PNFS)) {
 		open->op_odstate = alloc_clnt_odstate(clp);
 		if (!open->op_odstate)
 			return nfserr_jukebox;
-- 
1.9.1

