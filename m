Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50487 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757480AbaIRGKJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 02:10:09 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 18 Sep 2014 16:09:27 +1000
Subject: [PATCH 2/2] NFS: don't use STABLE writes during writeback.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140918060927.24098.78914.stgit@notabene.brown>
In-Reply-To: <20140918060551.24098.72288.stgit@notabene.brown>
References: <20140918060551.24098.72288.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit b31268ac793fd300da66b9c28bbf0a200339ab96
  FS: Use stable writes when not doing a bulk flush

was a bit heavy handed.
The particular problem that lead to this patch was that
small writes to an O_SYNC file we being written as UNSTABLE writes
followed by a commit.
This is appropriate for large writes (which require multiple NFS
requests) but for small writes (single NFS request), using
NFS_FILE_SYNC is more efficient.

So that patch causes the code to select between the two methods
depending on how many nfs requests get generated.

Unfortunately this ends up applying to non O_SYNC writes as well.
In particular if you memory-map a file and update random pages, then
when they are eventually written out by writeback they will go as
NFS_FILE_SYNC.  This is inefficient and slows down the application.


So: only set FLUSH_COND_STABLE when wbc->sync_mode is WB_SYNC_ALL.
With this patch:
 O_SYNC writes are NFS_FILE_SYNC for single requests, and NFS_UNSTABLE
    followed by COMMIT for multiple requests
 Writing immediately before close of fsync follow the same pattern.
 Non-O_SYNC writes without an fsync of close eventually get flushed
 out as UNSTABLE and a commit follows eventually as appropriate.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/write.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3066c7fcb565..8d4aae9d977a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -271,11 +271,14 @@ static void nfs_mark_uptodate(struct nfs_page *req)
 
 static int wb_priority(struct writeback_control *wbc)
 {
+	int ret = 0;
 	if (wbc->for_reclaim)
 		return FLUSH_HIGHPRI | FLUSH_STABLE;
+	if (wbc->sync_mode == WB_SYNC_ALL)
+		ret = FLUSH_COND_STABLE;
 	if (wbc->for_kupdate || wbc->for_background)
-		return FLUSH_LOWPRI | FLUSH_COND_STABLE;
-	return FLUSH_COND_STABLE;
+		ret |= FLUSH_LOWPRI;
+	return ret;
 }
 
 /*


