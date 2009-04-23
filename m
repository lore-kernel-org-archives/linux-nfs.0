From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/19] NFSD: Stricter buffer size checking in fs/nfsd/nfsctl.c
Date: Thu, 23 Apr 2009 19:33:25 -0400
Message-ID: <20090423233325.17283.71127.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26838 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbZDWXe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:29 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: For consistency, handle output buffer size checking in a
other nfsctl functions the same way it's done for write_versions().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index a152694..877e713 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -695,8 +695,9 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 		if (rv)
 			return rv;
 	}
-	sprintf(buf, "%d\n", nfsd_nrthreads());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
+							nfsd_nrthreads());
 }
 
 /**
@@ -1197,7 +1198,9 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 		nfsd_max_blksize = bsize;
 		mutex_unlock(&nfsd_mutex);
 	}
-	return sprintf(buf, "%d\n", nfsd_max_blksize);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
+							nfsd_max_blksize);
 }
 
 #ifdef CONFIG_NFSD_V4
@@ -1221,8 +1224,9 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 			return -EINVAL;
 		nfs4_reset_lease(lease);
 	}
-	sprintf(buf, "%ld\n", nfs4_lease_time());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
+							nfs4_lease_time());
 }
 
 /**

