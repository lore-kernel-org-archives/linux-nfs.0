From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 23/35] pnfsd: per block device dlm data server list cache
Date: Mon,  7 Dec 2009 11:34:54 +0200
Message-ID: <1260178494-15728-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28065 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934891AbZLGJd5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:33:57 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Simple linked list cache of per block device dlm pnfs data servers.

[pnfsd: define dlm export ops for the !CONFIG_PNFSD case]
[pnfsd: fix pnfs_dlm_device string parsing]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: more fixes for pnfs_dlm_device string parsing]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[restricted use of CONFIG_PNFSD]
[use NFSD_DLM_DS_LIST_MAX defined in include/linux/nfsd/nfs4pnfsdlm.h]
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
---
 fs/nfsd/Makefile                 |    2 +-
 fs/nfsd/nfs4pnfsdlm.c            |  162 ++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c                 |    2 +
 include/linux/nfsd/nfs4pnfsdlm.h |   49 ++++++++++++
 4 files changed, 214 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfsd/nfs4pnfsdlm.c
 create mode 100644 include/linux/nfsd/nfs4pnfsdlm.h

diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 4b4214c..ff5b54d 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -11,4 +11,4 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
-nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o
+nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o nfs4pnfsdlm.o
diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
new file mode 100644
index 0000000..9d91721
--- /dev/null
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -0,0 +1,162 @@
+/******************************************************************************
+ *
+ * (c) 2007 Network Appliance, Inc.  All Rights Reserved.
+ * (c) 2009 NetApp.  All Rights Reserved.
+ *
+ * NetApp provides this source code under the GPL v2 License.
+ * The GPL v2 license is available at
+ * http://opensource.org/licenses/gpl-license.php.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+ * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+ * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+ * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+ * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ ******************************************************************************/
+
+#include <linux/nfsd/debug.h>
+#include <linux/nfsd/nfs4pnfsdlm.h>
+
+#define NFSDDBG_FACILITY                NFSDDBG_PROC
+
+/* Just use a linked list. Do not expect more than 32 dlm_device_entries
+ * the first implementation will just use one device per cluster file system
+ */
+
+static LIST_HEAD(dlm_device_list);
+static DEFINE_SPINLOCK(dlm_device_list_lock);
+
+struct dlm_device_entry {
+	struct list_head	dlm_dev_list;
+	char			disk_name[DISK_NAME_LEN];
+	int			num_ds;
+	char			ds_list[NFSD_DLM_DS_LIST_MAX];
+};
+
+static struct dlm_device_entry *
+nfsd4_find_pnfs_dlm_device(char *disk_name)
+{
+	struct dlm_device_entry *dlm_pdev;
+
+	spin_lock(&dlm_device_list_lock);
+	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list) {
+		if (memcmp(dlm_pdev->disk_name, disk_name, strlen(disk_name))) {
+			spin_unlock(&dlm_device_list_lock);
+			return dlm_pdev;
+		}
+	}
+	spin_unlock(&dlm_device_list_lock);
+	return NULL;
+}
+
+/*
+ * pnfs_dlm_device string format:
+ *     block-device-path:<ds1 ipv4 address>,<ds2 ipv4 address>
+ *
+ * Examples
+ *     /dev/sda:192.168.1.96,192.168.1.97' creates a data server list with
+ *     two data servers for the dlm cluster file system mounted on /dev/sda.
+ *
+ *     /dev/sda:192.168.1.96,192.168.1.100'
+ *     replaces the data server list for /dev/sda
+ *
+ *     Only the deviceid == 1 is supported. Can add device id to
+ *     pnfs_dlm_device string when needed.
+ *
+ *     Only the round robin each data server once stripe index is supported.
+ */
+int
+nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
+
+{
+	struct dlm_device_entry *new, *found;
+	char *bufp = pnfs_dlm_device;
+	char *endp = bufp + strlen(bufp);
+	int err = -ENOMEM;
+
+	dprintk("--> %s len %d\n", __func__, len);
+
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return err;
+
+	err = -EINVAL;
+	/* disk_name */
+	/* FIXME: need to check for valid disk_name. search superblocks?
+	 * check for slash dev slash ?
+	 */
+	len = strcspn(bufp, ":");
+	if (len > DISK_NAME_LEN)
+		goto out_free;
+	memcpy(new->disk_name, bufp, len);
+
+	err = -EINVAL;
+	bufp += len + 1;
+	if (bufp >= endp)
+		goto out_free;
+
+	/* data server list */
+	/* FIXME: need to check for comma separated valid ip format */
+	len = strcspn(bufp, ":");
+	if (len > NFSD_DLM_DS_LIST_MAX)
+		goto out_free;
+	memcpy(new->ds_list, bufp, len);
+
+	/* count the number of comma-delimited DS IPs */
+	new->num_ds = 1;
+	while ((bufp = strchr(bufp, ',')) != NULL) {
+		new->num_ds++;
+		bufp++;
+	}
+
+	dprintk("%s disk_name %s num_ds %d ds_list %s\n", __func__,
+		new->disk_name, new->num_ds, new->ds_list);
+
+	found = nfsd4_find_pnfs_dlm_device(new->disk_name);
+	if (found) {
+		/* FIXME: should compare found->ds_list with new->ds_list
+		 * and if it is different, kick off a CB_NOTIFY change
+		 * deviceid.
+		 */
+		dprintk("%s pnfs_dlm_device %s:%s already in cache "
+			" replace ds_list with new ds_list %s\n", __func__,
+			found->disk_name, found->ds_list, new->ds_list);
+		memset(found->ds_list, 0, DISK_NAME_LEN);
+		memcpy(found->ds_list, new->ds_list, strlen(new->ds_list));
+		kfree(new);
+	} else {
+		dprintk("%s Adding pnfs_dlm_device %s:%s\n", __func__,
+				new->disk_name, new->ds_list);
+		spin_lock(&dlm_device_list_lock);
+		list_add(&new->dlm_dev_list, &dlm_device_list);
+		spin_unlock(&dlm_device_list_lock);
+	}
+	dprintk("<-- %s Success\n", __func__);
+	return 0;
+
+out_free:
+	kfree(new);
+	dprintk("<-- %s returns %d\n", __func__, err);
+	return err;
+}
+
+void nfsd4_pnfs_dlm_shutdown(void)
+{
+	struct dlm_device_entry *dlm_pdev;
+
+	dprintk("--> %s\n", __func__);
+
+	spin_lock(&dlm_device_list_lock);
+	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list) {
+		list_del(&dlm_pdev->dlm_dev_list);
+		kfree(dlm_pdev);
+	}
+	spin_unlock(&dlm_device_list_lock);
+}
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0415680..a44c1c2 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -14,6 +14,7 @@
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/nfsd/nfs4pnfsdlm.h>
 
 #include "nfsd.h"
 #include "cache.h"
