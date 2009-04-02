From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 11/21] SQUASHME: nfsd41: embed an xdr_netobj in nfsd4_exchange_id
Date: Fri,  3 Apr 2009 01:38:23 +0300
Message-ID: <1238711903-22365-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29547 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753172AbZDBWi3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:29 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: exchange_id operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c       |   12 ++++--------
 fs/nfsd/nfs4xdr.c         |    6 +++---
 include/linux/nfsd/xdr4.h |    3 +--
 3 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6ae12ff..9cf7d01 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1217,24 +1217,20 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	char			dname[HEXDIR_LEN];
 	nfs4_verifier		verf = exid->verifier;
 	u32			ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
-	struct xdr_netobj clname = {
-		.len = exid->id_len,
-		.data = exid->id,
-	};
 
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
 		" ip_addr=%u flags %x, spa_how %d\n",
-		__func__, rqstp, exid, clname.len, clname.data,
+		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
 		ip_addr, exid->flags, exid->spa_how);
 
-	if (!check_name(clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
+	if (!check_name(exid->clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
 		return nfserr_inval;
 
 	/* Currently only support SP4_NONE */
 	if (exid->spa_how != SP4_NONE)
 		return nfserr_encr_alg_unsupp;
 
-	status = nfs4_make_rec_clidname(dname, &clname);
+	status = nfs4_make_rec_clidname(dname, &exid->clname);
 
 	if (status)
 		goto error;
@@ -1304,7 +1300,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 out_new:
 	/* Normal case */
-	new = create_client(clname, dname);
+	new = create_client(exid->clname, dname);
 	if (new == NULL) {
 		status = nfserr_resource;
 		goto out;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 527fadb..5e8da86 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1052,10 +1052,10 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 	COPYMEM(exid->verifier.data, NFS4_VERIFIER_SIZE);
 
 	READ_BUF(4);
-	READ32(exid->id_len);
+	READ32(exid->clname.len);
 
-	READ_BUF(exid->id_len);
-	SAVEMEM(exid->id, exid->id_len);
+	READ_BUF(exid->clname.len);
+	SAVEMEM(exid->clname.data, exid->clname.len);
 
 	READ_BUF(4);
 	READ32(exid->flags);
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 7ed9955..6a340b6 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -356,8 +356,7 @@ struct nfsd4_write {
 #if defined(CONFIG_NFSD_V4_1)
 struct nfsd4_exchange_id {
 	nfs4_verifier	verifier;
-	u32		id_len;
-	char		*id;
+	struct xdr_netobj clname;
 	u32		flags;
 	clientid_t	clientid;
 	u32		seqid;
-- 
1.6.2.1

