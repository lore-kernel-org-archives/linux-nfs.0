From: Greg Banks <gnb@sgi.com>
Subject: [patch 10/29] knfsd: Update per-client & per-export stats from NFSv3
Date: Wed, 01 Apr 2009 07:28:10 +1100
Message-ID: <20090331202941.423831000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22575 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755487AbZCaVCj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add instrumentation to the NFSv3 server procedures.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfs3acl.c  |    2 ++
 fs/nfsd/nfs3proc.c |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

Index: bfields/fs/nfsd/nfs3proc.c
===================================================================
--- bfields.orig/fs/nfsd/nfs3proc.c
+++ bfields/fs/nfsd/nfs3proc.c
@@ -47,6 +47,7 @@ static int	nfs3_ftypes[] = {
 static __be32
 nfsd3_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
 {
+	nfsd_stats_update(rqstp, NULL, NFSD_STATS_OP_FSINFO);
 	return nfs_ok;
 }
 
@@ -73,6 +74,7 @@ nfsd3_proc_getattr(struct svc_rqst *rqst
 			  resp->fh.fh_dentry, &resp->stat);
 	nfserr = nfserrno(err);
 
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_GETATTR);
 	RETURN_STATUS(nfserr);
 }
 
@@ -91,6 +93,7 @@ nfsd3_proc_setattr(struct svc_rqst *rqst
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_setattr(rqstp, &resp->fh, &argp->attrs,
 			      argp->check_guard, argp->guardtime);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_SETATTR);
 	RETURN_STATUS(nfserr);
 }
 
@@ -115,6 +118,7 @@ nfsd3_proc_lookup(struct svc_rqst *rqstp
 				    argp->name,
 				    argp->len,
 				    &resp->fh);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_LOOKUP);
 	RETURN_STATUS(nfserr);
 }
 
@@ -134,6 +138,7 @@ nfsd3_proc_access(struct svc_rqst *rqstp
 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
 	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_ACCESS);
 	RETURN_STATUS(nfserr);
 }
 
@@ -152,6 +157,7 @@ nfsd3_proc_readlink(struct svc_rqst *rqs
 	fh_copy(&resp->fh, &argp->fh);
 	resp->len = NFS3_MAXPATHLEN;
 	nfserr = nfsd_readlink(rqstp, &resp->fh, argp->buffer, &resp->len);
+	nfsd_stats_update_read(rqstp, &resp->fh, resp->len);
 	RETURN_STATUS(nfserr);
 }
 
@@ -192,6 +198,8 @@ nfsd3_proc_read(struct svc_rqst *rqstp, 
 		resp->eof = (argp->offset + resp->count) >= inode->i_size;
 	}
 
+	nfsd_stats_update_read(rqstp, &resp->fh, resp->count);
+
 	RETURN_STATUS(nfserr);
 }
 
@@ -219,6 +227,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp,
 				   &cnt,
 				   &resp->committed);
 	resp->count = cnt;
+	nfsd_stats_update_write(rqstp, &resp->fh, resp->count, resp->committed);
 	RETURN_STATUS(nfserr);
 }
 
@@ -263,6 +272,7 @@ nfsd3_proc_create(struct svc_rqst *rqstp
 				attr, newfhp,
 				argp->createmode, argp->verf, NULL, NULL);
 
