Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:48686 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdE0IRY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:24 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 06/10] fs: set kernel address limit in do_loop_readv_writev
Date: Sat, 27 May 2017 11:16:50 +0300
Message-Id: <20170527081654.15957-7-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will allow to use all iov_iter based read/write for ITER_KVEC
without having to check if the file has the iter version of the
read/write ops, which will allow us to get rid of a large number
of get_fs/set_fs calls in drivers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index 64b61a032a56..60c64a996ab2 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -704,9 +704,18 @@ static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
 		loff_t *ppos, int type, int flags)
 {
 	ssize_t ret = 0;
+	mm_segment_t uninitialized_var(old_fs);
 
 	if (flags & ~RWF_HIPRI)
 		return -EOPNOTSUPP;
+	if (iter->type & (ITER_BVEC | ITER_PIPE))
+		return -EOPNOTSUPP;
+
+	/* adjust the address limit for in-kernel I/O */
+	if (iter->type & ITER_KVEC) {
+		old_fs = get_fs();
+		set_fs(get_ds());
+	}
 
 	while (iov_iter_count(iter)) {
 		struct iovec iovec = iov_iter_iovec(iter);
@@ -731,6 +740,8 @@ static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
 		iov_iter_advance(iter, nr);
 	}
 
+	if (iter->type & ITER_KVEC)
+		set_fs(old_fs);
 	return ret;
 }
 
-- 
2.11.0

