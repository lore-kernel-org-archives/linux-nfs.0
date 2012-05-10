Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62131 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755526Ab2EJUrZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 16:47:25 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 1/3] NFS: Create an NFS v3 stat_to_errno()
Date: Thu, 10 May 2012 16:47:18 -0400
Message-Id: <1336682840-10799-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

In theory, NFS v3 can have different error versions than NFS v2. v4 is
already using its own nfs4_stat_to_errno() to mapp error codes, so
rather than create something in the generic client for v2 and v3 to
share I instead give v3 its own function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h |    1 -
 fs/nfs/nfs2xdr.c  |    3 +-
 fs/nfs/nfs3xdr.c  |  103 +++++++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 87 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1855e8f..4cf76e9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -207,7 +207,6 @@ extern void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos);
 
 /* nfs2xdr.c */
-extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
 extern int nfs2_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index c99008e..baf759b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -61,6 +61,7 @@
 #define NFS_readdirres_sz	(1)
 #define NFS_statfsres_sz	(1+NFS_info_sz)
 
+static int nfs_stat_to_errno(enum nfs_stat);
 
 /*
  * While encoding arguments, set up the reply buffer in advance to
@@ -1111,7 +1112,7 @@ static const struct {
  * Returns a local errno value, or -EIO if the NFS status code is
  * not recognized.  This function is used jointly by NFSv2 and NFSv3.
  */
-int nfs_stat_to_errno(enum nfs_stat status)
+static int nfs_stat_to_errno(enum nfs_stat status)
 {
 	int i;
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index ee284c2..902de48 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -86,6 +86,8 @@
 				XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
 #define ACL3_setaclres_sz	(1+NFS3_post_op_attr_sz)
 
+static int nfs3_stat_to_errno(enum nfs_stat);
+
 /*
  * Map file type to S_IFMT bits
  */
@@ -1388,7 +1390,7 @@ static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1427,7 +1429,7 @@ static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1475,7 +1477,7 @@ out_default:
 	error = decode_post_op_attr(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1516,7 +1518,7 @@ static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1557,7 +1559,7 @@ static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1639,7 +1641,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1709,7 +1711,7 @@ static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1773,7 +1775,7 @@ out_default:
 	error = decode_wcc_data(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1812,7 +1814,7 @@ static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1856,7 +1858,7 @@ static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1899,7 +1901,7 @@ static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /**
@@ -2091,7 +2093,7 @@ out_default:
 	error = decode_post_op_attr(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2159,7 +2161,7 @@ static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2235,7 +2237,7 @@ static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2298,7 +2300,7 @@ static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2339,7 +2341,7 @@ static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 #ifdef CONFIG_NFS_V3_ACL
@@ -2404,7 +2406,7 @@ static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
@@ -2423,11 +2425,76 @@ static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 #endif  /* CONFIG_NFS_V3_ACL */
 
+
+/*
+ * We need to translate between nfs status return values and
+ * the local errno values which may not be the same.
+ */
+static const struct {
+	int stat;
+	int errno;
+} nfs_errtbl[] = {
+	{ NFS_OK,		0		},
+	{ NFSERR_PERM,		-EPERM		},
+	{ NFSERR_NOENT,		-ENOENT		},
+	{ NFSERR_IO,		-errno_NFSERR_IO},
+	{ NFSERR_NXIO,		-ENXIO		},
+/*	{ NFSERR_EAGAIN,	-EAGAIN		}, */
+	{ NFSERR_ACCES,		-EACCES		},
+	{ NFSERR_EXIST,		-EEXIST		},
+	{ NFSERR_XDEV,		-EXDEV		},
+	{ NFSERR_NODEV,		-ENODEV		},
+	{ NFSERR_NOTDIR,	-ENOTDIR	},
+	{ NFSERR_ISDIR,		-EISDIR		},
+	{ NFSERR_INVAL,		-EINVAL		},
+	{ NFSERR_FBIG,		-EFBIG		},
+	{ NFSERR_NOSPC,		-ENOSPC		},
+	{ NFSERR_ROFS,		-EROFS		},
+	{ NFSERR_MLINK,		-EMLINK		},
+	{ NFSERR_NAMETOOLONG,	-ENAMETOOLONG	},
+	{ NFSERR_NOTEMPTY,	-ENOTEMPTY	},
+	{ NFSERR_DQUOT,		-EDQUOT		},
+	{ NFSERR_STALE,		-ESTALE		},
+	{ NFSERR_REMOTE,	-EREMOTE	},
+#ifdef EWFLUSH
+	{ NFSERR_WFLUSH,	-EWFLUSH	},
+#endif
+	{ NFSERR_BADHANDLE,	-EBADHANDLE	},
+	{ NFSERR_NOT_SYNC,	-ENOTSYNC	},
+	{ NFSERR_BAD_COOKIE,	-EBADCOOKIE	},
+	{ NFSERR_NOTSUPP,	-ENOTSUPP	},
+	{ NFSERR_TOOSMALL,	-ETOOSMALL	},
+	{ NFSERR_SERVERFAULT,	-EREMOTEIO	},
+	{ NFSERR_BADTYPE,	-EBADTYPE	},
+	{ NFSERR_JUKEBOX,	-EJUKEBOX	},
+	{ -1,			-EIO		}
+};
+
+/**
+ * nfs3_stat_to_errno - convert an NFS status code to a local errno
+ * @status: NFS status code to convert
+ *
+ * Returns a local errno value, or -EIO if the NFS status code is
+ * not recognized.  This function is used jointly by NFSv2 and NFSv3.
+ */
+static int nfs3_stat_to_errno(enum nfs_stat status)
+{
+	int i;
+
+	for (i = 0; nfs_errtbl[i].stat != -1; i++) {
+		if (nfs_errtbl[i].stat == (int)status)
+			return nfs_errtbl[i].errno;
+	}
+	dprintk("NFS: Unrecognized nfs status value: %u\n", status);
+	return nfs_errtbl[i].errno;
+}
+
+
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
-- 
1.7.10.1

