From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 02/21] nfsd41: control nfsv4.1 svc via /proc/fs/nfsd/versions
Date: Fri,  3 Apr 2009 01:37:37 +0300
Message-ID: <1238711857-22084-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2925 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765272AbZDBWhm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:37:42 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will allow us to get rid of CONFIG_NFSD_V4_1

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |    2 +-
 fs/nfsd/nfsctl.c          |   26 +++++++++++++++++++++++---
 fs/nfsd/nfssvc.c          |   24 ++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h |    2 ++
 4 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a393d38..7619970 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -943,7 +943,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	 * According to RFC3010, this takes precedence over all other errors.
 	 */
 	status = nfserr_minor_vers_mismatch;
-	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
+	if (args->minorversion > nfsd_supported_minorversion)
 		goto out;
 
 	if (!nfs41_op_ordering_ok(args)) {
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4adebb6..a9b8c75 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -792,8 +792,9 @@ out_free:
 static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
-	char *vers, sign;
+	char *vers, *minorp, sign;
 	int len, num;
+	unsigned minor;
 	ssize_t tlen = 0;
 	char *sep;
 
@@ -814,9 +815,20 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 		do {
 			sign = *vers;
 			if (sign == '+' || sign == '-')
-				num = simple_strtol((vers+1), NULL, 0);
+				num = simple_strtol((vers+1), &minorp, 0);
 			else
-				num = simple_strtol(vers, NULL, 0);
+				num = simple_strtol(vers, &minorp, 0);
+			if (*minorp == '.') {
+				if (num < 4)
+					return -EINVAL;
+				minor = simple_strtoul(minorp+1, NULL, 0);
+				if (minor == 0)
+					return -EINVAL;
+				if (nfsd_minorversion(minor, sign == '-' ?
+						     NFSD_CLEAR : NFSD_SET) < 0)
+					return -EINVAL;
+				goto next;
+			}
 			switch(num) {
 			case 2:
 			case 3:
@@ -826,6 +838,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 			default:
 				return -EINVAL;
 			}
+		next:
 			vers += len + 1;
 			tlen += len;
 		} while ((len = qword_get(&mesg, vers, size)) > 0);
@@ -844,6 +857,13 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 				       num);
 			sep = " ";
 		}
+	if (nfsd_vers(4, NFSD_AVAIL))
+		for (minor = 1; minor <= NFSD_SUPPORTED_MINOR_VERSION; minor++)
+			len += sprintf(buf+len, " %c4.%u",
+					(nfsd_vers(4, NFSD_TEST) &&
+					 nfsd_minorversion(minor, NFSD_TEST)) ?
+						'+' : '-',
+					minor);
 	len += sprintf(buf+len, "\n");
 	return len;
 }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ab60320..097dc55 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -121,6 +121,8 @@ struct svc_program		nfsd_program = {
 
 };
 
+u32 nfsd_supported_minorversion = NFSD_SUPPORTED_MINOR_VERSION;
+
 int nfsd_vers(int vers, enum vers_op change)
 {
 	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
@@ -147,6 +149,28 @@ int nfsd_vers(int vers, enum vers_op change)
 	}
 	return 0;
 }
+
+int nfsd_minorversion(u32 minorversion, enum vers_op change)
+{
+	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION)
+		return -1;
+	switch(change) {
+	case NFSD_SET:
+		nfsd_supported_minorversion = minorversion;
+		break;
+	case NFSD_CLEAR:
+		if (minorversion == 0)
+			return -1;
+		nfsd_supported_minorversion = minorversion - 1;
+		break;
+	case NFSD_TEST:
+		return minorversion <= nfsd_supported_minorversion;
+	case NFSD_AVAIL:
+		return minorversion <= NFSD_SUPPORTED_MINOR_VERSION;
+	}
+	return 0;
+}
+
 /*
  * Maximum number of nfsd processes
  */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index b9e6682..27b9cf5 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -57,6 +57,7 @@ typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
+extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
 
@@ -153,6 +154,7 @@ int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
 
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(int vers, enum vers_op change);
+int nfsd_minorversion(u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(void);
 int nfsd_create_serv(void);
 
-- 
1.6.2.1

