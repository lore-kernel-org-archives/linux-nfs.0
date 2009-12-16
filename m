From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 06/11] nfsd41: no need to hold the state lock around mark_client_for_renew
Date: Wed, 16 Dec 2009 19:41:37 +0200
Message-ID: <1260985297-21553-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48899 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753844AbZLPRlk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:41:40 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 15f4b63..38817c3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1500,11 +1500,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 out:
 	spin_unlock(&sessionid_lock);
 	/* Renew the clientid on success and on replay */
-	if (cstate->session) {
-		nfs4_lock_state();
+	if (cstate->session)
 		mark_client_for_renew(cstate, session->se_client);
-		nfs4_unlock_state();
-	}
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
-- 
1.6.5.1

