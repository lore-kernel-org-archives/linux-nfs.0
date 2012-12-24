Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:47553 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab2LXKtj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Dec 2012 05:49:39 -0500
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfsd: Don't unlock the state while it's not locked
Date: Mon, 24 Dec 2012 18:11:45 +0800
Message-Id: <1356343905-11990-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

In the procedure of CREATE_SESSION, the state is locked after
alloc_conn_from_crses(). If the allocation fails, the function
goes to "out_free_session", and then "out" where there is an
unlock function.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>

---
 fs/nfsd/nfs4state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 29924a0..cc41bf4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1844,11 +1844,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
-out:
 	nfs4_unlock_state();
+out:
 	dprintk("%s returns %d\n", __func__, ntohl(status));
 	return status;
 out_free_conn:
+	nfs4_unlock_state();
 	free_conn(conn);
 out_free_session:
 	__free_session(new);
-- 
1.7.4.4

