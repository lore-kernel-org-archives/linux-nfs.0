Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f49.google.com ([209.85.160.49]:49865 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaDHFEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2014 01:04:24 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so485226pbb.22
        for <linux-nfs@vger.kernel.org>; Mon, 07 Apr 2014 22:04:23 -0700 (PDT)
Message-ID: <53438341.5090705@gmail.com>
Date: Tue, 08 Apr 2014 13:04:01 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: Use simple_read_from_buffer for coping data to userspace
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/fault_inject.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index d620e7f..2ed05c3 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -97,25 +97,14 @@ static ssize_t fault_inject_read(struct file *file,
char __user *buf,
 {
 	static u64 val;
 	char read_buf[25];
-	size_t size, ret;
+	size_t size;
 	loff_t pos = *ppos;

 	if (!pos)
 		nfsd_inject_get(file_inode(file)->i_private, &val);
 	size = scnprintf(read_buf, sizeof(read_buf), "%llu\n", val);

-	if (pos < 0)
-		return -EINVAL;
-	if (pos >= size || !len)
-		return 0;
-	if (len > size - pos)
-		len = size - pos;
-	ret = copy_to_user(buf, read_buf + pos, len);
-	if (ret == len)
-		return -EFAULT;
-	len -= ret;
-	*ppos = pos + len;
-	return len;
+	return simple_read_from_buffer(buf, len, ppos, read_buf, size);
 }

 static ssize_t fault_inject_write(struct file *file, const char __user
*buf,
-- 
1.9.0

