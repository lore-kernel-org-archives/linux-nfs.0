Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:57583 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbaJFXnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 19:43:03 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so7785450wgg.13
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 16:43:01 -0700 (PDT)
From: Zach Brown <zab@zabbo.net>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: fix inclusive vfs_fsync_range() end
Date: Mon,  6 Oct 2014 16:42:52 -0700
Message-Id: <1412638972-14617-1-git-send-email-zab@zabbo.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The vfs_fsync_range() call during write processing got the end of the
range off by one.  The range is inclusive, not exclusive.  The error has
nfsd sync more data than requested -- it's correct but unnecessary
overhead.

The call during commit processing is correct so I copied that pattern in
write processing.  Maybe a helper would be nice but I kept it trivial.

This is untested.  I found it while reviewing code for something else
entirely.

Signed-off-by: Zach Brown <zab@zabbo.net>
---
 fs/nfsd/vfs.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f501a9b..825250e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -921,6 +921,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	int			stable = *stablep;
 	int			use_wgather;
 	loff_t			pos = offset;
+	loff_t			end = LLONG_MAX;
 	unsigned int		pflags = current->flags;
 
 	if (rqstp->rq_local)
@@ -952,10 +953,13 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	fsnotify_modify(file);
 
 	if (stable) {
-		if (use_wgather)
+		if (use_wgather) {
 			host_err = wait_for_concurrent_writes(file);
-		else
-			host_err = vfs_fsync_range(file, offset, offset+*cnt, 0);
+		} else {
+			if (*cnt)
+				end = offset + *cnt - 1;
+			host_err = vfs_fsync_range(file, offset, end, 0);
+		}
 	}
 
 out_nfserr:
-- 
1.9.3

