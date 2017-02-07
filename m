Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33499 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754059AbdBGNuj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:50:39 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so12867944iom.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:50:39 -0800 (PST)
Subject: [PATCH 7/7] sunrpc: use simple_read_from_buffer for reading cache
 flush
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <02295874-6761-724a-ec8c-cc5159bc0d98@gmail.com>
Date: Tue, 7 Feb 2017 21:50:32 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/cache.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9e8561d..2f06f51 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1427,20 +1427,11 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 			  struct cache_detail *cd)
 {
 	char tbuf[22];
-	unsigned long p = *ppos;
 	size_t len;
 
-	snprintf(tbuf, sizeof(tbuf), "%lu\n", convert_to_wallclock(cd->flush_time));
-	len = strlen(tbuf);
-	if (p >= len)
-		return 0;
-	len -= p;
-	if (len > count)
-		len = count;
-	if (copy_to_user(buf, (void*)(tbuf+p), len))
-		return -EFAULT;
-	*ppos += len;
-	return len;
+	len = snprintf(tbuf, sizeof(tbuf), "%lu\n",
+			convert_to_wallclock(cd->flush_time));
+	return simple_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
 static ssize_t write_flush(struct file *file, const char __user *buf,
-- 
2.9.3

