Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:58418 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516Ab3JURKX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:10:23 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 5/5] NFSv4: clean up nfs4_state reference counting
Date: Mon, 21 Oct 2013 13:10:14 -0400
Message-ID: <1382375414-5854-6-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-1-git-send-email-dros@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use atomic_inc_not_zero() to avoid referencing a state that is currently
being freed.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c  | 8 ++++++--
 fs/nfs/nfs4state.c | 3 ++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a3b78df..005543d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1275,7 +1275,8 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 out:
 	return ERR_PTR(ret);
 out_return_state:
-	atomic_inc(&state->count);
+	if (!atomic_inc_not_zero(&state->count))
+		return ERR_PTR(-EINVAL);
 	return state;
 }
 
@@ -1429,7 +1430,10 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
-	atomic_inc(&state->count);
+	if (!atomic_inc_not_zero(&state->count)) {
+		nfs4_opendata_put(opendata);
+		return ERR_PTR(-EINVAL);
+	}
 	return opendata;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cc14cbb..1c71907 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1416,7 +1416,8 @@ restart:
 			continue;
 		if (state->state == 0)
 			continue;
-		atomic_inc(&state->count);
+		if (!atomic_inc_not_zero(&state->count))
+			continue;
 		spin_unlock(&sp->so_lock);
 		status = ops->recover_open(sp, state);
 		if (status >= 0) {
-- 
1.7.12.4 (Apple Git-37)

