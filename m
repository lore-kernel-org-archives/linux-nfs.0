Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34570 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab1CTLWY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Mar 2011 07:22:24 -0400
Date: Sun, 20 Mar 2011 14:22:07 +0300
From: Dan Carpenter <error27@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk,
        kernel-janitors@vger.kernel.org
Subject: [patch] nfs: lock() vs unlock() typo
Message-ID: <20110320112207.GM2008@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These should be spin_unlock() instead of spin_lock().  It's a typo.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index c0b8344..bf1c680 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -98,7 +98,7 @@ rename_retry:
 		namelen--;
 	buflen -= namelen;
 	if (buflen < 0) {
-		spin_lock(&dentry->d_lock);
+		spin_unlock(&dentry->d_lock);
 		rcu_read_unlock();
 		goto Elong;
 	}
@@ -108,7 +108,7 @@ rename_retry:
 	rcu_read_unlock();
 	return end;
 Elong_unlock:
-	spin_lock(&dentry->d_lock);
+	spin_unlock(&dentry->d_lock);
 	rcu_read_unlock();
 	if (read_seqretry(&rename_lock, seq))
 		goto rename_retry;