@@ -1404,6 +1405,7 @@ out_free_stat:
 static void __exit exit_nfsd(void)
 {
 	nfsd_export_shutdown();
+	nfsd4_pnfs_dlm_shutdown();
 	nfsd_reply_cache_shutdown();
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
diff --git a/include/linux/nfsd/nfs4pnfsdlm.h b/include/linux/nfsd/nfs4pnfsdlm.h
new file mode 100644
index 0000000..63248aa
--- /dev/null
+++ b/include/linux/nfsd/nfs4pnfsdlm.h
@@ -0,0 +1,49 @@
+/******************************************************************************
+ *
+ * (c) 2007 Network Appliance, Inc.  All Rights Reserved.
+ * (c) 2009 NetApp.  All Rights Reserved.
+ *
+ * NetApp provides this source code under the GPL v2 License.
+ * The GPL v2 license is available at
+ * http://opensource.org/licenses/gpl-license.php.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+ * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+ * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+ * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+ * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ ******************************************************************************/
+#include <linux/genhd.h>
+
+/*
+ * Length of comma separated pnfs data server IPv4 addresses. Enough room for
+ * 32 addresses.
+ */
+#define NFSD_DLM_DS_LIST_MAX   512
+/*
+ * Length of colon separated pnfs dlm device of the form
+ * disk_name:comma separated data server IPv4 address
+ */
+#define NFSD_PNFS_DLM_DEVICE_MAX (NFSD_DLM_DS_LIST_MAX + DISK_NAME_LEN + 1)
+
+#ifdef CONFIG_PNFSD
+
+int nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len);
+
+void nfsd4_pnfs_dlm_shutdown(void);
+
+#else /* CONFIG_PNFSD */
+
+static inline void nfsd4_pnfs_dlm_shutdown(void)
+{
+	return;
+}
+
+#endif /* CONFIG_PNFSD */
-- 
1.6.5.1

