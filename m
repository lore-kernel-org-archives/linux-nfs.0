From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 005/100] SUNRPC: Prevent length underflow in read_flush()
Date: Fri, 25 Jan 2008 18:15:45 -0500
Message-ID: <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47309 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759082AbYAYXRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:23 -0500
In-Reply-To: <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Make sure we compare an unsigned length to an unsigned count in
read_flush().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/cache.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8e05557..578084f 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1242,18 +1242,18 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
 	char tbuf[20];
 	unsigned long p = *ppos;
-	int len;
+	size_t len;
 
 	sprintf(tbuf, "%lu\n", cd->flush_time);
 	len = strlen(tbuf);
 	if (p >= len)
 		return 0;
 	len -= p;
-	if (len > count) len = count;
+	if (len > count)
+		len = count;
 	if (copy_to_user(buf, (void*)(tbuf+p), len))
-		len = -EFAULT;
-	else
-		*ppos += len;
+		return -EFAULT;
+	*ppos += len;
 	return len;
 }
 
-- 
1.5.4.rc2.60.gb2e62

