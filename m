Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30726 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756204Ab0JOGRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:43 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/12] RFC: pnfs: filelayout: add driver's LAYOUTGET and GETDEVICEINFO infrastructure
Date: Sun, 10 Oct 2010 11:22:53 -0400
Message-Id: <1286724173-8493-13-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Implement the driver's io_ops->alloc_lseg and free_lseg functions,
which integrate into the deviceid cache and calls out to
nfs4_proc_getdeviceinfo when necessary.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/Makefile            |    2 +-
 fs/nfs/client.c            |    1 +
 fs/nfs/nfs4filelayout.c    |  204 ++++++++++++++++++++-
 fs/nfs/nfs4filelayout.h    |   94 +++++++++
 fs/nfs/nfs4filelayoutdev.c |  448 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 747 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/nfs4filelayout.h
 create mode 100644 fs/nfs/nfs4filelayoutdev.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 08a8889..4776ff9 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -20,4 +20,4 @@ nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
-nfs_layout_nfsv41_files-y := nfs4filelayout.o
+nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 893ba83..fe6189c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -255,6 +255,7 @@ void nfs_put_client(struct nfs_client *clp)
 		nfs_free_client(clp);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_put_client);
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /*
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 696e283..9e82b51 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -30,7 +30,9 @@
  */
 
 #include <linux/nfs_fs.h>
-#include "pnfs.h"
+
+#include "internal.h"
+#include "nfs4filelayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -41,23 +43,223 @@ MODULE_DESCRIPTION("The NFSv4 file layout driver");
 int
 filelayout_initialize_mountpoint(struct nfs_server *nfss)
 {
+	int status = pnfs_alloc_init_deviceid_cache(nfss->nfs_client,
+						nfs4_fl_free_deviceid_callback);
+	if (status) {
+		printk(KERN_WARNING "%s: deviceid cache could not be "
+			"initialized\n", __func__);
+		return status;
+	}
+	dprintk("%s: deviceid cache has been initialized successfully\n",
+		__func__);
 	return 0;
 }
 
+/* Uninitialize a mountpoint by destroying its device list */
 int
 filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
 {
 	dprintk("--> %s\n", __func__);
 
+	if (nfss->nfs_client->cl_devid_cache)
+		pnfs_put_deviceid_cache(nfss->nfs_client);
 	return 0;
 }
 
