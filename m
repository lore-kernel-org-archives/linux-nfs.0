Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58762 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbaBXWIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Feb 2014 17:08:51 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 4/5] nfsd4: session needs room for following op to error out
Date: Mon, 24 Feb 2014 17:08:46 -0500
Message-Id: <1393279727-29437-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1393279727-29437-1-git-send-email-bfields@redhat.com>
References: <1393279727-29437-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 82189b2..b9048e5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1359,6 +1359,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		/* If op is non-idempotent */
 		if (opdesc->op_flags & OP_MODIFIES_SOMETHING) {
 			plen = opdesc->op_rsize_bop(rqstp, op);
+			/*
+			 * If there's still another operation, make sure
+			 * we'll have space to at least encode an error:
+			 */
+			if (resp->opcnt < args->opcnt)
+				plen += COMPOUND_ERR_SLACK_SPACE;
 			op->status = nfsd4_check_resp_size(resp, plen);
 		}
 
-- 
1.7.9.5

