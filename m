Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:44750 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbbB1EQU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 23:16:20 -0500
Received: by igdh15 with SMTP id h15so5530040igd.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2015 20:16:20 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Ensure that buffered writes wait for O_DIRECT writes to complete
Date: Fri, 27 Feb 2015 23:16:17 -0500
Message-Id: <1425096977-9293-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The O_DIRECT code will grab the inode->i_mutex and flush out buffered
writes, before scheduling a read or a write. However there is no
equivalent in the buffered write code to wait for O_DIRECT to complete.

Fixes a reported issue in xfstests generic/133, when first performing an
O_DIRECT write followed by a buffered write.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 94712fc781fa..c045c7169fa0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -372,6 +372,10 @@ start:
 				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (ret)
 		return ret;
+	/*
+	 * Wait for O_DIRECT to complete
+	 */
+	nfs_inode_dio_wait(mapping->host);
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
-- 
2.1.0

