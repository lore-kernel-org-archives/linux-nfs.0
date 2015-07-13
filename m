Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34582 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbbGMJ3H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:29:07 -0400
Received: by pacan13 with SMTP id an13so13021366pac.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:29:07 -0700 (PDT)
Message-ID: <55A384DD.1000800@gmail.com>
Date: Mon, 13 Jul 2015 17:29:01 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 01/14] nfsd: Add layouts checking for state resources
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Layout is a state resource, nfsd should check it too.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61dfb33..e0a4556 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2241,6 +2241,7 @@ static bool client_has_state(struct nfs4_client *clp)
 	 * Also note we should probably be using this in 4.0 case too.
 	 */
 	return !list_empty(&clp->cl_openowners)
+		|| !list_empty(&clp->cl_lo_states)
 		|| !list_empty(&clp->cl_delegations)
 		|| !list_empty(&clp->cl_sessions);
 }
@@ -4257,8 +4258,9 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	clp = cstate->clp;
 	status = nfserr_cb_path_down;
-	if (!list_empty(&clp->cl_delegations)
-			&& clp->cl_cb_state != NFSD4_CB_UP)
+	if ((!list_empty(&clp->cl_delegations)
+	     || !list_empty(&clp->cl_lo_states))
+	    && clp->cl_cb_state != NFSD4_CB_UP)
 		goto out;
 	status = nfs_ok;
 out:
-- 
2.4.3

