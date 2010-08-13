Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13703 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab0HMVcT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:19 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 17/50] pnfs_submit: filelayout getdeviceinfo
Date: Fri, 13 Aug 2010 17:31:29 -0400
Message-Id: <1281735122-1496-18-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-17-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h    |    6 +
 fs/nfs/nfs4filelayoutdev.c |  243 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 249 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 39dcdba..be3c9fe 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -20,6 +20,9 @@
 #define NFS4_PNFS_DEV_HASH_SIZE (1 << NFS4_PNFS_DEV_HASH_BITS)
 #define NFS4_PNFS_DEV_HASH_MASK (NFS4_PNFS_DEV_HASH_SIZE - 1)
 
+#define NFS4_PNFS_MAX_STRIPE_CNT 4096
+#define NFS4_PNFS_MAX_MULTI_CNT  64 /* 256 fit into a u8 stripe_index */
+
 /* Individual ip address */
 struct nfs4_pnfs_ds {
 	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
@@ -46,4 +49,7 @@ extern void print_ds(struct nfs4_pnfs_ds *ds);
 char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
 extern struct nfs4_file_layout_dsaddr *
 nfs4_pnfs_device_item_find(struct nfs_client *, struct pnfs_deviceid *dev_id);
+struct nfs4_file_layout_dsaddr *
+get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id);
+
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 0da1510..f7614f6 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -200,6 +200,249 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 	}
 }
 
