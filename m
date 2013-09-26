Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:65257 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab3IZSkn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:43 -0400
Received: by mail-qc0-f173.google.com with SMTP id c3so1048297qcv.32
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:42 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 12/49] pnfsd: get device list/info
Date: Thu, 26 Sep 2013 14:40:38 -0400
Message-Id: <1380220838-13228-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Implement the generic handling of GETDEVICELIST and GETDEVICEINFO.

After verifying that the requested layout type is supported,
getdevlist uses the get_device_iter pnfs export method
to encode the list of deviceids and get the cookie, verifier,
and eof flag to be used be the client to iterate through
the whole device list.

Getdevinfo uses the get_device_info pnfs export method
to encode the device info for the given deviceid.

The filesystem can choose to return valid cookie and cookieverf
on eof, pointing at the end of the device list so that subsequent
calls to GETDEVIE LIST will return an empty list.

Note that with the file layout, lots of devices are sent under a
single device id, so the client will need to send a relatively
large value of maxcount.

If maxcount is 0 then just update notifications.
The nfsv4.1 spec forbids returning ETOOSMALL in this case.
It is up to the implementor of the get_device_info method
to verify the deviceid in this case and return no
info for it.

If no notifications are given represent gdir_notification as an empty
bitmap array rather than one consisting of a single zeroed entry.
Thanks to Dean Hildebrand for suggesting this optimization
and to Peter Staubach for convincing that it's worth it.

Nfsd should return sbid while getting device list so that it can operate it properly later in nfsd4_getdevinfo.

[extracted from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: update pNFS server ops to draft 13]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Fix server getdevicelist update to draft 13]
Signed-off-by: Andy Adamson<andros@umich.edu>
[pnfsd: update pNFS server ops to draft 13]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Fix server GETDEVICELIST to comply with NFSv4.1 Draft 13]
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
[pnfsd: Streamline error code checking for non-pnfs filesystems]
Signed-off-by: Dean Hildebrand <seattleplus@gmail.com>
[pnfsd: Simplify device export ops.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfs: fix compile problems if CONFIG_PNFS turned off - exportfs.h]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsd: Implement getdevlist maxcount checking.]
[pnfsd: use nfs error codes]
[pnfsd: Use 128 bit deviceid on server]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: fix warning in nfsd4_encode_devlist_iterator()]
Signed-off-by: Mike Sager <sager@netapp.com>
[pnfsd: Update getdeviceinfo for draft-19]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: encode empty getdeviceinfo notify bitmap rather than zeroed]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: do not depend on the current file handle in getdeviceinfo]
[pnfsd: update export hold count]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Update getdevlist for draft 19]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: fix GETDEVICELIST encoding]
Signed-off-by: Mike Sager <sager@netapp.com>
[pnfsd: use nfsd4_compoundres pointer in pnfs_xdr_info]
[pnfsd: fix NFS4ERR_TOOSMALL for getdeviceinfo]
[pnfsd: enable multipage getdeviceinfo da_addr_body]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: move vfs api structures to nfsd4_pnfs.h]
[pnfsd: convert generic code to use new pnfs api]
[pnfsd: define pnfs_export_operations]
[pnfsd: obliterate old vfs api]
[pnfsd: fixup ENCODE_HEAD for getdevicelist/info]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: get device list/info all layout types]
[pnfsd: check ex_pnfs in nfsd4_verify_layout]
Signed-off-by: Andy Adamson <andros@netapp.com>
[removed nfsd4_pnfs_fl_getdev{info,iter} stubs]
[pnfsd: filelayout: convert to using exp_xdr]
[pnfsd: get rid of getdevinfo notify_types]
[pnfsd: copy getdevinfo deviceid in one piece]
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: fix cosmetic checkpatch warnings]
[pnfsd: handle s_pnfs_op==NULL]
[pnfsd: move getdevinfo xdr structure to private header]
[pnfsd: clean up getdeviceinfo export op API]
[pnfsd: getdeviceinfo deviceid needs to be const.]
[pnfsd: allow returning empty device list.]
[pnfsd: return NFS4ERR_INVAL when maxdevices is zero.]
[pnfsd: move getdevlist xdr structure to private header]
[pnfsd: dev_iter: clean up export API]
[pnfsd: rename device fsid member to sbid]
[pnfsd: use devid.sbid for locating super block in getdevinfo]
[pnfsd: fixup nfsd4_encode_getdev{list,info} to use __be32 nfserr]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Use list_move instead list_del and list_add]
Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
[pnfsd: using sbid instead of fsid while returning device list to client]
Signed-off-by: Zhengju Sha <shazhengju@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/export.c                |   3 +-
 fs/nfsd/nfs4pnfsd.c             |  30 ++++-
 fs/nfsd/nfs4proc.c              |  92 ++++++++++++++
 fs/nfsd/nfs4xdr.c               | 257 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/pnfsd.h                 |   3 +
 fs/nfsd/xdr4.h                  |  22 ++++
 include/linux/nfsd/nfsd4_pnfs.h |  32 +++++
 7 files changed, 433 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index d803414..462f0df 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -377,7 +377,8 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 	}
 
 	if (inode->i_sb->s_pnfs_op &&
-	    !inode->i_sb->s_pnfs_op->layout_type) {
+	    (!inode->i_sb->s_pnfs_op->layout_type ||
+	     !inode->i_sb->s_pnfs_op->get_device_info)) {
 		dprintk("exp_export: export of invalid fs pnfs export ops.\n");
 		return -EINVAL;
 	}
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 9a7cbc9..d219e42 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -118,7 +118,29 @@ struct sbid_tracker {
 	return id;
 }
 