+/*
+ * filelayout_check_layout()
+ *
+ * Make sure layout segment parameters are sane WRT the device.
+ * At this point no generic layer initialization of the lseg has occurred,
+ * and nothing has been added to the layout_hdr cache.
+ *
+ */
+static int
+filelayout_check_layout(struct pnfs_layout_hdr *lo,
+			struct nfs4_filelayout_segment *fl,
+			struct nfs4_layoutget_res *lgr,
+			struct nfs4_deviceid *id)
+{
+	struct nfs4_file_layout_dsaddr *dsaddr;
+	int status = -EINVAL;
+	struct nfs_server *nfss = NFS_SERVER(lo->inode);
+
+	dprintk("--> %s\n", __func__);
+
+	if (fl->pattern_offset > lgr->range.offset) {
+		dprintk("%s pattern_offset %lld to large\n",
+				__func__, fl->pattern_offset);
+		goto out;
+	}
+
+	if (fl->stripe_unit % PAGE_SIZE) {
+		dprintk("%s Stripe unit (%u) not page aligned\n",
+			__func__, fl->stripe_unit);
+		goto out;
+	}
+
+	/* find and reference the deviceid */
+	dsaddr = nfs4_fl_find_get_deviceid(nfss->nfs_client, id);
+	if (dsaddr == NULL) {
+		dsaddr = get_device_info(lo->inode, id);
+		if (dsaddr == NULL)
+			goto out;
+	}
+	fl->dsaddr = dsaddr;
+
+	if (fl->first_stripe_index < 0 ||
+	    fl->first_stripe_index >= dsaddr->stripe_count) {
+		dprintk("%s Bad first_stripe_index %d\n",
+				__func__, fl->first_stripe_index);
+		goto out_put;
+	}
+
+	if ((fl->stripe_type == STRIPE_SPARSE &&
+	    fl->num_fh > 1 && fl->num_fh != dsaddr->ds_num) ||
+	    (fl->stripe_type == STRIPE_DENSE &&
+	    fl->num_fh != dsaddr->stripe_count)) {
+		dprintk("%s num_fh %u not valid for given packing\n",
+			__func__, fl->num_fh);
+		goto out_put;
+	}
+
+	if (fl->stripe_unit % nfss->rsize || fl->stripe_unit % nfss->wsize) {
+		dprintk("%s Stripe unit (%u) not aligned with rsize %u "
+			"wsize %u\n", __func__, fl->stripe_unit, nfss->rsize,
+			nfss->wsize);
+	}
+
+	status = 0;
+out:
+	dprintk("--> %s returns %d\n", __func__, status);
+	return status;
+out_put:
+	pnfs_put_deviceid(nfss->nfs_client->cl_devid_cache, &dsaddr->deviceid);
+	goto out;
+}
+
+static void filelayout_free_fh_array(struct nfs4_filelayout_segment *fl)
+{
+	int i;
+
+	for (i = 0; i < fl->num_fh; i++) {
+		if (!fl->fh_array[i])
+			break;
+		kfree(fl->fh_array[i]);
+	}
+	kfree(fl->fh_array);
+	fl->fh_array = NULL;
+}
+
+static void
+_filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
+{
+	filelayout_free_fh_array(fl);
+	kfree(fl);
+}
+
+static int
+filelayout_decode_layout(struct pnfs_layout_hdr *flo,
+			 struct nfs4_filelayout_segment *fl,
+			 struct nfs4_layoutget_res *lgr,
+			 struct nfs4_deviceid *id)
+{
+	uint32_t *p = (uint32_t *)lgr->layout.buf;
+	uint32_t nfl_util;
+	int i;
+
+	dprintk("%s: set_layout_map Begin\n", __func__);
+
+	memcpy(id, p, sizeof(*id));
+	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
+	print_deviceid(id);
+
+	nfl_util = be32_to_cpup(p++);
+	if (nfl_util & NFL4_UFLG_COMMIT_THRU_MDS)
+		fl->commit_through_mds = 1;
+	if (nfl_util & NFL4_UFLG_DENSE)
+		fl->stripe_type = STRIPE_DENSE;
+	else
+		fl->stripe_type = STRIPE_SPARSE;
+	fl->stripe_unit = nfl_util & ~NFL4_UFLG_MASK;
+
+	fl->first_stripe_index = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &fl->pattern_offset);
+	fl->num_fh = be32_to_cpup(p++);
+
+	dprintk("%s: nfl_util 0x%X num_fh %u fsi %u po %llu\n",
+		__func__, nfl_util, fl->num_fh, fl->first_stripe_index,
+		fl->pattern_offset);
+
+	fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
+			       GFP_KERNEL);
+	if (!fl->fh_array)
+		return -ENOMEM;
+
+	for (i = 0; i < fl->num_fh; i++) {
+		/* Do we want to use a mempool here? */
+		fl->fh_array[i] = kmalloc(sizeof(struct nfs_fh), GFP_KERNEL);
+		if (!fl->fh_array[i]) {
+			filelayout_free_fh_array(fl);
+			return -ENOMEM;
+		}
+		fl->fh_array[i]->size = be32_to_cpup(p++);
+		if (sizeof(struct nfs_fh) < fl->fh_array[i]->size) {
+			printk(KERN_ERR "Too big fh %d received %d\n",
+			       i, fl->fh_array[i]->size);
+			filelayout_free_fh_array(fl);
+			return -EIO;
+		}
+		memcpy(fl->fh_array[i]->data, p, fl->fh_array[i]->size);
+		p += XDR_QUADLEN(fl->fh_array[i]->size);
+		dprintk("DEBUG: %s: fh len %d\n", __func__,
+			fl->fh_array[i]->size);
+	}
+
+	return 0;
+}
+
+static struct pnfs_layout_segment *
+filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
+		      struct nfs4_layoutget_res *lgr)
+{
+	struct nfs4_filelayout_segment *fl;
+	int rc;
+	struct nfs4_deviceid id;
+
+	dprintk("--> %s\n", __func__);
+	fl = kzalloc(sizeof(*fl), GFP_KERNEL);
+	if (!fl)
+		return NULL;
+
+	rc = filelayout_decode_layout(layoutid, fl, lgr, &id);
+	if (rc != 0 || filelayout_check_layout(layoutid, fl, lgr, &id)) {
+		_filelayout_free_lseg(fl);
+		return NULL;
+	}
+	return &fl->generic_hdr;
+}
+
+static void
+filelayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct nfs_server *nfss = NFS_SERVER(lseg->layout->inode);
+	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+
+	dprintk("--> %s\n", __func__);
+	pnfs_put_deviceid(nfss->nfs_client->cl_devid_cache,
+			  &fl->dsaddr->deviceid);
+	_filelayout_free_lseg(fl);
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id = LAYOUT_NFSV4_1_FILES,
 	.name = "LAYOUT_NFSV4_1_FILES",
 	.owner = THIS_MODULE,
 	.initialize_mountpoint   = filelayout_initialize_mountpoint,
 	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
