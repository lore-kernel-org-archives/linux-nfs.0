Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52638 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdE0IRF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:05 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        stable@vger.kernel.org
Subject: [PATCH 01/10] fs: pass on flags in compat_writev
Date: Sat, 27 May 2017 11:16:45 +0300
Message-Id: <20170527081654.15957-2-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes: 793b80ef ("vfs: pass a flags argument to vfs_readv/vfs_writev")
Signed-off-by: Christoph Hellwig <hch@lst.de>
Cc: stable@vger.kernel.org
---
 fs/read_write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 47c1d4484df9..19d4d88fa285 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1285,7 +1285,7 @@ static size_t compat_writev(struct file *file,
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		goto out;
 
-	ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos, 0);
+	ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos, flags);
 
 out:
 	if (ret > 0)
-- 
2.11.0

