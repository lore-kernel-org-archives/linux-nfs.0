Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:50642 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbbBCV7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Feb 2015 16:59:47 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so30266948igb.2
        for <linux-nfs@vger.kernel.org>; Tue, 03 Feb 2015 13:59:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Olga.Kornievskaia@netapp.com
Subject: [PATCH 1/2] NFSv4.1: Ask for no delegation on OPEN if using O_DIRECT
Date: Tue,  3 Feb 2015 16:59:43 -0500
Message-Id: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're using NFSv4.1, then we have the ability to let the server know
whether or not we believe that returning a delegation as part of our OPEN
request would be useful.
The feature needs to be used with care, since the client sending the request
doesn't necessarily know how other clients are using that file, and how
they may be affected by the delegation.
For this reason, our initial use of the feature will be to let the server
know when the client believes that handing out a delegation would not be
useful.
The first application for this function is when opening the file using
O_DIRECT.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 30 +++++++++++++++++++
 fs/nfs/nfs4xdr.c        | 79 +++++++++++++++++++++++++++++++++----------------
 include/linux/nfs_xdr.h |  2 ++
 3 files changed, 85 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6e1c9b2d92c5..cd4295d84d54 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -940,6 +940,31 @@ static bool nfs4_clear_cap_atomic_open_v1(struct nfs_server *server,
 	return true;
 }
 
+static u32
+nfs4_map_atomic_open_share(struct nfs_server *server,
+		fmode_t fmode, int openflags)
+{
+	u32 res = 0;
+
+	switch (fmode & (FMODE_READ | FMODE_WRITE)) {
+	case FMODE_READ:
+		res = NFS4_SHARE_ACCESS_READ;
+		break;
+	case FMODE_WRITE:
+		res = NFS4_SHARE_ACCESS_WRITE;
+		break;
+	case FMODE_READ|FMODE_WRITE:
+		res = NFS4_SHARE_ACCESS_BOTH;
+	}
+	if (!(server->caps & NFS_CAP_ATOMIC_OPEN_V1))
+		goto out;
+	/* Want no delegation if we're using O_DIRECT */
+	if (openflags & O_DIRECT)
+		res |= NFS4_SHARE_WANT_NO_DELEG;
+out:
+	return res;
+}
+
 static enum open_claim_type4
 nfs4_map_atomic_open_claim(struct nfs_server *server,
 		enum open_claim_type4 claim)
@@ -1002,6 +1027,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	atomic_inc(&sp->so_count);
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
+	p->o_arg.share_access = nfs4_map_atomic_open_share(server,
+			fmode, flags);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
 	 * will return permission denied for all bits until close */
 	if (!(flags & O_EXCL)) {
@@ -2695,6 +2722,9 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 			goto out_wait;
 		    }
 	}
+	calldata->arg.share_access =
+		nfs4_map_atomic_open_share(NFS_SERVER(inode),
+				calldata->arg.fmode, 0);
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a2329d69502b..e23a0a664e12 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1351,24 +1351,12 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
+static void encode_share_access(struct xdr_stream *xdr, u32 share_access)
 {
 	__be32 *p;
 
 	p = reserve_space(xdr, 8);
-	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
-	case FMODE_READ:
-		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_READ);
-		break;
-	case FMODE_WRITE:
-		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_WRITE);
-		break;
-	case FMODE_READ|FMODE_WRITE:
-		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_BOTH);
-		break;
-	default:
-		*p++ = cpu_to_be32(0);
-	}
+	*p++ = cpu_to_be32(share_access);
 	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
 }
 
@@ -1380,7 +1368,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->share_access);
 	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(24);
@@ -1535,7 +1523,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->share_access);
 }
 
 static void
@@ -4935,20 +4923,13 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
+static int decode_rw_delegation(struct xdr_stream *xdr,
+		uint32_t delegation_type,
+		struct nfs_openres *res)
 {
 	__be32 *p;
-	uint32_t delegation_type;
 	int status;
 
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	delegation_type = be32_to_cpup(p);
-	if (delegation_type == NFS4_OPEN_DELEGATE_NONE) {
-		res->delegation_type = 0;
-		return 0;
-	}
 	status = decode_stateid(xdr, &res->delegation);
 	if (unlikely(status))
 		return status;
@@ -4972,6 +4953,52 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_no_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
+{
+	__be32 *p;
+	uint32_t why_no_delegation;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	why_no_delegation = be32_to_cpup(p);
+	switch (why_no_delegation) {
+		case WND4_CONTENTION:
+		case WND4_RESOURCE:
+			xdr_inline_decode(xdr, 4);
+			/* Ignore for now */
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
+{
+	__be32 *p;
+	uint32_t delegation_type;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	delegation_type = be32_to_cpup(p);
+	res->delegation_type = 0;
+	switch (delegation_type) {
+	case NFS4_OPEN_DELEGATE_NONE:
+		return 0;
+	case NFS4_OPEN_DELEGATE_READ:
+	case NFS4_OPEN_DELEGATE_WRITE:
+		return decode_rw_delegation(xdr, delegation_type, res);
+	case NFS4_OPEN_DELEGATE_NONE_EXT:
+		return decode_no_delegation(xdr, res);
+	}
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 {
 	__be32 *p;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 81401125ab2d..2c35e2affa6f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -326,6 +326,7 @@ struct nfs_openargs {
 	struct nfs_seqid *	seqid;
 	int			open_flags;
 	fmode_t			fmode;
+	u32			share_access;
 	u32			access;
 	__u64                   clientid;
 	struct stateowner_id	id;
@@ -393,6 +394,7 @@ struct nfs_closeargs {
 	nfs4_stateid 		stateid;
 	struct nfs_seqid *	seqid;
 	fmode_t			fmode;
+	u32			share_access;
 	const u32 *		bitmask;
 };
 
-- 
2.1.0

