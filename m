Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55534 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754833AbeFNTcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:32:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd: clarify check_op_ordering
Date: Thu, 14 Jun 2018 15:32:12 -0400
Message-Id: <1529004733-6022-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1529004733-6022-1-git-send-email-bfields@redhat.com>
References: <1529004733-6022-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Document a couple things that confused me on a recent reading.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1929f85b8269..140b05c8a4be 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1603,7 +1603,7 @@ static const char *nfsd4_op_name(unsigned opnum);
  */
 static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 {
-	struct nfsd4_op *op = &args->ops[0];
+	struct nfsd4_op *first_op = &args->ops[0];
 
 	/* These ordering requirements don't apply to NFSv4.0: */
 	if (args->minorversion == 0)
@@ -1611,12 +1611,17 @@ static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 	/* This is weird, but OK, not our problem: */
 	if (args->opcnt == 0)
 		return nfs_ok;
-	if (op->status == nfserr_op_illegal)
+	if (first_op->status == nfserr_op_illegal)
 		return nfs_ok;
-	if (!(nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP))
+	if (!(nfsd4_ops[first_op->opnum].op_flags & ALLOWED_AS_FIRST_OP))
 		return nfserr_op_not_in_session;
-	if (op->opnum == OP_SEQUENCE)
+	if (first_op->opnum == OP_SEQUENCE)
 		return nfs_ok;
+	/*
+	 * So first_op is something allowed outside a session, like
+	 * EXCHANGE_ID; but then it has to be the only op in the
+	 * compound:
+	 */
 	if (args->opcnt != 1)
 		return nfserr_not_only_op;
 	return nfs_ok;
-- 
2.17.1

