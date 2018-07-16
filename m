Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46715 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727857AbeGPMhF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Jul 2018 08:37:05 -0400
From: Colin King <colin.king@canonical.com>
To: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: fix memory leak of async_copy
Date: Mon, 16 Jul 2018 13:09:54 +0100
Message-Id: <20180716120954.6720-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

In the case where async_copy is successfully allocated but
the call to nfs4_init_cp_state fails, async_copy is not
currently freed and the memory is leaked. Fix this by kfree'ing
it before returning.

Detected by CoverityScan, CID#1471823 ("Resource leak")

Fixes: beb1814d5a8a ("NFSD create new stateid for async copy")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/nfsd/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8f3368353aaf..3fb96a2708b9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1295,8 +1295,10 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 		if (!async_copy)
 			goto out;
-		if (!nfs4_init_cp_state(nn, copy))
+		if (!nfs4_init_cp_state(nn, copy)) {
+			kfree(async_copy);
 			goto out;
+		}
 		refcount_set(&async_copy->refcount, 1);
 		memcpy(&copy->cp_res.cb_stateid, &copy->cp_stateid,
 			sizeof(copy->cp_stateid));
-- 
2.17.1

