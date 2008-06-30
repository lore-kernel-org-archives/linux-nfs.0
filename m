From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/16] lockd: Pass "struct sockaddr *" to new failover-by-IP
	function
Date: Mon, 30 Jun 2008 18:58:14 -0400
Message-ID: <20080630225813.25407.29856.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51792 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763705AbYF3XAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:33 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass a more generic socket address type to nlmsvc_unlock_all_by_ip() to
allow for future support of IPv6.  Also provide additional sanity
checking in failover_unlock_ip() when constructing the server's IP
address.

As an added bonus, provide clean kerneldoc comments on related NLM
interfaces which were recently added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svcsubs.c          |   39 +++++++++++++++++++++++++--------------
 fs/nfsd/nfsctl.c            |   15 ++++++++++-----
 include/linux/lockd/lockd.h |    2 +-
 3 files changed, 36 insertions(+), 20 deletions(-)


diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index d1c48b5..723b6d5 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -373,18 +373,18 @@ nlmsvc_free_host_resources(struct nlm_host *host)
 	}
 }
 
-/*
- * Remove all locks held for clients
+/**
+ * nlmsvc_invalidate_all - remove all locks held for clients
+ *
+ * Release all locks held by NFS clients.  Previously, the code
+ * would call nlmsvc_free_host_resources for each client in turn,
+ * which is about as inefficient as it gets.
+ *
+ * Now we just do it once in nlm_traverse_files.
  */
 void
 nlmsvc_invalidate_all(void)
 {
-	/* Release all locks held by NFS clients.
-	 * Previously, the code would call
-	 * nlmsvc_free_host_resources for each client in
-	 * turn, which is about as inefficient as it gets.
-	 * Now we just do it once in nlm_traverse_files.
-	 */
 	nlm_traverse_files(NULL, nlmsvc_is_client, NULL);
 }
 
@@ -396,6 +396,12 @@ nlmsvc_match_sb(void *datap, struct nlm_file *file)
 	return sb == file->f_file->f_path.mnt->mnt_sb;
 }
 
+/**
+ * nlmsvc_unlock_all_by_sb - release locks held on this file system
+ * @sb: super block
+ *
+ * Release all locks held by clients accessing this file system.
+ */
 int
 nlmsvc_unlock_all_by_sb(struct super_block *sb)
 {
@@ -409,17 +415,22 @@ EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_sb);
 static int
 nlmsvc_match_ip(void *datap, struct nlm_host *host)
 {
-	__be32 *server_addr = datap;
-
-	return host->h_saddr.sin_addr.s_addr == *server_addr;
+	return nlm_cmp_addr(&host->h_saddr, datap);
 }
 
+/**
+ * nlmsvc_unlock_all_by_ip - release local locks by IP address
+ * @server_addr: server's IP address as seen by clients
+ *
+ * Release all locks held by clients accessing this host
+ * via the passed in IP address.
+ */
 int
-nlmsvc_unlock_all_by_ip(__be32 server_addr)
+nlmsvc_unlock_all_by_ip(struct sockaddr *server_addr)
 {
 	int ret;
-	ret = nlm_traverse_files(&server_addr, nlmsvc_match_ip, NULL);
-	return ret ? -EIO : 0;
 
+	ret = nlm_traverse_files(server_addr, nlmsvc_match_ip, NULL);
+	return ret ? -EIO : 0;
 }
 EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_ip);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5ac00c4..5b4a412 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -310,9 +310,12 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 
 static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
 {
-	__be32 server_ip;
-	char *fo_path, c;
+	struct sockaddr_in sin = {
+		.sin_family	= AF_INET,
+	};
 	int b1, b2, b3, b4;
+	char c;
+	char *fo_path;
 
 	/* sanity check */
 	if (size == 0)
@@ -326,11 +329,13 @@ static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
 		return -EINVAL;
 
 	/* get ipv4 address */
-	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+	if (sscanf(fo_path, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) != 4)
+		return -EINVAL;
+	if (b1 > 255 || b2 > 255 || b3 > 255 || b4 > 255)
 		return -EINVAL;
-	server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+	sin.sin_addr.s_addr = htonl((b1 << 24) | (b2 << 16) | (b3 << 8) | b4);
 
-	return nlmsvc_unlock_all_by_ip(server_ip);
+	return nlmsvc_unlock_all_by_ip((struct sockaddr *)&sin);
 }
 
 static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 102d928..a6d1215 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -224,7 +224,7 @@ void		  nlmsvc_invalidate_all(void);
  * Cluster failover support
  */
 int           nlmsvc_unlock_all_by_sb(struct super_block *sb);
-int           nlmsvc_unlock_all_by_ip(__be32 server_addr);
+int           nlmsvc_unlock_all_by_ip(struct sockaddr *server_addr);
 
 static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
 {

