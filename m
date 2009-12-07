From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 24/35] pnfsd: new nfsd filesystem file: pnfs_dlm_device
Date: Mon,  7 Dec 2009 11:35:07 +0200
Message-ID: <1260178507-15763-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1378 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934899AbZLGJeK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:34:10 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Change nfsd filesystem name from pnfs_ds_list to pnfs_dlm_device
write the per block device dlm data server cache

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
---
 fs/nfsd/nfsctl.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index a44c1c2..14b9f37 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -49,6 +49,9 @@ enum {
 	NFSD_Leasetime,
 	NFSD_RecoveryDir,
 #endif
+#ifdef CONFIG_PNFSD
+	NFSD_pnfs_dlm_device,
+#endif
 };
 
 /*
@@ -73,6 +76,9 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
+#ifdef CONFIG_PNFSD
+static ssize_t write_pnfs_dlm_device(struct file *file, char *buf, size_t size);
+#endif
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -94,6 +100,9 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
 #endif
+#ifdef CONFIG_PNFSD
+	[NFSD_pnfs_dlm_device] = write_pnfs_dlm_device,
+#endif
 };
 
 static ssize_t nfsctl_transaction_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
@@ -1291,6 +1300,66 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 
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
@@ -1322,6 +1391,10 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
+#ifdef CONFIG_PNFSD
+		[NFSD_pnfs_dlm_device] = {"pnfs_dlm_device", &transaction_ops,
+					   S_IWUSR|S_IRUSR},
+#endif
 		/* last one */ {""}
 	};
 	return simple_fill_super(sb, 0x6e667364, nfsd_files);
-- 
1.6.5.1

