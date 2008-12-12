From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/22] NFSD: Prevent buffer overflow in write_maxblksize()
Date: Fri, 12 Dec 2008 16:59:19 -0500
Message-ID: <20081212215919.24332.55627.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:58909 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409AbYLLV7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:59:50 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_maxblksize() to eliminate the slight possibility of
overflowing its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 41e09c6..0fad95c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1131,6 +1131,7 @@ int nfsd_max_blksize;
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
+
 	if (size > 0) {
 		int bsize;
 		int rv = get_int(&mesg, &bsize);
@@ -1152,7 +1153,9 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 		nfsd_max_blksize = bsize;
 		mutex_unlock(&nfsd_mutex);
 	}
-	return sprintf(buf, "%d\n", nfsd_max_blksize);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
+							nfsd_max_blksize);
 }
 
 #ifdef CONFIG_NFSD_V4

