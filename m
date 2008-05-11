From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3] nfs: use compound hdr.status to override op status.
Date: Sun, 11 May 2008 16:21:31 -0700
Message-ID: <48277F7B.2060307@panasas.com>
References: <47F0F6AB.3030302@panasas.com>	
	<1206974900-368-1-git-send-email-bhalevy@panasas.com>	
	<1207002349.15341.15.camel@heimdal.trondhjem.org>	
	<47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>	
	<4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1210440276.12927.0.camel@localhost>
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
compound header instead.

This patch also fixes 3 call sites where we looked at the compound
hdr.status in the success case which is useless (yet benign).
These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   88 +++++++++++++++++++++++++++---------------------------
 1 files changed, 44 insertions(+), 44 deletions(-)

Changes in PATCH v3:
* nfs4_fixup_status made static inline (with very minor increase
in code size over macro)

Changes in PATCH v2:
* rebased onto 2.6.26 (off of linux-2.6 28a4acb4)
* fixed checkpatch.pl nits
* do not fixup status in nfs4_xdr_enc_setacl


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5a2d649..e6f7f0b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3791,6 +3791,13 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
+static inline int nfs4_fixup_status(int status, int hdr_status)
+{
+	if (likely(!status))
+		return 0;
+	return nfs4_stat_to_errno(hdr_status);
+}
+
 /*
  * Decode OPEN_DOWNGRADE response
  */
@@ -3812,7 +3819,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3839,7 +3846,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3862,7 +3869,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3882,7 +3889,7 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if ((status = decode_getfh(&xdr, res->fh)) == 0)
 		status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3903,7 +3910,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	decode_getfattr(&xdr, &res->dir_attr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3933,7 +3940,7 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 		goto out;
 	decode_getfattr(&xdr, res->old_fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3966,7 +3973,7 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -3995,7 +4002,7 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 		goto out;
 	decode_getfattr(&xdr, res->dir_fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4024,8 +4031,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
-
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4047,7 +4053,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
                 goto out;
         status = encode_setacl(&xdr, args);
 out:
-        return status;
+	return status;
 }
 /*
  * Decode SETACL response
@@ -4068,7 +4074,7 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
 		goto out;
 	status = decode_setattr(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4091,7 +4097,7 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
 	status = decode_getacl(&xdr, rqstp, acl_len);
 
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4121,7 +4127,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 */
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4154,7 +4160,7 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4175,7 +4181,7 @@ static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp, __be32 *p, struct n
                 goto out;
         status = decode_open_confirm(&xdr, res);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4199,7 +4205,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
                 goto out;
 	decode_getfattr(&xdr, res->f_attr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4223,9 +4229,9 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
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
@@ -4246,7 +4252,7 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_
 		goto out;
 	status = decode_lock(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4267,7 +4273,7 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 		goto out;
 	status = decode_lockt(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4288,7 +4294,7 @@ static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 		goto out;
 	status = decode_locku(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4309,7 +4315,7 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
 		goto out;
 	status = decode_readlink(&xdr, rqstp);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4330,7 +4336,7 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_r
 		goto out;
 	status = decode_readdir(&xdr, rqstp, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4351,9 +4357,9 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readr
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
@@ -4377,9 +4383,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
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
@@ -4403,7 +4409,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4421,9 +4427,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4441,7 +4445,7 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_pathconf(&xdr, pathconf);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4459,7 +4463,7 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fssta
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_statfs(&xdr, fsstat);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4478,7 +4482,7 @@ static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4
 		goto out;
 	status = decode_server_caps(&xdr, res);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4494,7 +4498,7 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_renew(&xdr);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4511,9 +4515,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_setclientid(&xdr, clp);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4533,9 +4535,7 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 		status = decode_putrootfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4557,7 +4557,7 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_delegreturn(&xdr);
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*
@@ -4580,7 +4580,7 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	xdr_enter_page(&xdr, PAGE_SIZE);
 	status = decode_getfattr(&xdr, &res->fattr, res->server);
 out:
-	return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
-- 
1.5.3.3
