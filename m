Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41559 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864Ab3CEWRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 17:17:23 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UD0Ak-0004rZ-UH
	for linux-nfs@vger.kernel.org; Tue, 05 Mar 2013 17:17:23 -0500
Date: Tue, 5 Mar 2013 17:17:22 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd4: remove BUG_ON
Message-ID: <20130305221722.GE15816@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This BUG_ON just crashes the thread a little earlier than it would
otherwise--it doesn't seem useful.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ae73175..c7e4e8c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1282,12 +1282,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		if (op->status)
 			goto encode_op;
 
-		if (opdesc->op_func) {
-			if (opdesc->op_get_currentstateid)
-				opdesc->op_get_currentstateid(cstate, &op->u);
-			op->status = opdesc->op_func(rqstp, cstate, &op->u);
-		} else
-			BUG_ON(op->status == nfs_ok);
+		if (opdesc->op_get_currentstateid)
+			opdesc->op_get_currentstateid(cstate, &op->u);
+		op->status = opdesc->op_func(rqstp, cstate, &op->u);
 
 		if (!op->status) {
 			if (opdesc->op_set_currentstateid)
-- 
1.7.9.5