+	.alloc_lseg              = filelayout_alloc_lseg,
+	.free_lseg               = filelayout_free_lseg,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
new file mode 100644
index 0000000..bbf60dd
--- /dev/null
+++ b/fs/nfs/nfs4filelayout.h
@@ -0,0 +1,94 @@
+/*
+ *  NFSv4 file layout driver data structures.
+ *
+ *  Copyright (c) 2002
+ *  The Regents of the University of Michigan
+ *  All Rights Reserved
+ *
+ *  Dean Hildebrand <dhildebz@umich.edu>
+ *
+ *  Permission is granted to use, copy, create derivative works, and
+ *  redistribute this software and such derivative works for any purpose,
+ *  so long as the name of the University of Michigan is not used in
+ *  any advertising or publicity pertaining to the use or distribution
+ *  of this software without specific, written prior authorization. If
+ *  the above copyright notice or any other identification of the
+ *  University of Michigan is included in any copy of any portion of
+ *  this software, then the disclaimer below must also be included.
+ *
+ *  This software is provided as is, without representation or warranty
+ *  of any kind either express or implied, including without limitation
+ *  the implied warranties of merchantability, fitness for a particular
+ *  purpose, or noninfringement.  The Regents of the University of
+ *  Michigan shall not be liable for any damages, including special,
+ *  indirect, incidental, or consequential damages, with respect to any
+ *  claim arising out of or in connection with the use of the software,
+ *  even if it has been or is hereafter advised of the possibility of
+ *  such damages.
+ */
+
+#ifndef FS_NFS_NFS4FILELAYOUT_H
+#define FS_NFS_NFS4FILELAYOUT_H
+
+#include "pnfs.h"
+
+/*
+ * Field testing shows we need to support upto 4096 stripe indices.
+ * We store each index as a u8 (u32 on the wire) to keep the memory footprint
+ * reasonable. This in turn means we support a maximum of 256
+ * RFC 5661 multipath_list4 structures.
+ */
+#define NFS4_PNFS_MAX_STRIPE_CNT 4096
+#define NFS4_PNFS_MAX_MULTI_CNT  256 /* 256 fit into a u8 stripe_index */
+
+enum stripetype4 {
+	STRIPE_SPARSE = 1,
+	STRIPE_DENSE = 2
+};
+
+/* Individual ip address */
+struct nfs4_pnfs_ds {
+	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
+	u32			ds_ip_addr;
+	u32			ds_port;
+	struct nfs_client	*ds_clp;
+	atomic_t		ds_count;
+};
+
+struct nfs4_file_layout_dsaddr {
+	struct pnfs_deviceid_node	deviceid;
+	u32				stripe_count;
+	u8				*stripe_indices;
+	u32				ds_num;
+	struct nfs4_pnfs_ds		*ds_list[1];
+};
+
+struct nfs4_filelayout_segment {
+	struct pnfs_layout_segment generic_hdr;
+	u32 stripe_type;
+	u32 commit_through_mds;
+	u32 stripe_unit;
+	u32 first_stripe_index;
+	u64 pattern_offset;
+	struct nfs4_file_layout_dsaddr *dsaddr; /* Point to GETDEVINFO data */
+	unsigned int num_fh;
+	struct nfs_fh **fh_array;
+};
+
+static inline struct nfs4_filelayout_segment *
+FILELAYOUT_LSEG(struct pnfs_layout_segment *lseg)
+{
+	return container_of(lseg,
+			    struct nfs4_filelayout_segment,
+			    generic_hdr);
+}
+
+extern void nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *);
+extern void print_ds(struct nfs4_pnfs_ds *ds);
+extern void print_deviceid(struct nfs4_deviceid *dev_id);
+extern struct nfs4_file_layout_dsaddr *
+nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
+struct nfs4_file_layout_dsaddr *
+get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id);
+
+#endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
new file mode 100644
index 0000000..51fe64a
--- /dev/null
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -0,0 +1,448 @@
+/*
+ *  Device operations for the pnfs nfs4 file layout driver.
+ *
+ *  Copyright (c) 2002
+ *  The Regents of the University of Michigan
+ *  All Rights Reserved
+ *
+ *  Dean Hildebrand <dhildebz@umich.edu>
+ *  Garth Goodson   <Garth.Goodson@netapp.com>
+ *
+ *  Permission is granted to use, copy, create derivative works, and
+ *  redistribute this software and such derivative works for any purpose,
+ *  so long as the name of the University of Michigan is not used in
+ *  any advertising or publicity pertaining to the use or distribution
+ *  of this software without specific, written prior authorization. If
+ *  the above copyright notice or any other identification of the
+ *  University of Michigan is included in any copy of any portion of
+ *  this software, then the disclaimer below must also be included.
+ *
+ *  This software is provided as is, without representation or warranty
+ *  of any kind either express or implied, including without limitation
+ *  the implied warranties of merchantability, fitness for a particular
+ *  purpose, or noninfringement.  The Regents of the University of
+ *  Michigan shall not be liable for any damages, including special,
+ *  indirect, incidental, or consequential damages, with respect to any
+ *  claim arising out of or in connection with the use of the software,
+ *  even if it has been or is hereafter advised of the possibility of
+ *  such damages.
+ */
+
+#include <linux/nfs_fs.h>
+#include <linux/vmalloc.h>
+
+#include "internal.h"
+#include "nfs4filelayout.h"
+
+#define NFSDBG_FACILITY		NFSDBG_PNFS_LD
+
+/*
+ * Data server cache
+ *
+ * Data servers can be mapped to different device ids.
+ * nfs4_pnfs_ds reference counting
+ *   - set to 1 on allocation
+ *   - incremented when a device id maps a data server already in the cache.
+ *   - decremented when deviceid is removed from the cache.
+ */
+DEFINE_SPINLOCK(nfs4_ds_cache_lock);
+static LIST_HEAD(nfs4_data_server_cache);
+
+/* Debug routines */
+void
+print_ds(struct nfs4_pnfs_ds *ds)
+{
+	if (ds == NULL) {
+		printk("%s NULL device\n", __func__);
+		return;
+	}
+	printk("        ip_addr %x port %hu\n"
+		"        ref count %d\n"
+		"        client %p\n"
+		"        cl_exchange_flags %x\n",
+		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
+		atomic_read(&ds->ds_count), ds->ds_clp,
+		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
+}
+
+void
+print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
+{
+	int i;
+
+	ifdebug(FACILITY) {
+		printk("%s dsaddr->ds_num %d\n", __func__,
+		       dsaddr->ds_num);
+		for (i = 0; i < dsaddr->ds_num; i++)
+			print_ds(dsaddr->ds_list[i]);
+	}
+}
+
+void print_deviceid(struct nfs4_deviceid *id)
+{
+	u32 *p = (u32 *)id;
+
+	dprintk("%s: device id= [%x%x%x%x]\n", __func__,
+		p[0], p[1], p[2], p[3]);
+}
+
+/* nfs4_ds_cache_lock is held */
+static struct nfs4_pnfs_ds *
+_data_server_lookup_locked(u32 ip_addr, u32 port)
+{
+	struct nfs4_pnfs_ds *ds;
+
+	dprintk("_data_server_lookup: ip_addr=%x port=%hu\n",
+			ntohl(ip_addr), ntohs(port));
+
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
+		if (ds->ds_ip_addr == ip_addr &&
+		    ds->ds_port == port) {
+			return ds;
+		}
+	}
+	return NULL;
+}
+
+static void
+destroy_ds(struct nfs4_pnfs_ds *ds)
+{
+	dprintk("--> %s\n", __func__);
+	ifdebug(FACILITY)
+		print_ds(ds);
+
+	if (ds->ds_clp)
+		nfs_put_client(ds->ds_clp);
+	kfree(ds);
+}
+
+static void
+nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
+{
+	struct nfs4_pnfs_ds *ds;
+	int i;
+
+	print_deviceid(&dsaddr->deviceid.de_id);
+
+	for (i = 0; i < dsaddr->ds_num; i++) {
+		ds = dsaddr->ds_list[i];
+		if (ds != NULL) {
+			if (atomic_dec_and_lock(&ds->ds_count,
+						&nfs4_ds_cache_lock)) {
+				list_del_init(&ds->ds_node);
+				spin_unlock(&nfs4_ds_cache_lock);
+				destroy_ds(ds);
+			}
+		}
+	}
+	kfree(dsaddr->stripe_indices);
+	kfree(dsaddr);
+}
+
+void
+nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *device)
+{
+	struct nfs4_file_layout_dsaddr *dsaddr =
+		container_of(device, struct nfs4_file_layout_dsaddr, deviceid);
+
+	nfs4_fl_free_deviceid(dsaddr);
+}
+
+static struct nfs4_pnfs_ds *
+nfs4_pnfs_ds_add(struct inode *inode, u32 ip_addr, u32 port)
+{
+	struct nfs4_pnfs_ds *tmp_ds, *ds;
+
+	ds = kzalloc(sizeof(*tmp_ds), GFP_KERNEL);
+	if (!ds)
+		goto out;
+
+	spin_lock(&nfs4_ds_cache_lock);
+	tmp_ds = _data_server_lookup_locked(ip_addr, port);
+	if (tmp_ds == NULL) {
+		ds->ds_ip_addr = ip_addr;
+		ds->ds_port = port;
+		atomic_set(&ds->ds_count, 1);
+		INIT_LIST_HEAD(&ds->ds_node);
+		ds->ds_clp = NULL;
+		list_add(&ds->ds_node, &nfs4_data_server_cache);
+		dprintk("%s add new data server ip 0x%x\n", __func__,
+			ds->ds_ip_addr);
+	} else {
+		kfree(ds);
+		atomic_inc(&tmp_ds->ds_count);
+		dprintk("%s data server found ip 0x%x, inc'ed ds_count to %d\n",
+			__func__, tmp_ds->ds_ip_addr,
+			atomic_read(&tmp_ds->ds_count));
+		ds = tmp_ds;
+	}
+	spin_unlock(&nfs4_ds_cache_lock);
+out:
+	return ds;
+}
+
+/*
+ * Currently only support ipv4, and one multi-path address.
+ */
+static struct nfs4_pnfs_ds *
+decode_and_add_ds(__be32 **pp, struct inode *inode)
+{
+	struct nfs4_pnfs_ds *ds = NULL;
+	char *buf;
+	const char *ipend, *pstr;
+	u32 ip_addr, port;
+	int nlen, rlen, i;
+	int tmp[2];
+	__be32 *r_netid, *r_addr, *p = *pp;
+
+	/* r_netid */
+	nlen = be32_to_cpup(p++);
+	r_netid = p;
+	p += XDR_QUADLEN(nlen);
+
+	/* r_addr */
+	rlen = be32_to_cpup(p++);
+	r_addr = p;
+	p += XDR_QUADLEN(rlen);
+	*pp = p;
+
+	/* Check that netid is "tcp" */
+	if (nlen != 3 ||  memcmp((char *)r_netid, "tcp", 3)) {
+		dprintk("%s: ERROR: non ipv4 TCP r_netid\n", __func__);
+		goto out_err;
+	}
+
+	/* ipv6 length plus port is legal */
+	if (rlen > INET6_ADDRSTRLEN + 8) {
+		dprintk("%s Invalid address, length %d\n", __func__,
+			rlen);
+		goto out_err;
+	}
+	buf = kmalloc(rlen + 1, GFP_KERNEL);
+	buf[rlen] = '\0';
+	memcpy(buf, r_addr, rlen);
+
+	/* replace the port dots with dashes for the in4_pton() delimiter*/
+	for (i = 0; i < 2; i++) {
+		char *res = strrchr(buf, '.');
+		*res = '-';
+	}
+
+	/* Currently only support ipv4 address */
+	if (in4_pton(buf, rlen, (u8 *)&ip_addr, '-', &ipend) == 0) {
+		dprintk("%s: Only ipv4 addresses supported\n", __func__);
+		goto out_free;
+	}
+
+	/* port */
+	pstr = ipend;
+	sscanf(pstr, "-%d-%d", &tmp[0], &tmp[1]);
+	port = htons((tmp[0] << 8) | (tmp[1]));
+
+	ds = nfs4_pnfs_ds_add(inode, ip_addr, port);
+	dprintk("%s Decoded address and port %s\n", __func__, buf);
+out_free:
+	kfree(buf);
+out_err:
+	return ds;
+}
+
+/* Decode opaque device data and return the result */
+static struct nfs4_file_layout_dsaddr*
+decode_device(struct inode *ino, struct pnfs_device *pdev)
+{
+	int i, dummy;
+	u32 cnt, num;
+	u8 *indexp;
+	__be32 *p = (__be32 *)pdev->area, *indicesp;
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
+	memcpy(&dsaddr->deviceid.de_id, &pdev->dev_id, sizeof(pdev->dev_id));
+
+	/* Go back an read stripe indices */
+	p = indicesp;
+	indexp = &dsaddr->stripe_indices[0];
+	for (i = 0; i < dsaddr->stripe_count; i++) {
+		*indexp = be32_to_cpup(p++);
+		if (*indexp >= num)
+			goto out_err_free;
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
+	struct pnfs_deviceid_node *d;
+
+	dsaddr = decode_device(inode, dev);
+	if (!dsaddr) {
+		printk(KERN_WARNING "%s: Could not decode or add device\n",
+			__func__);
+		return NULL;
+	}
+
+	d = pnfs_add_deviceid(NFS_SERVER(inode)->nfs_client->cl_devid_cache,
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
+get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id)
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
+	memcpy(&pdev->dev_id, dev_id, sizeof(*dev_id));
+	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
+	pdev->pages = pages;
+	pdev->pgbase = 0;
+	pdev->pglen = PAGE_SIZE * max_pages;
+	pdev->mincount = 0;
+
+	rc = nfs4_proc_getdeviceinfo(server, pdev);
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
+struct nfs4_file_layout_dsaddr *
+nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
+{
+	struct pnfs_deviceid_node *d;
+
+	d = pnfs_find_get_deviceid(clp->cl_devid_cache, id);
+	return (d == NULL) ? NULL :
+		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
+}
-- 
1.7.2.1

