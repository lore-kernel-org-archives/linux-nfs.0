Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:52086 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757892Ab2DYT2O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2012 15:28:14 -0400
Received: by yenl12 with SMTP id l12so433476yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Apr 2012 12:28:13 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.net
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: trivial: use SEEK_SET instead of 0 in vfs_llseek
Date: Wed, 25 Apr 2012 15:28:08 -0400
Message-Id: <1335382088-5463-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They're equivalent, but SEEK_SET is more informative...

Cc: Eric Sandeen <sandeen@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5686661..c8bd9c3 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2039,7 +2039,7 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	if (err)
 		goto out;
 
-	offset = vfs_llseek(file, offset, 0);
+	offset = vfs_llseek(file, offset, SEEK_SET);
 	if (offset < 0) {
 		err = nfserrno((int)offset);
 		goto out_close;
-- 
1.7.7.6