-static u64
+struct super_block *
+find_sbid_id(u64 id)
+{
+	struct sbid_tracker *sbid;
+	struct super_block *sb = NULL;
+	unsigned long hash_idx = id & SBID_HASH_MASK;
+	int pos = 0;
+
+	spin_lock(&layout_lock);
+	list_for_each_entry (sbid, &sbid_hashtbl[hash_idx], hash) {
+		pos++;
+		if (sbid->id != id)
+			continue;
+		if (pos > 1)
+			list_move(&sbid->hash, &sbid_hashtbl[hash_idx]);
+		sb = sbid->sb;
+		break;
+	}
+	spin_unlock(&layout_lock);
+	return sb;
+}
+
+u64
 find_create_sbid(struct super_block *sb)
 {
 	struct sbid_tracker *sbid;
@@ -131,10 +153,8 @@ struct sbid_tracker {
 		pos++;
 		if (sbid->sb != sb)
 			continue;
-		if (pos > 1) {
-			list_del(&sbid->hash);
-			list_add(&sbid->hash, &sbid_hashtbl[hash_idx]);
-		}
+		if (pos > 1)
+			list_move(&sbid->hash, &sbid_hashtbl[hash_idx]);
 		id = sbid->id;
 		break;
 	}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 576b635..feea3a9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1146,6 +1146,87 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+
+static __be32
+nfsd4_getdevlist(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd4_pnfs_getdevlist *gdlp)
+{
+	struct super_block *sb;
+	struct svc_fh *current_fh = &cstate->current_fh;
+	int status;
+
+	dprintk("%s: type %u maxdevices %u cookie %llu verf %llu\n",
+		__func__, gdlp->gd_layout_type, gdlp->gd_maxdevices,
+		gdlp->gd_cookie, gdlp->gd_verf);
+
+
+	status = fh_verify(rqstp, current_fh, 0, NFSD_MAY_NOP);
+	if (status)
+		goto out;
+
+	status = nfserr_inval;
+	sb = current_fh->fh_dentry->d_inode->i_sb;
+	if (!sb)
+		goto out;
+
+	/* We must be able to encode at list one device */
+	if (!gdlp->gd_maxdevices)
+		goto out;
+
+	/* Ensure underlying file system supports pNFS and,
+	 * if so, the requested layout type
+	 */
+	status = nfsd4_layout_verify(sb, current_fh->fh_export,
+				     gdlp->gd_layout_type);
+	if (status)
+		goto out;
+
+	/* Do nothing if underlying file system does not support
+	 * getdevicelist */
+	if (!sb->s_pnfs_op->get_device_iter) {
+		status = nfserr_notsupp;
+		goto out;
+	}
+
+	/* Set up arguments so device can be retrieved at encode time */
+	gdlp->gd_fhp = &cstate->current_fh;
+out:
+	return status;
+}
+
+static __be32
+nfsd4_getdevinfo(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd4_pnfs_getdevinfo *gdp)
+{
+	struct super_block *sb;
+	int status;
+
+	dprintk("%s: layout_type %u dev_id %llx:%llx maxcnt %u\n",
+	       __func__, gdp->gd_layout_type, gdp->gd_devid.sbid,
+	       gdp->gd_devid.devid, gdp->gd_maxcount);
+
+	status = nfserr_inval;
+	sb = find_sbid_id(gdp->gd_devid.sbid);
+	dprintk("%s: sb %p\n", __func__, sb);
+	if (!sb) {
+		status = nfserr_noent;
+		goto out;
+	}
+
+	/* Ensure underlying file system supports pNFS and,
+	 * if so, the requested layout type
+	 */
+	status = nfsd4_layout_verify(sb, NULL, gdp->gd_layout_type);
+	if (status)
+		goto out;
+
+	/* Set up arguments so device can be retrieved at encode time */
+	gdp->gd_sb = sb;
+out:
+	return status;
+}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -1879,6 +1960,17 @@ static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+#if defined(CONFIG_PNFSD)
+	[OP_GETDEVICELIST] = {
+		.op_func = (nfsd4op_func)nfsd4_getdevlist,
+		.op_name = "OP_GETDEVICELIST",
+	},
+	[OP_GETDEVICEINFO] = {
+		.op_func = (nfsd4op_func)nfsd4_getdevinfo,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_GETDEVICEINFO",
+	},
+#endif /* CONFIG_PNFSD */
 };
 
 #ifdef NFSD_DEBUG
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d9454fe..a761514 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -46,6 +46,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/exportfs.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -54,6 +55,7 @@
 #include "state.h"
 #include "cache.h"
 #include "netns.h"
