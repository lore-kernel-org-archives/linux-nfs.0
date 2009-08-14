From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 15/21] nfs: nfs4xdr: introduce decode_opaque_fixed and decode_stateid helpers
Date: Fri, 14 Aug 2009 17:19:52 +0300
Message-ID: <1250259592-13961-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:26389
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932123AbZHNOT7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:59 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   71 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8255ec7..86e6983 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3290,19 +3290,34 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 	return 0;
 }
 
-static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
+static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
 {
 	__be32 *p;
+
+	p = xdr_inline_decode(xdr, len);
+	if (likely(p)) {
+		memcpy(buf, p, len);
+		return 0;
+	}
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	return decode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
+}
+
+static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
+{
 	int status;
 
 	status = decode_op_hdr(xdr, OP_CLOSE);
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
-	if (status)
-		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
-	return 0;
+	if (!status)
+		status = decode_stateid(xdr, &res->stateid);
+	return status;
 }
 
 static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
@@ -3635,15 +3650,15 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 
 static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
 {
-	__be32 *p;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_LOCK);
 	if (status == -EIO)
 		goto out;
 	if (status == 0) {
-		READ_BUF(NFS4_STATEID_SIZE);
-		COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+		status = decode_stateid(xdr, &res->stateid);
+		if (unlikely(status))
+			goto out;
 	} else if (status == -NFS4ERR_DENIED)
 		status = decode_lock_denied(xdr, NULL);
 	if (res->open_seqid != NULL)
@@ -3664,16 +3679,13 @@ static int decode_lockt(struct xdr_stream *xdr, struct nfs_lockt_res *res)
 
 static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
 {
-	__be32 *p;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_LOCKU);
 	if (status != -EIO)
 		nfs_increment_lock_seqid(status, res->seqid);
-	if (status == 0) {
-		READ_BUF(NFS4_STATEID_SIZE);
-		COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
-	}
+	if (status == 0)
+		status = decode_stateid(xdr, &res->stateid);
 	return status;
 }
 
@@ -3706,6 +3718,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 {
 	__be32 *p;
 	uint32_t delegation_type;
+	int status;
 
 	READ_BUF(4);
 	delegation_type = be32_to_cpup(p++);
@@ -3713,8 +3726,10 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 		res->delegation_type = 0;
 		return 0;
 	}
-	READ_BUF(NFS4_STATEID_SIZE+4);
-	COPYMEM(res->delegation.data, NFS4_STATEID_SIZE);
+	status = decode_stateid(xdr, &res->delegation);
+	if (unlikely(status))
+		return status;
+	READ_BUF(4);
 	res->do_recall = be32_to_cpup(p++);
 
 	switch (delegation_type) {
@@ -3738,10 +3753,10 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	status = decode_op_hdr(xdr, OP_OPEN);
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
-	if (status)
+	if (!status)
+		status = decode_stateid(xdr, &res->stateid);
+	if (unlikely(status))
 		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
 
 	decode_change_info(xdr, &res->cinfo);
 
@@ -3766,32 +3781,26 @@ xdr_error:
 
 static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmres *res)
 {
-	__be32 *p;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_OPEN_CONFIRM);
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
-	if (status)
-		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
-	return 0;
+	if (!status)
+		status = decode_stateid(xdr, &res->stateid);
+	return status;
 }
 
 static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *res)
 {
-	__be32 *p;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_OPEN_DOWNGRADE);
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
-	if (status)
-		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
-	return 0;
+	if (!status)
+		status = decode_stateid(xdr, &res->stateid);
+	return status;
 }
 
 static int decode_putfh(struct xdr_stream *xdr)
-- 
1.6.4

