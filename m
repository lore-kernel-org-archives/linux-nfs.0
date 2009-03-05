From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/23] NFSD: Prevent buffer overflow in write_maxblksize()
Date: Thu, 05 Mar 2009 16:34:01 -0500
Message-ID: <20090305213401.21342.74661.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:50544 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbZCEVeW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:34:22 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_maxblksize() to eliminate the slight possibility of
overflowing its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index cb786bf..67a0b91 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1127,6 +1127,7 @@ int nfsd_max_blksize;
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
+
 	if (size > 0) {
 		int bsize;
 		int rv = get_int(&mesg, &bsize);
@@ -1148,7 +1149,9 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 		nfsd_max_blksize = bsize;
 		mutex_unlock(&nfsd_mutex);
 	}
-	return sprintf(buf, "%d\n", nfsd_max_blksize);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
+							nfsd_max_blksize);
 }
 
 #ifdef CONFIG_NFSD_V4

