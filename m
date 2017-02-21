Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33656 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751904AbdBUPjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 10:39:20 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFS4: remove a redundant lock range check
Date: Tue, 21 Feb 2017 10:39:14 -0500
Message-Id: <65bfbbf71119f151f320d47f2e5fe423eb640e78.1487691345.git.bcodding@redhat.com>
In-Reply-To: <cover.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
In-Reply-To: <cover.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

flock64_to_posix_lock() is already doing this check

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4proc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a0eaecf9676..9388899e4050 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6570,9 +6570,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	ctx = nfs_file_open_context(filp);
 	state = ctx->state;
 
-	if (request->fl_start < 0 || request->fl_end < 0)
-		return -EINVAL;
-
 	if (IS_GETLK(cmd)) {
 		if (state != NULL)
 			return nfs4_proc_getlk(state, F_GETLK, request);
-- 
2.9.3

