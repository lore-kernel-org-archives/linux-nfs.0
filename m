Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57451 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754904Ab1DJQ3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:29:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: introduce OPDESC helper
Date: Sun, 10 Apr 2011 12:29:31 -0400
Message-Id: <1302452973-27272-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20110410162536.GC26233@fieldses.org>
References: <20110410162536.GC26233@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5fcb139..126b8f7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1031,6 +1031,11 @@ static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 	return nfs_ok;
 }
 
+static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
+{
+	return &nfsd4_ops[op->opnum];
+}
+
 /*
  * COMPOUND call.
  */
@@ -1108,7 +1113,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			goto encode_op;
 		}
 
-		opdesc = &nfsd4_ops[op->opnum];
+		opdesc = OPDESC(op);
 
 		if (!cstate->current_fh.fh_dentry) {
 			if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
-- 
1.7.1

