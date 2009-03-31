From: Greg Banks <gnb@sgi.com>
Subject: [patch 11/29] knfsd: Update per-client & per-export stats from NFSv2
Date: Wed, 01 Apr 2009 07:28:11 +1100
Message-ID: <20090331202941.779324000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22577 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755610AbZCaVCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add instrumentation to the NFSv2 server procedures.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfs2acl.c |    2 ++
 fs/nfsd/nfsproc.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

Index: bfields/fs/nfsd/nfsproc.c
===================================================================
--- bfields.orig/fs/nfsd/nfsproc.c
+++ bfields/fs/nfsd/nfsproc.c
@@ -34,6 +34,7 @@ typedef struct svc_buf	svc_buf;
 static __be32
 nfsd_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
 {
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_GETATTR);
 	return nfs_ok;
 }
 
@@ -67,6 +68,8 @@ nfsd_proc_getattr(struct svc_rqst *rqstp
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = fh_verify(rqstp, &resp->fh, 0,
 			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_GETATTR);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
@@ -85,6 +88,8 @@ nfsd_proc_setattr(struct svc_rqst *rqstp
 
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_setattr(rqstp, &resp->fh, &argp->attrs,0, (time_t)0);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_GETATTR);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
@@ -107,6 +112,7 @@ nfsd_proc_lookup(struct svc_rqst *rqstp,
 	nfserr = nfsd_lookup(rqstp, &argp->fh, argp->name, argp->len,
 				 &resp->fh);
 
+	nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_LOOKUP);
 	fh_put(&argp->fh);
 	return nfsd_return_dirop(nfserr, resp);
 }
@@ -126,6 +132,7 @@ nfsd_proc_readlink(struct svc_rqst *rqst
 	resp->len = NFS_MAXPATHLEN;
 	nfserr = nfsd_readlink(rqstp, &argp->fh, argp->buffer, &resp->len);
 
+	nfsd_stats_update_read(rqstp, &argp->fh, resp->len);
 	fh_put(&argp->fh);
 	return nfserr;
 }
@@ -163,6 +170,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 				  argp->offset,
 			   	  rqstp->rq_vec, argp->vlen,
 				  &resp->count);
+	nfsd_stats_update_read(rqstp, &resp->fh, resp->count);
 
 	if (nfserr) return nfserr;
 	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
@@ -191,6 +199,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, 
 				   rqstp->rq_vec, argp->vlen,
 			           &cnt,
 				   &stable);
+	nfsd_stats_update_write(rqstp, &resp->fh, cnt, stable);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
@@ -349,6 +358,8 @@ out_unlock:
 	fh_unlock(dirfhp);
 
 done:
+	if (!nfserr)
+		nfsd_stats_update(rqstp, dirfhp, NFSD_STATS_OP_MKINODE);
 	fh_put(dirfhp);
 	return nfsd_return_dirop(nfserr, resp);
 }
@@ -364,6 +375,8 @@ nfsd_proc_remove(struct svc_rqst *rqstp,
 
 	/* Unlink. -SIFDIR means file must not be a directory */
 	nfserr = nfsd_unlink(rqstp, &argp->fh, -S_IFDIR, argp->name, argp->len);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_REMOVE);
 	fh_put(&argp->fh);
 	return nfserr;
 }
@@ -381,6 +394,8 @@ nfsd_proc_rename(struct svc_rqst *rqstp,
 
 	nfserr = nfsd_rename(rqstp, &argp->ffh, argp->fname, argp->flen,
 				    &argp->tfh, argp->tname, argp->tlen);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->ffh, NFSD_STATS_OP_MKINODE);
 	fh_put(&argp->ffh);
 	fh_put(&argp->tfh);
 	return nfserr;
@@ -401,6 +416,8 @@ nfsd_proc_link(struct svc_rqst *rqstp, s
 
 	nfserr = nfsd_link(rqstp, &argp->tfh, argp->tname, argp->tlen,
 				  &argp->ffh);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->ffh, NFSD_STATS_OP_MKINODE);
 	fh_put(&argp->ffh);
 	fh_put(&argp->tfh);
 	return nfserr;
@@ -425,6 +442,8 @@ nfsd_proc_symlink(struct svc_rqst *rqstp
 						 argp->tname, argp->tlen,
 				 		 &newfh, &argp->attrs);
 
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->ffh, NFSD_STATS_OP_MKINODE);
 
 	fh_put(&argp->ffh);
 	fh_put(&newfh);
@@ -452,6 +471,8 @@ nfsd_proc_mkdir(struct svc_rqst *rqstp, 
 	fh_init(&resp->fh, NFS_FHSIZE);
 	nfserr = nfsd_create(rqstp, &argp->fh, argp->name, argp->len,
 				    &argp->attrs, S_IFDIR, 0, &resp->fh);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_MKINODE);
 	fh_put(&argp->fh);
 	return nfsd_return_dirop(nfserr, resp);
 }
@@ -468,6 +489,8 @@ nfsd_proc_rmdir(struct svc_rqst *rqstp, 
 	dprintk("nfsd: RMDIR    %s %.*s\n", SVCFH_fmt(&argp->fh), argp->len, argp->name);
 
 	nfserr = nfsd_unlink(rqstp, &argp->fh, S_IFDIR, argp->name, argp->len);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_RMDIR);
 	fh_put(&argp->fh);
 	return nfserr;
 }
@@ -508,6 +531,9 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 	if (resp->offset)
 		*resp->offset = htonl(offset);
 
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_READDIR);
+
 	fh_put(&argp->fh);
 	return nfserr;
 }
@@ -525,6 +551,8 @@ nfsd_proc_statfs(struct svc_rqst * rqstp
 
 	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats,
 			NFSD_MAY_BYPASS_GSS_ON_ROOT);
+	if (!nfserr)
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_FSINFO);
 	fh_put(&argp->fh);
 	return nfserr;
 }
Index: bfields/fs/nfsd/nfs2acl.c
===================================================================
--- bfields.orig/fs/nfsd/nfs2acl.c
+++ bfields/fs/nfsd/nfs2acl.c
@@ -86,6 +86,7 @@ static __be32 nfsacld_proc_getacl(struct
 		resp->acl_default = acl;
 	}
 
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_XATTR);
 	/* resp->acl_{access,default} are released in nfssvc_release_getacl. */
 	RETURN_STATUS(0);
 
@@ -123,6 +124,7 @@ static __be32 nfsacld_proc_setacl(struct
 	   nfssvc_decode_setaclargs. */
 	posix_acl_release(argp->acl_access);
 	posix_acl_release(argp->acl_default);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_XATTR);
 	return nfserr;
 }
 

--
Greg
