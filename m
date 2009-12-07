From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 05/35] pnfsd: don't set up back channel on create_session for ds
Date: Mon,  7 Dec 2009 11:30:51 +0200
Message-ID: <1260178251-14816-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13097 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934800AbZLGJ3y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:29:54 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dean Hildebrand <seattleplus@gmail.com>

[was pnfsd: Add use of pnfs exchange flags]
Should this code be surrounded by CONFIG_PNFSD?

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9ecbc25..dc9d553 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1349,6 +1349,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cr_ses->flags &= ~SESSION4_PERSIST;
 		cr_ses->flags &= ~SESSION4_RDMA;
 
+		if (!(unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS) &&
+		    (unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS))
+			cr_ses->flags &= ~SESSION4_BACK_CHAN;
+
 		if (cr_ses->flags & SESSION4_BACK_CHAN) {
 			unconf->cl_cb_xprt = rqstp->rq_xprt;
 			svc_xprt_get(unconf->cl_cb_xprt);
-- 
1.6.5.1