+#include "pnfsd.h"
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 #include <linux/security.h>
@@ -1484,6 +1486,42 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	DECODE_TAIL;
 }
 
+#if defined(CONFIG_PNFSD)
+static __be32
+nfsd4_decode_getdevlist(struct nfsd4_compoundargs *argp,
+			struct nfsd4_pnfs_getdevlist *gdevl)
+{
+	DECODE_HEAD;
+
+	READ_BUF(16 + sizeof(nfs4_verifier));
+	READ32(gdevl->gd_layout_type);
+	READ32(gdevl->gd_maxdevices);
+	READ64(gdevl->gd_cookie);
+	COPYMEM(&gdevl->gd_verf, sizeof(nfs4_verifier));
+
+	DECODE_TAIL;
+}
+
+static __be32
+nfsd4_decode_getdevinfo(struct nfsd4_compoundargs *argp,
+			struct nfsd4_pnfs_getdevinfo *gdev)
+{
+	u32 num;
+	DECODE_HEAD;
+
+	READ_BUF(12 + sizeof(struct nfsd4_pnfs_deviceid));
+	READ64(gdev->gd_devid.sbid);
+	READ64(gdev->gd_devid.devid);
+	READ32(gdev->gd_layout_type);
+	READ32(gdev->gd_maxcount);
+	READ32(num);
+	if (num)
+		READ_BUF(4); /* TODO: for now, just skip notify_types */
+
+	DECODE_TAIL;
+}
+#endif /* CONFIG_PNFSD */
+
 static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