+	nfsd_stats_update(rqstp, dirfhp, NFSD_STATS_OP_MKINODE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -286,6 +296,7 @@ nfsd3_proc_mkdir(struct svc_rqst *rqstp,
 	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
 				    &argp->attrs, S_IFDIR, 0, &resp->fh);
 
+	nfsd_stats_update(rqstp, &resp->dirfh, NFSD_STATS_OP_MKINODE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -305,6 +316,7 @@ nfsd3_proc_symlink(struct svc_rqst *rqst
 	nfserr = nfsd_symlink(rqstp, &resp->dirfh, argp->fname, argp->flen,
 						   argp->tname, argp->tlen,
 						   &resp->fh, &argp->attrs);
+	nfsd_stats_update(rqstp, &resp->dirfh, NFSD_STATS_OP_MKINODE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -342,6 +354,7 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp,
 	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
 				    &argp->attrs, type, rdev, &resp->fh);
 
+	nfsd_stats_update(rqstp, &resp->dirfh, NFSD_STATS_OP_MKINODE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -362,6 +375,7 @@ nfsd3_proc_remove(struct svc_rqst *rqstp
 	/* Unlink. -S_IFDIR means file must not be a directory */
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_unlink(rqstp, &resp->fh, -S_IFDIR, argp->name, argp->len);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_REMOVE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -381,6 +395,7 @@ nfsd3_proc_rmdir(struct svc_rqst *rqstp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_unlink(rqstp, &resp->fh, S_IFDIR, argp->name, argp->len);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_RMDIR);
 	RETURN_STATUS(nfserr);
 }
 
@@ -403,6 +418,7 @@ nfsd3_proc_rename(struct svc_rqst *rqstp
 	fh_copy(&resp->tfh, &argp->tfh);
 	nfserr = nfsd_rename(rqstp, &resp->ffh, argp->fname, argp->flen,
 				    &resp->tfh, argp->tname, argp->tlen);
+	nfsd_stats_update(rqstp, &resp->ffh, NFSD_STATS_OP_MKINODE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -423,6 +439,7 @@ nfsd3_proc_link(struct svc_rqst *rqstp, 
 	fh_copy(&resp->tfh, &argp->tfh);
 	nfserr = nfsd_link(rqstp, &resp->tfh, argp->tname, argp->tlen,
 				  &resp->fh);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_MKINODE);
 	RETURN_STATUS(nfserr);
 }
 
@@ -458,6 +475,7 @@ nfsd3_proc_readdir(struct svc_rqst *rqst
 	if (resp->offset)
 		xdr_encode_hyper(resp->offset, argp->cookie);
 
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_READDIR);
 	RETURN_STATUS(nfserr);
 }
 
@@ -518,6 +536,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *
 		}
 	}
 
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_READDIRP);
 	RETURN_STATUS(nfserr);
 }
 
@@ -534,6 +553,7 @@ nfsd3_proc_fsstat(struct svc_rqst * rqst
 				SVCFH_fmt(&argp->fh));
 
 	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats, 0);
+	nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_FSINFO);
 	fh_put(&argp->fh);
 	RETURN_STATUS(nfserr);
 }
@@ -575,6 +595,8 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqst
 			resp->f_properties = NFS3_FSF_BILLYBOY;
 		}
 		resp->f_maxfilesize = sb->s_maxbytes;
+
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_FSINFO);
 	}
 
 	fh_put(&argp->fh);
@@ -617,6 +639,8 @@ nfsd3_proc_pathconf(struct svc_rqst * rq
 			resp->p_case_preserving  = 0;
 			break;
 		}
+
+		nfsd_stats_update(rqstp, &argp->fh, NFSD_STATS_OP_FSINFO);
 	}
 
 	fh_put(&argp->fh);
@@ -644,6 +668,8 @@ nfsd3_proc_commit(struct svc_rqst * rqst
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_commit(rqstp, &resp->fh, argp->offset, argp->count);
 
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_COMMIT);
+
 	RETURN_STATUS(nfserr);
 }
 
Index: bfields/fs/nfsd/nfs3acl.c
===================================================================
--- bfields.orig/fs/nfsd/nfs3acl.c
+++ bfields/fs/nfsd/nfs3acl.c
@@ -82,6 +82,7 @@ static __be32 nfsd3_proc_getacl(struct s
 		resp->acl_default = acl;
 	}
 
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_XATTR);
 	/* resp->acl_{access,default} are released in nfs3svc_release_getacl. */
 	RETURN_STATUS(0);
 
@@ -117,6 +118,7 @@ static __be32 nfsd3_proc_setacl(struct s
 	   nfs3svc_decode_setaclargs. */
 	posix_acl_release(argp->acl_access);
 	posix_acl_release(argp->acl_default);
+	nfsd_stats_update(rqstp, &resp->fh, NFSD_STATS_OP_XATTR);
 	RETURN_STATUS(nfserr);
 }
 

--
Greg
