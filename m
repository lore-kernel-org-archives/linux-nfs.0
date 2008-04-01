From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2 v1] nfs: use compound hdr.status to override op status.
Date: Tue, 01 Apr 2008 12:41:08 +0300
Message-ID: <47F20334.7040208@panasas.com>
References: <47F0F6AB.3030302@panasas.com>		<1206974900-368-1-git-send-email-bhalevy@panasas.com>	<1207002349.15341.15.camel@heimdal.trondhjem.org> <47F2025D.3030306@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bzq-219-195-70.pop.bezeqint.net ([62.219.195.70]:52165 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbYDAJl1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Apr 2008 05:41:27 -0400
In-Reply-To: <47F2025D.3030306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The compound header status must be equivalent to the
status of the last operation in the compound results.
In certain cases like lack of resources or xdr decoding error,
the nfs server may return a non-zero status in the compound header
which is not returned by any operation.  In this case we would
notice that today when looking for the respective operations
code in the results and we return -EIO when we cannot find it.
This patch fixes that by returning the status available in the
compound header instead.

This patch also fixes 3 call sites where we looked at the compound
hdr.status in the success case which is useless (yet benign).
These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   84 +++++++++++++++++++++++++----------------------------
 1 files changed, 40 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bb95b7c..85fae46 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3758,6 +3758,9 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
+#define nfs4_fixup_status(status, hdr_status) \
+	( likely(!status) ? 0 : nfs4_stat_to_errno(hdr_status) )
+
 /*
  * Decode OPEN_DOWNGRADE response
  */
@@ -3779,7 +3782,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3806,7 +3809,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3829,7 +3832,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3849,7 +3852,7 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if ((status = decode_getfh(&xdr, res->fh)) == 0)
 		status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3870,7 +3873,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	decode_getfattr(&xdr, &res->dir_attr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3900,7 +3903,7 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 		goto out;
 	decode_getfattr(&xdr, res->old_fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3933,7 +3936,7 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3962,7 +3965,7 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 		goto out;
 	decode_getfattr(&xdr, res->dir_fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3991,8 +3994,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
-
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4014,7 +4016,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
                 goto out;
         status = encode_setacl(&xdr, args);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 /*
  * Decode SETACL response
@@ -4035,7 +4037,7 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
 		goto out;
 	status = decode_setattr(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4058,7 +4060,7 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
 	status = decode_getacl(&xdr, rqstp, acl_len);
 
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4088,7 +4090,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 */
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4121,7 +4123,7 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4142,7 +4144,7 @@ static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp, __be32 *p, struct n
                 goto out;
         status = decode_open_confirm(&xdr, res);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4166,7 +4168,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
                 goto out;
 	decode_getfattr(&xdr, res->f_attr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4190,9 +4192,9 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
                 goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 	if (status == NFS4ERR_DELAY)
-		status = 0;
+		return 0;
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4213,7 +4215,7 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_
 		goto out;
 	status = decode_lock(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4234,7 +4236,7 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 		goto out;
 	status = decode_lockt(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4255,7 +4257,7 @@ static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 		goto out;
 	status = decode_locku(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4276,7 +4278,7 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
 		goto out;
 	status = decode_readlink(&xdr, rqstp);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4297,7 +4299,7 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_r
 		goto out;
 	status = decode_readdir(&xdr, rqstp, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4318,9 +4320,9 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readr
 		goto out;
 	status = decode_read(&xdr, rqstp, res);
 	if (!status)
-		status = res->count;
+		return res->count;
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4344,9 +4346,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 	if (!status)
-		status = res->count;
+		return res->count;
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4370,7 +4372,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4388,9 +4390,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4408,7 +4408,7 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_pathconf(&xdr, pathconf);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4426,7 +4426,7 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fssta
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_statfs(&xdr, fsstat);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4445,7 +4445,7 @@ static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4
 		goto out;
 	status = decode_server_caps(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4461,7 +4461,7 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_renew(&xdr);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4478,9 +4478,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_setclientid(&xdr, clp);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4500,9 +4498,7 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 		status = decode_putrootfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4524,7 +4520,7 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_delegreturn(&xdr);
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4547,7 +4543,7 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	xdr_enter_page(&xdr, PAGE_SIZE);
 	status = decode_getfattr(&xdr, &res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
-- 
1.5.3.3