@@ -1585,11 +1623,19 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
 	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_free_stateid,
 	[OP_GET_DIR_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
+#if defined(CONFIG_PNFSD)
+	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_getdevinfo,
+	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_getdevlist,
+	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
+#else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
+#endif /* CONFIG_PNFSD */
 	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_secinfo_no_name,
 	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
 	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3519,6 +3565,209 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	return nfserr;
 }
 
+#if defined(CONFIG_PNFSD)
+
+/* Uses the export interface to iterate through the available devices
+ * and encodes them on the response stream.
+ */
+static  __be32
+nfsd4_encode_devlist_iterator(struct nfsd4_compoundres *resp,
+			      struct nfsd4_pnfs_getdevlist *gdevl,
+			      unsigned int *dev_count)
+{
+	struct super_block *sb = gdevl->gd_fhp->fh_dentry->d_inode->i_sb;
+	__be32 nfserr;
+	int status;
+	__be32 *p;
+	struct nfsd4_pnfs_dev_iter_res res = {
+		.gd_cookie = gdevl->gd_cookie,
+		.gd_verf = gdevl->gd_verf,
+		.gd_eof = 0
+	};
+	u64 sbid;
+
+	dprintk("%s: Begin\n", __func__);
+
+	sbid = find_create_sbid(sb);
+	*dev_count = 0;
+	do {
+		status = sb->s_pnfs_op->get_device_iter(sb,
+							gdevl->gd_layout_type,
+							&res);
+		if (status) {
+			if (status == -ENOENT) {
+				res.gd_eof = 1;
+				/* return success */
+				break;
+			}
+			nfserr = nfserrno(status);
+			goto out_err;
+		}
+
+		/* Encode device id and layout type */
+		RESERVE_SPACE(sizeof(struct nfsd4_pnfs_deviceid));
+		WRITE64(sbid);
+		WRITE64(res.gd_devid);	/* devid minor */
+		ADJUST_ARGS();
+		(*dev_count)++;
+	} while (*dev_count < gdevl->gd_maxdevices && !res.gd_eof);
+	gdevl->gd_cookie = res.gd_cookie;
+	gdevl->gd_verf = res.gd_verf;
+	gdevl->gd_eof = res.gd_eof;
+	nfserr = nfs_ok;
+out_err:
+	dprintk("%s: Encoded %u devices\n", __func__, *dev_count);
+	return nfserr;
+}
+
+/* Encodes the response of get device list.
+*/
+static __be32
+nfsd4_encode_getdevlist(struct nfsd4_compoundres *resp, __be32 nfserr,
+			struct nfsd4_pnfs_getdevlist *gdevl)
+{
+	unsigned int dev_count = 0, lead_count;
+	u32 *p_in = resp->p;
+	__be32 *p;
+
+	dprintk("%s: err %d\n", __func__, nfserr);
+	if (nfserr)
+		return nfserr;
+
+	/* Ensure we have room for cookie, verifier, and devlist len,
+	 * which we will backfill in after we encode as many devices as possible
+	 */
+	lead_count = 8 + sizeof(nfs4_verifier) + 4;
+	RESERVE_SPACE(lead_count);
+	/* skip past these values */
+	p += XDR_QUADLEN(lead_count);
+	ADJUST_ARGS();
+
+	/* Iterate over as many device ids as possible on the xdr stream */
+	nfserr = nfsd4_encode_devlist_iterator(resp, gdevl, &dev_count);
+	if (nfserr)
+		goto out_err;
+
+	/* Backfill in cookie, verf and number of devices encoded */
+	p = p_in;
+	WRITE64(gdevl->gd_cookie);
+	WRITEMEM(&gdevl->gd_verf, sizeof(nfs4_verifier));
+	WRITE32(dev_count);
+
+	/* Skip over devices */
+	p += XDR_QUADLEN(dev_count * sizeof(struct nfsd4_pnfs_deviceid));
+	ADJUST_ARGS();
+
+	/* are we at the end of devices? */
+	RESERVE_SPACE(4);
+	WRITE32(gdevl->gd_eof);
+	ADJUST_ARGS();
+
+	dprintk("%s: done.\n", __func__);
+
+	nfserr = nfs_ok;
+out:
+	return nfserr;
+out_err:
+	p = p_in;
+	ADJUST_ARGS();
+	goto out;
+}
+
+/* For a given device id, have the file system retrieve and encode the
+ * associated device.  For file layout, the encoding function is
+ * passed down to the file system.  The file system then has the option
+ * of using this encoding function or one of its own.
+ *
+ * Note: the file system must return the XDR size of struct device_addr4
+ * da_addr_body in pnfs_xdr_info.bytes_written on NFS4ERR_TOOSMALL for the
+ * gdir_mincount calculation.
+ */
+static __be32
+nfsd4_encode_getdevinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
+			struct nfsd4_pnfs_getdevinfo *gdev)
+{
+	struct super_block *sb;
+	int maxcount = 0, type_notify_len = 12;
+	__be32 *p, *p_save = NULL, *p_in = resp->p;
+	struct exp_xdr_stream xdr;
+
+	dprintk("%s: err %d\n", __func__, nfserr);
+	if (nfserr)
+		return nfserr;
+
+	sb = gdev->gd_sb;
+
+	if (gdev->gd_maxcount != 0) {
+		/* FIXME: this will be bound by the session max response */
+		maxcount = svc_max_payload(resp->rqstp);
+		if (maxcount > gdev->gd_maxcount)
+			maxcount = gdev->gd_maxcount;
+
+		/* Ensure have room for type and notify field */
+		maxcount -= type_notify_len;
+		if (maxcount < 0) {
+			nfserr = -ETOOSMALL;
+			goto toosmall;
+		}
+	}
+
+	RESERVE_SPACE(4);
+	WRITE32(gdev->gd_layout_type);
+	ADJUST_ARGS();
+
+	/* If maxcount is 0 then just update notifications */
+	if (gdev->gd_maxcount == 0)
+		goto handle_notifications;
+
+	xdr.p = p_save = resp->p;
+	xdr.end = resp->end;
+	if (xdr.end - xdr.p > exp_xdr_qwords(maxcount & ~3))
+		xdr.end = xdr.p + exp_xdr_qwords(maxcount & ~3);
+
+	nfserr = sb->s_pnfs_op->get_device_info(sb, &xdr, gdev->gd_layout_type,
+						&gdev->gd_devid);
+	if (nfserr) {
+		/* Rewind to the beginning */
+		p = p_in;
+		ADJUST_ARGS();
+		if (nfserr == -ETOOSMALL)
+			goto toosmall;
+		printk(KERN_ERR "%s: export ERROR %d\n", __func__, nfserr);
+		goto out;
+	}
+
+	/* The file system should never write 0 bytes without
+	 * returning an error
+	 */
+	BUG_ON(xdr.p == p_save);
+	BUG_ON(xdr.p > xdr.end);
+
+	/* Update the xdr stream with the number of bytes encoded
+	 * by the file system.
+	 */
+	p = xdr.p;
+	ADJUST_ARGS();
+
+handle_notifications:
+	/* Encode supported device notifications.
+	 * Note: Currently none are supported.
+	 */
+	RESERVE_SPACE(4);
+	WRITE32(0);
+	ADJUST_ARGS();
+
+out:
+	return nfserrno(nfserr);
+toosmall:
+	dprintk("%s: maxcount too small\n", __func__);
+	RESERVE_SPACE(4);
+	WRITE32((p_save ? (xdr.p - p_save) * 4 : 0) + type_notify_len);
+	ADJUST_ARGS();
+	goto out;
+}
+#endif /* CONFIG_PNFSD */
+
 static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
