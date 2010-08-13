Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0HMVcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:18 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 16/50] pnfs_submit: generic getdeviceinfo
Date: Fri, 13 Aug 2010 17:31:28 -0400
Message-Id: <1281735122-1496-17-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-16-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |   26 ++++++++
 fs/nfs/nfs4xdr.c          |  154 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c             |    6 ++
 fs/nfs/pnfs.h             |    3 +
 include/linux/nfs4.h      |    1 +
 include/linux/nfs4_pnfs.h |   13 ++++
 include/linux/pnfs_xdr.h  |   10 +++
 7 files changed, 213 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 45d6526..9eebe46 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -49,12 +49,15 @@
 #include <linux/mount.h>
 #include <linux/module.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/pnfs_xdr.h>
+#include <linux/nfs4_pnfs.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
 #include "callback.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -5353,6 +5356,29 @@ out:
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
 }
+
+int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
+{
+	struct nfs4_pnfs_getdeviceinfo_arg args = {
+		.pdev = pdev,
+	};
+	struct nfs4_pnfs_getdeviceinfo_res res = {
+		.pdev = pdev,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_GETDEVICEINFO],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	dprintk("<-- %s status=%d\n", __func__, status);
+
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 075845d..58bb81e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -50,8 +50,11 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs4_pnfs.h>
+#include <linux/pnfs_xdr.h>
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
@@ -310,6 +313,13 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
+#define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
+				XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE))
+#define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
+				4 /*layout type */ + \
+				4 /* opaque devaddr4 length */ +\
+				4 /* notification bitmap length */ + \
+				4 /* notification bitmap */)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -699,6 +709,12 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_reclaim_complete_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_reclaim_complete_maxsz)
+#define NFS4_enc_getdeviceinfo_sz (compound_encode_hdr_maxsz +    \
+				encode_sequence_maxsz +\
+				encode_getdeviceinfo_maxsz)
+#define NFS4_dec_getdeviceinfo_sz (compound_decode_hdr_maxsz +    \
+				decode_sequence_maxsz + \
+				decode_getdeviceinfo_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1726,6 +1742,30 @@ static void encode_sequence(struct xdr_stream *xdr,
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+#ifdef CONFIG_NFS_V4_1
+static void
+encode_getdeviceinfo(struct xdr_stream *xdr,
+		     const struct nfs4_pnfs_getdeviceinfo_arg *args,
+		     struct compound_hdr *hdr)
+{
+	int has_bitmap = (args->pdev->dev_notify_types != 0);
+	int len = 16 + NFS4_PNFS_DEVICEID4_SIZE + (has_bitmap * 4);
+	__be32 *p;
+
+	p = reserve_space(xdr, len);
+	*p++ = cpu_to_be32(OP_GETDEVICEINFO);
+	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
+				    NFS4_PNFS_DEVICEID4_SIZE);
+	*p++ = cpu_to_be32(args->pdev->layout_type);
+	*p++ = cpu_to_be32(args->pdev->pglen + len);	/* gdia_maxcount */
+	*p++ = cpu_to_be32(has_bitmap);			/* bitmap length [01] */
+	if (has_bitmap)
+		*p = cpu_to_be32(args->pdev->dev_notify_types);
+	hdr->nops++;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -2543,6 +2583,38 @@ static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
 	return 0;
 }
 
