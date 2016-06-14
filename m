Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:36906 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbcFNUtw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 16:49:52 -0400
Received: by mail-it0-f51.google.com with SMTP id e5so4943094ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 13:49:52 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [V5 2/2] nfsd: Add a super simple flex file server
Date: Tue, 14 Jun 2016 13:41:28 -0700
Message-Id: <1465936888-103341-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1465936888-103341-1-git-send-email-loghyr@primarydata.com>
References: <1465936888-103341-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have a simple flex file server where the mds (NFSv4.1 or NFSv4.2)
is also the ds (NFSv3). I.e., the metadata and the data file are
the exact same file.

This will allow testing of the flex file client.

Simply add the "pnfs" export option to your export
in /etc/exports and mount from a client that supports
flex files.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/Kconfig             |  17 ++++++
 fs/nfsd/Makefile            |   1 +
 fs/nfsd/flexfilelayout.c    | 133 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.c | 115 ++++++++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.h |  49 ++++++++++++++++
 fs/nfsd/nfs4layouts.c       |  12 +++-
 fs/nfsd/pnfs.h              |   3 +
 7 files changed, 329 insertions(+), 1 deletion(-)
 create mode 100644 fs/nfsd/flexfilelayout.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.h

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index c9f583d..e64d1a3 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -111,6 +111,23 @@ config NFSD_SCSILAYOUT
 
 	  If unsure, say N.
 
+config NFSD_FLEXFILELAYOUT
+	bool "NFSv4.1 server support for pNFS Flex File layouts"
+	depends on NFSD_V4
+	select NFSD_PNFS
+	help
+	  This option enables support for the exporting pNFS Flex File
+	  layouts in the kernel's NFS server. The pNFS Flex File  layout
+	  enables NFS clients to directly perform I/O to NFSv3 devices
+	  accesible to both the server and the clients.  See
+	  draft-ietf-nfsv4-flex-files for more details.
+
+	  Warning, this server implements the bare minimum functionality
+	  to be a flex file server - it is for testing the client,
+	  not for use in production.
+
+	  If unsure, say N.
+
 config NFSD_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 server"
 	depends on NFSD_V4 && SECURITY
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 3ae5f3c..5f5d3a7 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -20,3 +20,4 @@ nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 nfsd-$(CONFIG_NFSD_PNFS) += nfs4layouts.o
 nfsd-$(CONFIG_NFSD_BLOCKLAYOUT) += blocklayout.o blocklayoutxdr.o
 nfsd-$(CONFIG_NFSD_SCSILAYOUT) += blocklayout.o blocklayoutxdr.o
