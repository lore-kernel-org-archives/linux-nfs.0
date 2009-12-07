From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 11/35] pnfsd: get device list/info
Date: Mon,  7 Dec 2009 11:32:10 +0200
Message-ID: <1260178330-15032-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Andy Adamson <andros@umich.edu>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Dean Hildebrand <seattleplus@gmail.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Fred Isaman <iisaman@citi.umich.edu>,
	Mike Sager <sager@netapp.com>, Andy Adamson <andros@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:55892 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934851AbZLGJbP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:31:15 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/export.c                |    3 +-
 fs/nfsd/nfs4proc.c              |  101 ++++++++++++++++
 fs/nfsd/nfs4xdr.c               |  254 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h                  |   22 ++++
 include/linux/nfsd/nfsd4_pnfs.h |   34 +++++
 5 files changed, 413 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 7c3fa87..d847dd2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -398,7 +398,8 @@ static int check_export(struct inode *inode, int flags, unsigned char *uuid,
 	}
 
 	if (inode->i_sb->s_pnfs_op &&
-	    !inode->i_sb->s_pnfs_op->layout_type) {
+	    (!inode->i_sb->s_pnfs_op->layout_type ||
+	     !inode->i_sb->s_pnfs_op->get_device_info)) {
 		dprintk("exp_export: export of invalid fs pnfs export ops.\n");
 		return -EINVAL;
 	}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4c78642..8747ddf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -968,6 +968,96 @@ nfsd4_layout_verify(struct super_block *sb, struct svc_export *exp,
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
+	struct svc_export *exp = NULL;
+	u32 fsidv = gdp->gd_devid.fsid;
+	int status;
+
+	dprintk("%s: layout_type %u dev_id %llx:%llx maxcnt %u\n",
+	       __func__, gdp->gd_layout_type, gdp->gd_devid.fsid,
+	       gdp->gd_devid.devid, gdp->gd_maxcount);
+
+	status = nfserr_inval;
+	exp = rqst_exp_find(rqstp, FSID_NUM, &fsidv);
+	dprintk("%s: exp %p\n", __func__, exp);
+	if (IS_ERR(exp)) {
+		status = nfserrno(PTR_ERR(exp));
+		exp = NULL;
+		goto out;
+	}
+	sb = exp->ex_path.dentry->d_inode->i_sb;
+	dprintk("%s: sb %p\n", __func__, sb);
+	if (!sb)
+		goto out;
+
+	/* Ensure underlying file system supports pNFS and,
+	 * if so, the requested layout type
+	 */
+	status = nfsd4_layout_verify(sb, exp, gdp->gd_layout_type);
+	if (status)
+		goto out;
+
+	/* Set up arguments so device can be retrieved at encode time */
+	gdp->gd_sb = sb;
+out:
+	if (exp)
+		exp_put(exp);
+	return status;
+}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -1330,6 +1420,17 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
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
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a8587e9..955f583 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -46,6 +46,7 @@
 #include <linux/nfsd_idmap.h>
 #include <linux/nfs4_acl.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/exportfs.h>
 
 #include "xdr4.h"
 #include "vfs.h"
@@ -1233,6 +1234,42 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
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
+	READ64(gdev->gd_devid.fsid);
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
@@ -1334,11 +1371,19 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
 	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
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
 	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
 	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3062,6 +3107,207 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	return 0;
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
+
+	dprintk("%s: Begin\n", __func__);
+
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
+		WRITE64((__be64)gdevl->gd_fhp->fh_export->ex_fsid);
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
+nfsd4_encode_getdevlist(struct nfsd4_compoundres *resp, int nfserr,
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
+nfsd4_encode_getdevinfo(struct nfsd4_compoundres *resp, int nfserr,
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
@@ -3122,11 +3368,19 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
 	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
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
 	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
 	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 83202a1..acb215a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -39,6 +39,8 @@
 #ifndef _LINUX_NFSD_XDR4_H
 #define _LINUX_NFSD_XDR4_H
 
+#include <linux/nfsd/nfsd4_pnfs.h>
+
 #include "state.h"
 #include "nfsd.h"
 
@@ -383,6 +385,22 @@ struct nfsd4_destroy_session {
 	struct nfs4_sessionid	sessionid;
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
+	struct svc_fh 	*gd_fhp;	/* response */
+	u32		gd_eof;		/* response */
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -423,6 +441,10 @@ struct nfsd4_op {
 		struct nfsd4_create_session	create_session;
 		struct nfsd4_destroy_session	destroy_session;
 		struct nfsd4_sequence		sequence;
+#if defined(CONFIG_PNFSD)
+		struct nfsd4_pnfs_getdevlist	pnfs_getdevlist;
+		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
+#endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
 };
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index c44e13d..d68fd14 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -34,6 +34,21 @@
 #ifndef _LINUX_NFSD_NFSD4_PNFS_H
 #define _LINUX_NFSD_NFSD4_PNFS_H
 
+#include <linux/exportfs.h>
+#include <linux/exp_xdr.h>
+
+struct nfsd4_pnfs_deviceid {
+	u64	fsid;			/* filesystem ID */
+	u64	devid;			/* filesystem-wide unique device ID */
+};
+
+struct nfsd4_pnfs_dev_iter_res {
+	u64		gd_cookie;	/* request/repsonse */
+	u64		gd_verf;	/* request/repsonse */
+	u64		gd_devid;	/* response */
+	u32		gd_eof;		/* response */
+};
+
 /*
  * pNFS export operations vector.
  *
@@ -47,6 +62,25 @@
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
1.6.5.1

