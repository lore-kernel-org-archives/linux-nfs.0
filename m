From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 12/21] nfs: nfs4xdr: get rid of READ64
Date: Fri, 14 Aug 2009 17:19:41 +0300
Message-ID: <1250259581-13865-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:28859
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756888AbZHNOTr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:47 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

s/READ64\(\*(.*)\)/p = xdr_decode_hyper(p, \1)/
s/READ64\((.*)\)/p = xdr_decode_hyper(p, &\1)/

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   54 +++++++++++++++++++++++++-----------------------------
 1 files changed, 25 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5f6b46f..238189c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2433,10 +2433,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define READ64(x)         do {			\
-	(x) = (u64)ntohl(*p++) << 32;		\
-	(x) |= ntohl(*p++);			\
-} while (0)
 #define READTIME(x)       do {			\
 	p++;					\
 	(x.tv_sec) = ntohl(*p++);		\
@@ -2588,7 +2584,7 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_CHANGE)) {
 		READ_BUF(8);
-		READ64(*change);
+		p = xdr_decode_hyper(p, change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 		ret = NFS_ATTR_FATTR_CHANGE;
 	}
@@ -2607,7 +2603,7 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SIZE)) {
 		READ_BUF(8);
-		READ64(*size);
+		p = xdr_decode_hyper(p, size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 		ret = NFS_ATTR_FATTR_SIZE;
 	}
@@ -2658,8 +2654,8 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FSID)) {
 		READ_BUF(16);
-		READ64(fsid->major);
-		READ64(fsid->minor);
+		p = xdr_decode_hyper(p, &fsid->major);
+		p = xdr_decode_hyper(p, &fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
 		ret = NFS_ATTR_FATTR_FSID;
 	}
@@ -2711,7 +2707,7 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEID)) {
 		READ_BUF(8);
-		READ64(*fileid);
+		p = xdr_decode_hyper(p, fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
@@ -2729,7 +2725,7 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)) {
 		READ_BUF(8);
-		READ64(*fileid);
+		p = xdr_decode_hyper(p, fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
@@ -2747,7 +2743,7 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_AVAIL)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
 	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
@@ -2764,7 +2760,7 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_FREE)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
 	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
@@ -2781,7 +2777,7 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_TOTAL)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
 	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
@@ -2910,7 +2906,7 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXFILESIZE)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
 	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
@@ -2962,7 +2958,7 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXREAD)) {
 		uint64_t maxread;
 		READ_BUF(8);
-		READ64(maxread);
+		p = xdr_decode_hyper(p, &maxread);
 		if (maxread > 0x7FFFFFFF)
 			maxread = 0x7FFFFFFF;
 		*res = (uint32_t)maxread;
@@ -2983,7 +2979,7 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXWRITE)) {
 		uint64_t maxwrite;
 		READ_BUF(8);
-		READ64(maxwrite);
+		p = xdr_decode_hyper(p, &maxwrite);
 		if (maxwrite > 0x7FFFFFFF)
 			maxwrite = 0x7FFFFFFF;
 		*res = (uint32_t)maxwrite;
@@ -3122,7 +3118,7 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_AVAIL)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
 	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
@@ -3139,7 +3135,7 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_FREE)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
 	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
@@ -3156,7 +3152,7 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_TOTAL)) {
 		READ_BUF(8);
-		READ64(*res);
+		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
 	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
@@ -3173,7 +3169,7 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_USED)) {
 		READ_BUF(8);
-		READ64(*used);
+		p = xdr_decode_hyper(p, used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 		ret = NFS_ATTR_FATTR_SPACE_USED;
 	}
@@ -3189,7 +3185,7 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 	uint32_t nsec;
 
 	READ_BUF(12);
-	READ64(sec);
+	p = xdr_decode_hyper(p, &sec);
 	nsec = be32_to_cpup(p++);
 	time->tv_sec = (time_t)sec;
 	time->tv_nsec = (long)nsec;
@@ -3273,8 +3269,8 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 
 	READ_BUF(20);
 	cinfo->atomic = be32_to_cpup(p++);
-	READ64(cinfo->before);
-	READ64(cinfo->after);
+	p = xdr_decode_hyper(p, &cinfo->before);
+	p = xdr_decode_hyper(p, &cinfo->after);
 	return 0;
 }
 
@@ -3619,8 +3615,8 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	uint32_t namelen, type;
 
 	READ_BUF(32);
-	READ64(offset);
-	READ64(length);
+	p = xdr_decode_hyper(p, &offset);
+	p = xdr_decode_hyper(p, &length);
 	type = be32_to_cpup(p++);
 	if (fl != NULL) {
 		fl->fl_start = (loff_t)offset;
@@ -3632,7 +3628,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 			fl->fl_type = F_RDLCK;
 		fl->fl_pid = 0;
 	}
-	READ64(clientid);
+	p = xdr_decode_hyper(p, &clientid);
 	namelen = be32_to_cpup(p++);
 	READ_BUF(namelen);
 	return -NFS4ERR_DENIED;
@@ -3697,7 +3693,7 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 	limit_type = be32_to_cpup(p++);
 	switch (limit_type) {
 	case 1:
-		READ64(*maxsize);
+		p = xdr_decode_hyper(p, maxsize);
 		break;
 	case 2:
 		nblocks = be32_to_cpup(p++);
@@ -4090,7 +4086,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	nfserr = be32_to_cpup(p++);
 	if (nfserr == NFS_OK) {
 		READ_BUF(8 + NFS4_VERIFIER_SIZE);
-		READ64(clp->cl_clientid);
+		p = xdr_decode_hyper(p, &clp->cl_clientid);
 		COPYMEM(clp->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
@@ -4151,7 +4147,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 		return status;
 
 	READ_BUF(8);
-	READ64(clp->cl_ex_clid);
+	p = xdr_decode_hyper(p, &clp->cl_ex_clid);
 	READ_BUF(12);
 	clp->cl_seqid = be32_to_cpup(p++);
 	clp->cl_exchange_flags = be32_to_cpup(p++);
-- 
1.6.4

