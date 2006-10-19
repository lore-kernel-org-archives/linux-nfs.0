From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/11] NFS: Fix error handling in nfs_direct_write_result()
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.446.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946246AbWJSRGK@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If the RPC call tanked, we should not be checking the return value
of data->res.verf->committed, since it is unlikely to even be
initialised.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9f7f8b9..1e873fc 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -532,10 +532,12 @@ static void nfs_direct_write_result(stru
 
 	spin_lock(&dreq->lock);
 
-	if (likely(status >= 0))
-		dreq->count += data->res.count;
-	else
-		dreq->error = task->tk_status;
+	if (unlikely(status < 0)) {
+		dreq->error = status;
+		goto out_unlock;
+	}
+
+	dreq->count += data->res.count;
 
 	if (data->res.verf->committed != NFS_FILE_SYNC) {
 		switch (dreq->flags) {
@@ -550,7 +552,7 @@ static void nfs_direct_write_result(stru
 				}
 		}
 	}
-
+out_unlock:
 	spin_unlock(&dreq->lock);
 }
 
