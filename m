From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/6] nfsd4: fix deleg leak on callback error
Date: Thu, 24 Jun 2010 12:29:09 -0400
Message-ID: <1277396950-18298-6-git-send-email-bfields@citi.umich.edu>
References: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-3-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-4-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-5-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52620 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756052Ab0FXQ3L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:29:11 -0400
In-Reply-To: <1277396950-18298-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 874a56a..a468632 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -761,8 +761,10 @@ static void _nfsd4_cb_recall(struct nfs4_delegation *dp)
 		.rpc_cred = callback_cred
 	};
 
-	if (clnt == NULL)
+	if (clnt == NULL) {
+		nfs4_put_delegation(dp);
 		return; /* Client is shutting down; give up. */
+	}
 
 	args->args_op = dp;
 	msg.rpc_argp = args;
-- 
1.7.0.4

