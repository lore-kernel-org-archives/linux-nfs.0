Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f54.google.com ([209.85.128.54]:55568 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:11 -0400
Received: by mail-qe0-f54.google.com with SMTP id cy11so1119161qeb.13
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:11 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 34/49] pnfsd: new nfsd filesystem file: pnfs_dlm_device
Date: Thu, 26 Sep 2013 14:42:09 -0400
Message-Id: <1380220929-14257-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Change nfsd filesystem name from pnfs_ds_list to pnfs_dlm_device
write the per block device dlm data server cache

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfsctl.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b8bfa2e..7da8584 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -50,6 +50,9 @@ enum {
 	NFSD_Gracetime,
 	NFSD_RecoveryDir,
 #endif
+#ifdef CONFIG_PNFSD
+	NFSD_pnfs_dlm_device,
+#endif
 };
 
 /*
@@ -68,6 +71,9 @@ enum {
 static ssize_t write_gracetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
+#ifdef CONFIG_PNFSD
+static ssize_t write_pnfs_dlm_device(struct file *file, char *buf, size_t size);
+#endif
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Fh] = write_filehandle,
@@ -83,6 +89,9 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Gracetime] = write_gracetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
 #endif
+#ifdef CONFIG_PNFSD
+	[NFSD_pnfs_dlm_device] = write_pnfs_dlm_device,
+#endif
 };
 
 static ssize_t nfsctl_transaction_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
@@ -1037,6 +1046,66 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 
 #endif
 
+#ifdef CONFIG_PNFSD
+
+static ssize_t __write_pnfs_dlm_device(struct file *file, char *buf,
+				       size_t size)
+{
+	char *mesg = buf;
+	char *pnfs_dlm_device;
+	int max_size = NFSD_PNFS_DLM_DEVICE_MAX;
+	int len, ret = 0;
+
+	if (size > 0) {
+		ret = -EINVAL;
+		if (size > max_size || buf[size-1] != '\n')
+			return ret;
+		buf[size-1] = 0;
+
+		pnfs_dlm_device = mesg;
+		len = qword_get(&mesg, pnfs_dlm_device, size);
+		if (len <= 0)
+			return ret;
+
+		ret = nfsd4_set_pnfs_dlm_device(pnfs_dlm_device, len);
+	}
+	return ret <= 0 ? ret : strlen(buf);
+}
+
+/**
+ * write_pnfs_dlm_device - Set or report the current pNFS data server list
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing a block device name,
+ *					a colon, and then a comma separated
+ *					list of pNFS data server IPv4 addresses
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C
+ *			string containing a block device name, a colon, and
+ *			then a comma separated list of pNFS
+ *			data server IPv4 addresses.
+ *			return code is the size in bytes of the string
+ *	On error:	return code is a negative errno value
+ */
+static ssize_t write_pnfs_dlm_device(struct file *file, char *buf, size_t size)
+{
+	ssize_t rv;
+
+	mutex_lock(&nfsd_mutex);
+	rv = __write_pnfs_dlm_device(file, buf, size);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
+}
+
+#endif /* CONFIG_PNFSD */
+
 /*----------------------------------------------------------------------------*/
 /*
  *	populating the filesystem.
@@ -1068,6 +1137,10 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
+#ifdef CONFIG_PNFSD
+		[NFSD_pnfs_dlm_device] = {"pnfs_dlm_device", &transaction_ops,
+					   S_IWUSR|S_IRUSR},
+#endif
 		/* last one */ {""}
 	};
 	struct net *net = data;
-- 
1.8.3.1