+/*
+ * Encode GETDEVICEINFO request
+ */
+static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
+				      struct nfs4_pnfs_getdeviceinfo_arg *args)
+{
+	struct xdr_stream xdr;
+	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+	int replen;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_getdeviceinfo(&xdr, args, &hdr);
+
+	/* set up reply kvec. Subtract notification bitmap max size (8)
+	 * so that notification bitmap is put in xdr_buf tail */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack +
+		  NFS4_dec_getdeviceinfo_sz - 8) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pdev->pages,
+			 args->pdev->pgbase, args->pdev->pglen);
+	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
+		__func__, replen, args->pdev->pages,
+		args->pdev->pgbase, args->pdev->pglen);
+
+	encode_nops(&hdr);
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -4791,6 +4863,64 @@ out_overflow:
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+static int decode_getdeviceinfo(struct xdr_stream *xdr,
+				struct pnfs_device *pdev)
+{
+	__be32 *p;
+	uint32_t len, type;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_GETDEVICEINFO);
+	if (status) {
+		if (status == -ETOOSMALL) {
+			p = xdr_inline_decode(xdr, 4);
+			if (unlikely(!p))
+				goto out_overflow;
+			pdev->mincount = be32_to_cpup(p);
+			dprintk("%s: Min count too small. mincnt = %u\n",
+				__func__, pdev->mincount);
+		}
+		return status;
+	}
+
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
+	type = be32_to_cpup(p++);
+	if (type != pdev->layout_type) {
+		dprintk("%s: layout mismatch req: %u pdev: %u\n",
+			__func__, pdev->layout_type, type);
+		return -EINVAL;
+	}
+	/*
+	 * Get the length of the opaque device_addr4. xdr_read_pages places
+	 * the opaque device_addr4 in the xdr_buf->pages (pnfs_device->pages)
+	 * and places the remaining xdr data in xdr_buf->tail
+	 */
+	pdev->mincount = be32_to_cpup(p);
+	xdr_read_pages(xdr, pdev->mincount); /* include space for the length */
+
+	/* At most one bitmap word */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	len = be32_to_cpup(p);
+	if (len) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		pdev->dev_notify_types = be32_to_cpup(p);
+	} else
+		pdev->dev_notify_types = 0;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * END OF "GENERIC" DECODE ROUTINES.
  */
@@ -5818,6 +5948,29 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
 		status = decode_reclaim_complete(&xdr, (void *)NULL);
 	return status;
 }
+
+/*
+ * Decode GETDEVINFO response
+ */
+static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp, uint32_t *p,
+				      struct nfs4_pnfs_getdeviceinfo_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status != 0)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status != 0)
+		goto out;
+	status = decode_getdeviceinfo(&xdr, res->pdev);
+out:
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -5996,6 +6149,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
+  PROC(PNFS_GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e17835e..dcede52 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -191,6 +191,12 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 	}
 }
 
+/* Callback operations for layout drivers.
+ */
+struct pnfs_client_operations pnfs_ops = {
+	.nfs_getdeviceinfo = nfs4_pnfs_getdeviceinfo,
+};
+
 EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
 EXPORT_SYMBOL(pnfs_register_layoutdriver);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3561fa8..f9fb58b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -21,6 +21,9 @@
 #include <linux/nfs_iostat.h>
 #include "iostat.h"
 
+/* nfs4proc.c */
+extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
+				   struct pnfs_device *dev);
 /* pnfs.c */
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 010c3ba..c0c8cba 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -533,6 +533,7 @@ enum {
 	NFSPROC4_CLNT_SEQUENCE,
 	NFSPROC4_CLNT_GET_LEASE_TIME,
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
+	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index a3fa1d2..dee53f2 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -35,6 +35,17 @@ struct layoutdriver_io_operations {
 struct layoutdriver_policy_operations {
 };
 
+struct pnfs_device {
+	struct pnfs_deviceid dev_id;
+	unsigned int  layout_type;
+	unsigned int  mincount;
+	struct page **pages;
+	void          *area;
+	unsigned int  pgbase;
+	unsigned int  pglen;
+	unsigned int  dev_notify_types;
+};
+
 /*
  * Device ID RCU cache. A device ID is unique per client ID and layout type.
  */
@@ -84,6 +95,8 @@ extern struct nfs4_deviceid *nfs4_add_deviceid(struct nfs4_deviceid_cache *,
  * E.g., getdeviceinfo, I/O callbacks, etc
  */
 struct pnfs_client_operations {
+	int (*nfs_getdeviceinfo) (struct nfs_server *,
+				  struct pnfs_device *dev);
 };
 
 extern struct pnfs_client_operations pnfs_ops;
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 1decc11..458ff69 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -18,4 +18,14 @@ struct pnfs_deviceid {
 	char data[NFS4_PNFS_DEVICEID4_SIZE];
 };
 
+struct nfs4_pnfs_getdeviceinfo_arg {
+	struct pnfs_device *pdev;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_pnfs_getdeviceinfo_res {
+	struct pnfs_device *pdev;
+	struct nfs4_sequence_res seq_res;
+};
+
 #endif /* LINUX_PNFS_XDR_H */
-- 
1.6.2.5

