Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga01-in.huawei.com ([119.145.14.64]:33348 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566Ab3LICav (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Dec 2013 21:30:51 -0500
Message-ID: <52A52B08.9040305@huawei.com>
Date: Mon, 9 Dec 2013 10:29:28 +0800
From: Rui Xiang <rui.xiang@huawei.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH RESEND] nfsd: return err directly while allocing failing
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

while nthreads alloc fails, return err value directly
without kfree.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 fs/nfsd/nfsctl.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f55517..1fa6b00 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -491,9 +491,10 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	}
 
 	nthreads = kcalloc(npools, sizeof(int), GFP_KERNEL);
-	rv = -ENOMEM;
-	if (nthreads == NULL)
-		goto out_free;
+	if (nthreads == NULL) {
+		mutex_unlock(&nfsd_mutex);
+		return -ENOMEM;
+	}
 
 	if (size > 0) {
 		for (i = 0; i < npools; i++) {
-- 
1.8.2.2