+nfsd-$(CONFIG_NFSD_FLEXFILELAYOUT) += flexfilelayout.o flexfilelayoutxdr.o
diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
new file mode 100644
index 0000000..df880e9
--- /dev/null
+++ b/fs/nfsd/flexfilelayout.c
@@ -0,0 +1,133 @@
+/*
+ * Copyright (c) 2016 Tom Haynes <loghyr@primarydata.com>
+ *
+ * The following implements a super-simple flex-file server
+ * where the NFSv4.1 mds is also the ds. And the storage is
+ * the same. I.e., writing to the mds via a NFSv4.1 WRITE
+ * goes to the same location as the NFSv3 WRITE.
+ */
+#include <linux/slab.h>
+
+#include <linux/nfsd/debug.h>
+
+#include <linux/sunrpc/addr.h>
+
+#include "flexfilelayoutxdr.h"
+#include "pnfs.h"
+
+#define NFSDDBG_FACILITY	NFSDDBG_PNFS
+
+static __be32
+nfsd4_ff_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
+		struct nfsd4_layoutget *args)
+{
+	struct nfsd4_layout_seg *seg = &args->lg_seg;
+	u32 device_generation = 0;
+	int error;
+	uid_t u;
+
+	struct pnfs_ff_layout *fl;
+
+	/*
+	 * The super simple flex file server has 1 mirror, 1 data server,
+	 * and 1 file handle. So instead of 4 allocs, do 1 for now.
+	 * Zero it out for the stateid - don't want junk in there!
+	 */
+	error = -ENOMEM;
+	fl = kzalloc(sizeof(*fl), GFP_KERNEL);
+	if (!fl)
+		goto out_error;
+	args->lg_content = fl;
+
+	/*
+	 * Avoid layout commit, try to force the I/O to the DS,
+	 * and for fun, cause all IOMODE_RW layout segments to
+	 * effectively be WRITE only.
+	 */
+	fl->flags = FF_FLAGS_NO_LAYOUTCOMMIT | FF_FLAGS_NO_IO_THRU_MDS |
+		    FF_FLAGS_NO_READ_IO;
+
+	/* Do not allow a IOMODE_READ segment to have write pemissions */
+	if (seg->iomode == IOMODE_READ) {
+		u = from_kuid(&init_user_ns, inode->i_uid) + 1;
+		fl->uid = make_kuid(&init_user_ns, u);
+	} else
+		fl->uid = inode->i_uid;
+	fl->gid = inode->i_gid;
+
+	error = nfsd4_set_deviceid(&fl->deviceid, fhp, device_generation);
+	if (error)
+		goto out_error;
+
+	fl->fh.size = fhp->fh_handle.fh_size;
+	memcpy(fl->fh.data, &fhp->fh_handle.fh_base, fl->fh.size);
+
+	/* Give whole file layout segments */
+	seg->offset = 0;
+	seg->length = NFS4_MAX_UINT64;
+
+	dprintk("GET: 0x%llx:0x%llx %d\n", seg->offset, seg->length,
+		seg->iomode);
+	return 0;
+
+out_error:
+	seg->length = 0;
+	return nfserrno(error);
+}
+
+static __be32
+nfsd4_ff_proc_getdeviceinfo(struct super_block *sb, struct svc_rqst *rqstp,
+		struct nfs4_client *clp, struct nfsd4_getdeviceinfo *gdp)
+{
+	struct pnfs_ff_device_addr *da;
+
+	u16 port;
+	char addr[INET6_ADDRSTRLEN];
+
+	da = kzalloc(sizeof(struct pnfs_ff_device_addr), GFP_KERNEL);
+	if (!da)
+		return nfserrno(-ENOMEM);
+
+	gdp->gd_device = da;
+
+	da->version = 3;
+	da->minor_version = 0;
+
+	da->rsize = svc_max_payload(rqstp);
+	da->wsize = da->rsize;
+
+	rpc_ntop((struct sockaddr *)&rqstp->rq_daddr,
+		 addr, INET6_ADDRSTRLEN);
+	if (rqstp->rq_daddr.ss_family == AF_INET) {
+		struct sockaddr_in *sin;
+
+		sin = (struct sockaddr_in *)&rqstp->rq_daddr;
+		port = ntohs(sin->sin_port);
+		snprintf(da->netaddr.netid, FF_NETID_LEN + 1, "tcp");
+		da->netaddr.netid_len = 3;
+	} else {
+		struct sockaddr_in6 *sin6;
+
+		sin6 = (struct sockaddr_in6 *)&rqstp->rq_daddr;
+		port = ntohs(sin6->sin6_port);
+		snprintf(da->netaddr.netid, FF_NETID_LEN + 1, "tcp6");
+		da->netaddr.netid_len = 4;
+	}
+
+	da->netaddr.addr_len =
+		snprintf(da->netaddr.addr, FF_ADDR_LEN + 1,
+			 "%s.%hhu.%hhu", addr, port >> 8, port & 0xff);
+
+	da->tightly_coupled = false;
+
+	return 0;
+}
+
+const struct nfsd4_layout_ops ff_layout_ops = {
+	.notify_types		=
+			NOTIFY_DEVICEID4_DELETE | NOTIFY_DEVICEID4_CHANGE,
+	.proc_getdeviceinfo	= nfsd4_ff_proc_getdeviceinfo,
+	.encode_getdeviceinfo	= nfsd4_ff_encode_getdeviceinfo,
+	.proc_layoutget		= nfsd4_ff_proc_layoutget,
+	.encode_layoutget	= nfsd4_ff_encode_layoutget,
+};
diff --git a/fs/nfsd/flexfilelayoutxdr.c b/fs/nfsd/flexfilelayoutxdr.c
new file mode 100644
index 0000000..5e3fd7f
--- /dev/null
+++ b/fs/nfsd/flexfilelayoutxdr.c
@@ -0,0 +1,115 @@
+/*
+ * Copyright (c) 2016 Tom Haynes <loghyr@primarydata.com>
+ */
+#include <linux/sunrpc/svc.h>
+#include <linux/nfs4.h>
+
+#include "nfsd.h"
+#include "flexfilelayoutxdr.h"
+
+#define NFSDDBG_FACILITY	NFSDDBG_PNFS
+
+struct ff_idmap {
+	char buf[11];
+	int len;
+};
+
+__be32
+nfsd4_ff_encode_layoutget(struct xdr_stream *xdr,
+		struct nfsd4_layoutget *lgp)
+{
+	struct pnfs_ff_layout *fl = lgp->lg_content;
+	int len, mirror_len, ds_len, fh_len;
+	__be32 *p;
+
+	/*
+	 * Unlike nfsd4_encode_user, we know these will
+	 * always be stringified.
+	 */
+	struct ff_idmap uid;
+	struct ff_idmap gid;
+
+	fh_len = 4 + fl->fh.size;
+
+	uid.len = sprintf(uid.buf, "%u", from_kuid(&init_user_ns, fl->uid));
+	gid.len = sprintf(gid.buf, "%u", from_kgid(&init_user_ns, fl->gid));
+
+	/* 8 + len for recording the length, name, and padding */
+	ds_len = 20 + sizeof(stateid_opaque_t) + 4 + fh_len +
+		 8 + uid.len + 8 + gid.len;
+
+	mirror_len = 4 + ds_len;
+
+	/* The layout segment */
+	len = 20 + mirror_len;
+
+	p = xdr_reserve_space(xdr, sizeof(__be32) + len);
+	if (!p)
+		return nfserr_toosmall;
+
+	*p++ = cpu_to_be32(len);
+	p = xdr_encode_hyper(p, 0);		/* stripe unit of 1 */
+
+	*p++ = cpu_to_be32(1);			/* single mirror */
+	*p++ = cpu_to_be32(1);			/* single data server */
+
+	p = xdr_encode_opaque_fixed(p, &fl->deviceid,
+			sizeof(struct nfsd4_deviceid));
+
+	*p++ = cpu_to_be32(1);			/* efficiency */
+
+	*p++ = cpu_to_be32(fl->stateid.si_generation);
+	p = xdr_encode_opaque_fixed(p, &fl->stateid.si_opaque,
+				    sizeof(stateid_opaque_t));
+
+	*p++ = cpu_to_be32(1);			/* single file handle */
+	p = xdr_encode_opaque(p, fl->fh.data, fl->fh.size);
+
+	p = xdr_encode_opaque(p, uid.buf, uid.len);
+	p = xdr_encode_opaque(p, gid.buf, gid.len);
+
+	*p++ = cpu_to_be32(fl->flags);
+	*p++ = cpu_to_be32(0);			/* No stats collect hint */
+
+	return 0;
+}
+
+__be32
+nfsd4_ff_encode_getdeviceinfo(struct xdr_stream *xdr,
+		struct nfsd4_getdeviceinfo *gdp)
+{
+	struct pnfs_ff_device_addr *da = gdp->gd_device;
+	int len;
+	int ver_len;
+	int addr_len;
+	__be32 *p;
+
+	/* len + padding for two strings */
+	addr_len = 16 + da->netaddr.netid_len + da->netaddr.addr_len;
+	ver_len = 20;
+
+	len = 4 + ver_len + 4 + addr_len;
+
+	p = xdr_reserve_space(xdr, len + sizeof(__be32));
+	if (!p)
+		return nfserr_resource;
+
+	/*
+	 * Fill in the overall length and number of volumes at the beginning
+	 * of the layout.
+	 */
+	*p++ = cpu_to_be32(len);
+	*p++ = cpu_to_be32(1);			/* 1 netaddr */
+	p = xdr_encode_opaque(p, da->netaddr.netid, da->netaddr.netid_len);
+	p = xdr_encode_opaque(p, da->netaddr.addr, da->netaddr.addr_len);
+
+	*p++ = cpu_to_be32(1);			/* 1 versions */
+
+	*p++ = cpu_to_be32(da->version);
+	*p++ = cpu_to_be32(da->minor_version);
+	*p++ = cpu_to_be32(da->rsize);
+	*p++ = cpu_to_be32(da->wsize);
+	*p++ = cpu_to_be32(da->tightly_coupled);
+
+	return 0;
+}
diff --git a/fs/nfsd/flexfilelayoutxdr.h b/fs/nfsd/flexfilelayoutxdr.h
new file mode 100644
index 0000000..467defd
--- /dev/null
+++ b/fs/nfsd/flexfilelayoutxdr.h
@@ -0,0 +1,49 @@
+/*
+ * Copyright (c) 2016 Tom Haynes <loghyr@primarydata.com>
+ */
+#ifndef _NFSD_FLEXFILELAYOUTXDR_H
+#define _NFSD_FLEXFILELAYOUTXDR_H 1
+
+#include <linux/inet.h>
+#include "xdr4.h"
+
+#define FF_FLAGS_NO_LAYOUTCOMMIT 1
+#define FF_FLAGS_NO_IO_THRU_MDS  2
+#define FF_FLAGS_NO_READ_IO      4
+
+struct xdr_stream;
+
+#define FF_NETID_LEN		(4)
+#define FF_ADDR_LEN		(INET6_ADDRSTRLEN + 8)
+struct pnfs_ff_netaddr {
+	char				netid[FF_NETID_LEN + 1];
+	char				addr[FF_ADDR_LEN + 1];
+	u32				netid_len;
+	u32				addr_len;
+};
+
+struct pnfs_ff_device_addr {
+	struct pnfs_ff_netaddr		netaddr;
+	u32				version;
+	u32				minor_version;
+	u32				rsize;
+	u32				wsize;
+	bool				tightly_coupled;
+};
+
+struct pnfs_ff_layout {
+	u32				flags;
+	u32				stats_collect_hint;
+	kuid_t				uid;
+	kgid_t				gid;
+	struct nfsd4_deviceid		deviceid;
+	stateid_t			stateid;
+	struct nfs_fh			fh;
+};
+
+__be32 nfsd4_ff_encode_getdeviceinfo(struct xdr_stream *xdr,
+		struct nfsd4_getdeviceinfo *gdp);
+__be32 nfsd4_ff_encode_layoutget(struct xdr_stream *xdr,
+		struct nfsd4_layoutget *lgp);
+
+#endif /* _NFSD_FLEXFILELAYOUTXDR_H */
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 953c075..6d98d16 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -27,6 +27,9 @@ static const struct nfsd4_callback_ops nfsd4_cb_layout_ops;
 static const struct lock_manager_operations nfsd4_layouts_lm_ops;
 
 const struct nfsd4_layout_ops *nfsd4_layout_ops[LAYOUT_TYPE_MAX] =  {
+#ifdef CONFIG_NFSD_FLEXFILELAYOUT
+	[LAYOUT_FLEX_FILES]	= &ff_layout_ops,
+#endif
 #ifdef CONFIG_NFSD_BLOCKLAYOUT
 	[LAYOUT_BLOCK_VOLUME]	= &bl_layout_ops,
 #endif
@@ -122,17 +125,24 @@ nfsd4_set_deviceid(struct nfsd4_deviceid *id, const struct svc_fh *fhp,
 
 void nfsd4_setup_layout_type(struct svc_export *exp)
 {
+#if defined(CONFIG_NFSD_BLOCKLAYOUT) || defined(CONFIG_NFSD_SCSILAYOUT)
 	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
+#endif
 
 	if (!(exp->ex_flags & NFSEXP_PNFS))
 		return;
 
 	/*
-	 * Check if the file system supports exporting a block-like layout.
+	 * If flex file is configured, use it by default. Otherwise
+	 * check if the file system supports exporting a block-like layout.
 	 * If the block device supports reservations prefer the SCSI layout,
 	 * otherwise advertise the block layout.
 	 */
+#ifdef CONFIG_NFSD_FLEXFILELAYOUT
+	exp->ex_layout_type = LAYOUT_FLEX_FILES;
+#endif
 #ifdef CONFIG_NFSD_BLOCKLAYOUT
+	/* overwrite flex file layout selection if needed */
 	if (sb->s_export_op->get_uuid &&
 	    sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks)
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index e855677..0c2a716 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -45,6 +45,9 @@ extern const struct nfsd4_layout_ops bl_layout_ops;
 #ifdef CONFIG_NFSD_SCSILAYOUT
 extern const struct nfsd4_layout_ops scsi_layout_ops;
 #endif
+#ifdef CONFIG_NFSD_FLEXFILELAYOUT
+extern const struct nfsd4_layout_ops ff_layout_ops;
+#endif
 
 __be32 nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, stateid_t *stateid,
-- 
1.8.3.1

