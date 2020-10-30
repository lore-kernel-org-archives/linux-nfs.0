Return-Path: <SRS0=TAi6=EF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2811EC00A89
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Oct 2020 22:07:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B97542087E
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Oct 2020 22:07:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604095662;
	bh=ScIdmztlvC5lGaF8OhAEJdAQTYeDvTVf/YgYH6yqrBA=;
	h=From:To:Subject:Date:List-ID:From;
	b=gCMcQQ32mjL4S5sxhJAcZDXFRrYAFAKzJx4qlfONCdJtYD9/vtsxhBxD4jjX7dAMj
	 ApxzAkYvwOXlGIKCiEDacfWHnOE8G9Cslg5JnXtkhJOcgVnD7A86limRqb1TLhVAmu
	 gCwdDusLsFH9SnVFjUf50amjiXm9rtKnhVuDccJ4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725797AbgJ3WHm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Oct 2020 18:07:42 -0400
Received: from mail.kernel.org ([198.145.29.99]:58808 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725792AbgJ3WHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Oct 2020 18:07:42 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 57AEC2087E
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2020 22:07:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604095661;
        bh=ScIdmztlvC5lGaF8OhAEJdAQTYeDvTVf/YgYH6yqrBA=;
        h=From:To:Subject:Date:From;
        b=qwabaBBd/yaNsyAlGDinsHd8wDxbh4Q/tKgPToVHuOK0kjcOXLZKh680pL9XFeF4G
         Pmgj87cBm+w4xbczOGSWdbT4kVljbtmbZHzsKDFn5B41fdHRTIjpxWgP+BymUVLqEQ
         4D+kIXKuXp6GZCs/ld8yWZuDxaUZ79u1F7/qsKok=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Remove unnecessary inode locking in nfs_llseek_dir()
Date:   Fri, 30 Oct 2020 17:57:29 -0400
Message-Id: <20201030215730.85147-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Remove the contentious inode lock, and instead provide thread safety
using the file->f_lock spinlock.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cb52db9a0cfb..e56b1bd99537 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -955,7 +955,6 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 
 static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 {
-	struct inode *inode = file_inode(filp);
 	struct nfs_open_dir_context *dir_ctx = filp->private_data;
 
 	dfprintk(FILE, "NFS: llseek dir(%pD2, %lld, %d)\n",
@@ -967,15 +966,15 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 	case SEEK_SET:
 		if (offset < 0)
 			return -EINVAL;
-		inode_lock(inode);
+		spin_lock(&filp->f_lock);
 		break;
 	case SEEK_CUR:
 		if (offset == 0)
 			return filp->f_pos;
-		inode_lock(inode);
+		spin_lock(&filp->f_lock);
 		offset += filp->f_pos;
 		if (offset < 0) {
-			inode_unlock(inode);
+			spin_unlock(&filp->f_lock);
 			return -EINVAL;
 		}
 	}
@@ -987,7 +986,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 			dir_ctx->dir_cookie = 0;
 		dir_ctx->duped = 0;
 	}
-	inode_unlock(inode);
+	spin_unlock(&filp->f_lock);
 	return offset;
 }
 
-- 
2.28.0