@@ -3579,11 +3828,19 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
 	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_free_stateid,
 	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
+#if defined(CONFIG_PNFSD)
+	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_getdevinfo,
+	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_getdevlist,
+	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
+#else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
+#endif /* CONFIG_PNFSD */
 	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo_no_name,
 	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
 	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 29ea2e7..cfcfc9a 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -38,4 +38,7 @@
 
 #include "xdr4.h"
 
+u64 find_create_sbid(struct super_block *);
+struct super_block *find_sbid_id(u64);
+
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b3ed644..faf37bc 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -37,6 +37,8 @@
 #ifndef _LINUX_NFSD_XDR4_H
 #define _LINUX_NFSD_XDR4_H
 
+#include <linux/nfsd/nfsd4_pnfs.h>
+
 #include "state.h"
 #include "nfsd.h"
 
@@ -430,6 +432,22 @@ struct nfsd4_reclaim_complete {
 	u32 rca_one_fs;
 };
 
+struct nfsd4_pnfs_getdevinfo {
+	struct nfsd4_pnfs_deviceid gd_devid;	/* request */
+	u32			gd_layout_type;	/* request */
+	u32			gd_maxcount;	/* request */
+	struct super_block	*gd_sb;
+};
+
+struct nfsd4_pnfs_getdevlist {
+	u32             gd_layout_type;	/* request */
+	u32		gd_maxdevices;	/* request */
+	u64		gd_cookie;	/* request - response */
+	u64		gd_verf;	/* request - response */
+	struct svc_fh	*gd_fhp;	/* response */
+	u32		gd_eof;		/* response */
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -475,6 +493,10 @@ struct nfsd4_op {
 		struct nfsd4_reclaim_complete	reclaim_complete;
 		struct nfsd4_test_stateid	test_stateid;
 		struct nfsd4_free_stateid	free_stateid;
+#if defined(CONFIG_PNFSD)
+		struct nfsd4_pnfs_getdevlist	pnfs_getdevlist;
+		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
+#endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
 };
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index d44669e..53a0bb7 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -35,6 +35,19 @@
 #define _LINUX_NFSD_NFSD4_PNFS_H
 
 #include <linux/exportfs.h>
+#include <linux/exp_xdr.h>
+
+struct nfsd4_pnfs_deviceid {
+	u64	sbid;			/* per-superblock unique ID */
+	u64	devid;			/* filesystem-wide unique device ID */
+};
+
+struct nfsd4_pnfs_dev_iter_res {
+	u64		gd_cookie;	/* request/repsonse */
+	u64		gd_verf;	/* request/repsonse */
+	u64		gd_devid;	/* response */
+	u32		gd_eof;		/* response */
+};
 
 /*
  * pNFS export operations vector.
@@ -49,6 +62,25 @@
 struct pnfs_export_operations {
 	/* Returns the supported pnfs_layouttype4. */
 	int (*layout_type) (struct super_block *);
+
+	/* Encode device info onto the xdr stream. */
+	int (*get_device_info) (struct super_block *,
+				struct exp_xdr_stream *,
+				u32 layout_type,
+				const struct nfsd4_pnfs_deviceid *);
+
+	/* Retrieve all available devices via an iterator.
+	 * arg->cookie == 0 indicates the beginning of the list,
+	 * otherwise arg->verf is used to verify that the list hasn't changed
+	 * while retrieved.
+	 *
+	 * On output, the filesystem sets the devid based on the current cookie
+	 * and sets res->cookie and res->verf corresponding to the next entry.
+	 * When the last entry in the list is retrieved, res->eof is set to 1.
+	 */
+	int (*get_device_iter) (struct super_block *,
+				u32 layout_type,
+				struct nfsd4_pnfs_dev_iter_res *);
 };
 
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.8.3.1