+static struct nfs4_pnfs_ds *
+decode_and_add_ds(uint32_t **pp, struct inode *inode)
+{
+	struct nfs4_pnfs_ds *ds = NULL;
+	char r_addr[29]; /* max size of ip/port string */
+	int len;
+	u32 ip_addr, port;
+	int tmp[6];
+	uint32_t *p = *pp;
+
+	dprintk("%s enter\n", __func__);
+	/* check and skip r_netid */
+	len = be32_to_cpup(p++);
+	/* "tcp" */
+	if (len != 3) {
+		printk("%s: ERROR: non TCP r_netid len %d\n",
+			__func__, len);
+		goto out_err;
+	}
+	/*
+	 * Read the bytes into a temporary buffer
+	 * XXX: should probably sanity check them
+	 */
+	tmp[0] = be32_to_cpup(p++);
+
+	len = be32_to_cpup(p++);
+	if (len >= sizeof(r_addr)) {
+		printk("%s: ERROR: Device ip/port too long (%d)\n",
+			__func__, len);
+		goto out_err;
+	}
+	memcpy(r_addr, p, len);
+	p += XDR_QUADLEN(len);
+	*pp = p;
+	r_addr[len] = '\0';
+	sscanf(r_addr, "%d.%d.%d.%d.%d.%d", &tmp[0], &tmp[1],
+	       &tmp[2], &tmp[3], &tmp[4], &tmp[5]);
+	ip_addr = htonl((tmp[0]<<24) | (tmp[1]<<16) | (tmp[2]<<8) | (tmp[3]));
+	port = htons((tmp[4] << 8) | (tmp[5]));
+
+	nfs4_pnfs_ds_add(inode, &ds, ip_addr, port, r_addr, len);
+
+	dprintk("%s: addr:port string = %s\n", __func__, r_addr);
+	return ds;
+out_err:
+	dprintk("%s returned NULL\n", __func__);
+	return NULL;
+}
+
+/* Decode opaque device data and return the result */
+static struct nfs4_file_layout_dsaddr*
+decode_device(struct inode *ino, struct pnfs_device *pdev)
+{
+	int i, dummy;
+	u32 cnt, num;
+	u8 *indexp;
+	uint32_t *p = (u32 *)pdev->area, *indicesp;
+	struct nfs4_file_layout_dsaddr *dsaddr;
+
+	/* Get the stripe count (number of stripe index) */
+	cnt = be32_to_cpup(p++);
+	dprintk("%s stripe count  %d\n", __func__, cnt);
+	if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
+		printk(KERN_WARNING "%s: stripe count %d greater than "
+		       "supported maximum %d\n", __func__,
+			cnt, NFS4_PNFS_MAX_STRIPE_CNT);
+		goto out_err;
+	}
+
+	/* Check the multipath list count */
+	indicesp = p;
+	p += XDR_QUADLEN(cnt << 2);
+	num = be32_to_cpup(p++);
+	dprintk("%s ds_num %u\n", __func__, num);
+	if (num > NFS4_PNFS_MAX_MULTI_CNT) {
+		printk(KERN_WARNING "%s: multipath count %d greater than "
+			"supported maximum %d\n", __func__,
+			num, NFS4_PNFS_MAX_MULTI_CNT);
+		goto out_err;
+	}
+	dsaddr = kzalloc(sizeof(*dsaddr) +
+			(sizeof(struct nfs4_pnfs_ds *) * (num - 1)),
+			GFP_KERNEL);
+	if (!dsaddr)
+		goto out_err;
+
+	dsaddr->stripe_indices = kzalloc(sizeof(u8) * cnt, GFP_KERNEL);
+	if (!dsaddr->stripe_indices)
+		goto out_err_free;
+
+	dsaddr->stripe_count = cnt;
+	dsaddr->ds_num = num;
+
+	memcpy(&dsaddr->deviceid.de_id, &pdev->dev_id,
+	       NFS4_PNFS_DEVICEID4_SIZE);
+
+	/* Go back an read stripe indices */
+	p = indicesp;
+	indexp = &dsaddr->stripe_indices[0];
+	for (i = 0; i < dsaddr->stripe_count; i++) {
+		dummy = be32_to_cpup(p++);
+		*indexp = dummy; /* bound by NFS4_PNFS_MAX_MULTI_CNT */
+		indexp++;
+	}
+	/* Skip already read multipath list count */
+	p++;
+
+	for (i = 0; i < dsaddr->ds_num; i++) {
+		int j;
+
+		dummy = be32_to_cpup(p++); /* multipath count */
+		if (dummy > 1) {
+			printk(KERN_WARNING
+			       "%s: Multipath count %d not supported, "
+			       "skipping all greater than 1\n", __func__,
+				dummy);
+		}
+		for (j = 0; j < dummy; j++) {
+			if (j == 0) {
+				dsaddr->ds_list[i] = decode_and_add_ds(&p, ino);
+				if (dsaddr->ds_list[i] == NULL)
+					goto out_err_free;
+			} else {
+				u32 len;
+				/* skip extra multipath */
+				len = be32_to_cpup(p++);
+				p += XDR_QUADLEN(len);
+				len = be32_to_cpup(p++);
+				p += XDR_QUADLEN(len);
+				continue;
+			}
+		}
+	}
+	nfs4_init_deviceid_node(&dsaddr->deviceid);
+
+	return dsaddr;
+
+out_err_free:
+	nfs4_fl_free_deviceid(dsaddr);
+out_err:
+	dprintk("%s ERROR: returning NULL\n", __func__);
+	return NULL;
+}
+
+/*
+ * Decode the opaque device specified in 'dev'
+ * and add it to the list of available devices.
+ * If the deviceid is already cached, nfs4_add_deviceid will return
+ * a pointer to the cached struct and throw away the new.
+ */
+static struct nfs4_file_layout_dsaddr*
+decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
+{
+	struct nfs4_file_layout_dsaddr *dsaddr;
+	struct nfs4_deviceid *d;
+
+	dsaddr = decode_device(inode, dev);
+	if (!dsaddr) {
+		printk(KERN_WARNING "%s: Could not decode or add device\n",
+			__func__);
+		return NULL;
+	}
+
+	d = nfs4_add_deviceid(NFS_SERVER(inode)->nfs_client->cl_devid_cache,
+			      &dsaddr->deviceid);
+
+	return container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
+}
+
+/*
+ * Retrieve the information for dev_id, add it to the list
+ * of available devices, and return it.
+ */
+struct nfs4_file_layout_dsaddr *
+get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id)
+{
+	struct pnfs_device *pdev = NULL;
+	u32 max_resp_sz;
+	int max_pages;
+	struct page **pages = NULL;
+	struct nfs4_file_layout_dsaddr *dsaddr = NULL;
+	int rc, i;
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	/*
+	 * Use the session max response size as the basis for setting
+	 * GETDEVICEINFO's maxcount
+	 */
+	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
+	max_pages = max_resp_sz >> PAGE_SHIFT;
+	dprintk("%s inode %p max_resp_sz %u max_pages %d\n",
+		__func__, inode, max_resp_sz, max_pages);
+
+	pdev = kzalloc(sizeof(struct pnfs_device), GFP_KERNEL);
+	if (pdev == NULL)
+		return NULL;
+
+	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
+	if (pages == NULL) {
+		kfree(pdev);
+		return NULL;
+	}
+	for (i = 0; i < max_pages; i++) {
+		pages[i] = alloc_page(GFP_KERNEL);
+		if (!pages[i])
+			goto out_free;
+	}
+
+	/* set pdev->area */
+	pdev->area = vmap(pages, max_pages, VM_MAP, PAGE_KERNEL);
+	if (!pdev->area)
+		goto out_free;
+
+	memcpy(&pdev->dev_id, dev_id, NFS4_PNFS_DEVICEID4_SIZE);
+	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
+	pdev->pages = pages;
+	pdev->pgbase = 0;
+	pdev->pglen = PAGE_SIZE * max_pages;
+	pdev->mincount = 0;
+	/* TODO: Update types when CB_NOTIFY_DEVICEID is available */
+	pdev->dev_notify_types = 0;
+
+	rc = pnfs_callback_ops->nfs_getdeviceinfo(server, pdev);
+	dprintk("%s getdevice info returns %d\n", __func__, rc);
+	if (rc)
+		goto out_free;
+
+	/*
+	 * Found new device, need to decode it and then add it to the
+	 * list of known devices for this mountpoint.
+	 */
+	dsaddr = decode_and_add_device(inode, pdev);
+out_free:
+	if (pdev->area != NULL)
+		vunmap(pdev->area);
+	for (i = 0; i < max_pages; i++)
+		__free_page(pages[i]);
+	kfree(pages);
+	kfree(pdev);
+	dprintk("<-- %s dsaddr %p\n", __func__, dsaddr);
+	return dsaddr;
+}
+
 struct nfs4_file_layout_dsaddr *
 nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
 {
-- 
1.6.2.5

