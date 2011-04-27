Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64228 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755066Ab1D0BZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Apr 2011 21:25:15 -0400
Message-ID: <4DB76D60.3010802@cn.fujitsu.com>
Date: Wed, 27 Apr 2011 09:12:00 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: Deny new lock before RECLAIM_COMPLETE done
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Before nfs41 client's RECLAIM_COMPLETE done, nfs server should 
deny it's new lock.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4b36ec3..43cda94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3803,6 +3803,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 */
 		struct nfs4_stateid *open_stp = NULL;
 		
+		/*
+		 * RFC5661 18.51.3
+		 * Before RECLAIM_COMPLETE done, return NFS4ERR_GRACE
+		 */
+		status = nfserr_grace;
+		if (nfsd4_has_session(cstate) &&
+		    !cstate->session->se_client->cl_firststate)
+			goto out;
+
 		status = nfserr_stale_clientid;
 		if (!nfsd4_has_session(cstate) &&
 		    STALE_CLIENTID(&lock->lk_new_clientid))
-- 
1.7.4.1


