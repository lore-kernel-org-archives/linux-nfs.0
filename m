From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfs: use compound hdr.status to override op status.
Date: Mon, 31 Mar 2008 17:48:20 +0300
Message-ID: <1206974900-368-1-git-send-email-bhalevy@panasas.com>
References: <47F0F6AB.3030302@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47F0F6AB.3030302@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

The compound header status must be equivalent to the
status of the last operation in the compound results.
In certain cases like lack of resources or xdr decoding error,
the nfs server may return a non-zero status in the compound header
which is not returned by any operation.  In this case we would
notice that today when looking for the respective operations
code in the results and we return -EIO when we cannot find it.
This patch fixes that by returning the status available in the
comound header instead.

This patch also fixes 3 call sites where we looked at the comound
hdr.status in the success case which is useless (yet benign).
These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   74 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 68 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bb95b7c..edaa2fe 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3779,6 +3779,8 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 
@@ -3806,6 +3808,8 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3829,6 +3833,8 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3849,6 +3855,8 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if ((status = decode_getfh(&xdr, res->fh)) == 0)
 		status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3870,6 +3878,8 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	decode_getfattr(&xdr, &res->dir_attr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3900,6 +3910,8 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 		goto out;
 	decode_getfattr(&xdr, res->old_fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3933,6 +3945,8 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3962,6 +3976,8 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 		goto out;
 	decode_getfattr(&xdr, res->dir_fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -3991,6 +4007,8 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 
 }
@@ -4014,6 +4032,8 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
                 goto out;
         status = encode_setacl(&xdr, args);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 /*
@@ -4035,6 +4055,8 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
 		goto out;
 	status = decode_setattr(&xdr, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4058,6 +4080,8 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
 	status = decode_getacl(&xdr, rqstp, acl_len);
 
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4088,6 +4112,8 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 */
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 
@@ -4121,6 +4147,8 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 
@@ -4142,6 +4170,8 @@ static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp, __be32 *p, struct n
                 goto out;
         status = decode_open_confirm(&xdr, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 
@@ -4166,6 +4196,8 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
                 goto out;
 	decode_getfattr(&xdr, res->f_attr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 
@@ -4190,8 +4222,10 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
                 goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 	if (status == NFS4ERR_DELAY)
-		status = 0;
+		return 0;
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
         return status;
 }
 
@@ -4213,6 +4247,8 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_
 		goto out;
 	status = decode_lock(&xdr, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4234,6 +4270,8 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 		goto out;
 	status = decode_lockt(&xdr, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4255,6 +4293,8 @@ static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 		goto out;
 	status = decode_locku(&xdr, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4276,6 +4316,8 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
 		goto out;
 	status = decode_readlink(&xdr, rqstp);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4297,6 +4339,8 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_r
 		goto out;
 	status = decode_readdir(&xdr, rqstp, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4318,8 +4362,10 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readr
 		goto out;
 	status = decode_read(&xdr, rqstp, res);
 	if (!status)
-		status = res->count;
+		return res->count;
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4344,8 +4390,10 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 	if (!status)
-		status = res->count;
+		return res->count;
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4370,6 +4418,8 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4388,7 +4438,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
+	if (hdr.status)
 		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
@@ -4408,6 +4458,8 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_pathconf(&xdr, pathconf);
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4426,6 +4478,8 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fssta
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_statfs(&xdr, fsstat);
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4445,6 +4499,8 @@ static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4
 		goto out;
 	status = decode_server_caps(&xdr, res);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4461,6 +4517,8 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_renew(&xdr);
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4478,7 +4536,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_setclientid(&xdr, clp);
-	if (!status)
+	if (hdr.status)
 		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
@@ -4500,7 +4558,7 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 		status = decode_putrootfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
+	if (hdr.status)
 		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
@@ -4524,6 +4582,8 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_delegreturn(&xdr);
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4547,6 +4607,8 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	xdr_enter_page(&xdr, PAGE_SIZE);
 	status = decode_getfattr(&xdr, &res->fattr, res->server);
 out:
+	if (hdr.status)
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
-- 
1.5.3.3
