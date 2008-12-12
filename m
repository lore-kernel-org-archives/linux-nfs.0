From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/22] NFSD: clean up failover sysctl function naming
Date: Fri, 12 Dec 2008 16:57:13 -0500
Message-ID: <20081212215712.24332.24649.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:35751 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757638AbYLLV5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:57:33 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Rename recently-added failover functions to match the naming
convention in fs/nfsd/nfsctl.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e3f9783..6ebc607 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -84,6 +84,8 @@ static ssize_t write_unexport(struct file *file, char *buf, size_t size);
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
+static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size);
+static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
@@ -94,9 +96,6 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
-static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
-static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
-
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -106,8 +105,8 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
-	[NFSD_FO_UnlockIP] = failover_unlock_ip,
-	[NFSD_FO_UnlockFS] = failover_unlock_fs,
+	[NFSD_FO_UnlockIP] = write_unlock_ip,
+	[NFSD_FO_UnlockFS] = write_unlock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -309,7 +308,7 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 	return err;
 }
 
-static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
+static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 {
 	struct sockaddr_in sin = {
 		.sin_family	= AF_INET,
@@ -339,7 +338,7 @@ static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
 	return nlmsvc_unlock_all_by_ip((struct sockaddr *)&sin);
 }
 
-static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
+static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size)
 {
 	struct path path;
 	char *fo_path;

