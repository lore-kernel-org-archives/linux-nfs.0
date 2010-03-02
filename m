From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 6/7] nfsd4: allow setting grace period time
Date: Tue,  2 Mar 2010 18:12:52 -0500
Message-ID: <1267571573-11844-7-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-4-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-5-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-6-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54598 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow explicit configuration of the grace period time as well as the
lease period time.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    2 +-
 fs/nfsd/nfsctl.c    |   19 +++++++++++++++++++
 fs/nfsd/nfsd.h      |    1 +
 3 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4471046..6edfe23 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -45,7 +45,7 @@
 
 /* Globals */
 time_t nfsd4_lease = 90;     /* default lease time */
-static time_t nfsd4_grace = 90;
+time_t nfsd4_grace = 90;
 static time_t boot_time;
 static u32 current_ownerid = 1;
 static u32 current_fileid = 1;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1db8010..7bdaf31 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -45,6 +45,7 @@ enum {
 	 */
 #ifdef CONFIG_NFSD_V4
 	NFSD_Leasetime,
+	NFSD_Gracetime,
 	NFSD_RecoveryDir,
 #endif
 };
@@ -69,6 +70,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size);
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
+static ssize_t write_gracetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
@@ -90,6 +92,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_MaxBlkSize] = write_maxblksize,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
+	[NFSD_Gracetime] = write_gracetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
 #endif
 };
@@ -1252,6 +1255,21 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 	return write_time(file, buf, size, &nfsd4_lease);
 }
 
+/**
+ * write_gracetime - Set or report current NFSv4 grace period time
+ *
+ * As above, but sets the time of the NFSv4 grace period.
+ *
+ * Note this should never be set to less than the *previous*
+ * lease-period time, but we don't try to enforce this.  (In the common
+ * case (a new boot), we don't know what the previous lease time was
+ * anyway.)
+ */
+static ssize_t write_gracetime(struct file *file, char *buf, size_t size)
+{
+	return write_time(file, buf, size, &nfsd4_grace);
+}
+
 extern char *nfs4_recoverydir(void);
 
 static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
@@ -1343,6 +1361,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
 		/* last one */ {""}
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index b463093..7237776 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -228,6 +228,7 @@ extern struct timeval	nfssvc_boot;
 #ifdef CONFIG_NFSD_V4
 
 extern time_t nfsd4_lease;
+extern time_t nfsd4_grace;
 
 /* before processing a COMPOUND operation, we have to check that there
  * is enough space in the buffer for XDR encode to succeed.  otherwise,
-- 
1.6.3.3

