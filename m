Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29533 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760303Ab2CUUey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 16:34:54 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFS: Create an NFS v3 stat_to_errno()
Date: Wed, 21 Mar 2012 16:34:52 -0400
Message-Id: <1332362092-19359-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

In theory, NFS v3 can have different error versions than NFS v2. v4 is
already using its own nfs4_stat_to_errno() to mapp error codes, so
rather than create something in the generic client for v2 and v3 to
share I instead give v3 its own static function.

Signed-off-by: Bryan Schumaker <bjschuma@gmail.com>
---
This can replace my "relocate stat to errno" patch sent earlier this afternoon.

 fs/nfs/internal.h |    1 -
 fs/nfs/nfs2xdr.c  |    3 +-
 fs/nfs/nfs3xdr.c  |  103 +++++++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 87 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2476dc6..e43eb04 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -211,7 +211,6 @@ extern int __init nfs_init_directcache(void);
 extern void nfs_destroy_directcache(void);
 
 /* nfs2xdr.c */
-extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
 extern int nfs2_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f56000..73e3e67 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -61,6 +61,7 @@
 #define NFS_readdirres_sz	(1)
 #define NFS_statfsres_sz	(1+NFS_info_sz)
 
+static int nfs_stat_to_errno(enum nfs_stat);
 
 /*
  * While encoding arguments, set up the reply buffer in advance to
@@ -1109,7 +1110,7 @@ static const struct {
  * Returns a local errno value, or -EIO if the NFS status code is
  * not recognized.  This function is used jointly by NFSv2 and NFSv3.
  */
-int nfs_stat_to_errno(enum nfs_stat status)
+static int nfs_stat_to_errno(enum nfs_stat status)
 {
 	int i;
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index a77cc9a..f766a6f 100644
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
@@ -1385,7 +1387,7 @@ static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1424,7 +1426,7 @@ static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1472,7 +1474,7 @@ out_default:
 	error = decode_post_op_attr(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1513,7 +1515,7 @@ static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1554,7 +1556,7 @@ static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1636,7 +1638,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1706,7 +1708,7 @@ static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1770,7 +1772,7 @@ out_default:
 	error = decode_wcc_data(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1809,7 +1811,7 @@ static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1853,7 +1855,7 @@ static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -1896,7 +1898,7 @@ static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /**
@@ -2088,7 +2090,7 @@ out_default:
 	error = decode_post_op_attr(xdr, result->dir_attr);
 	if (unlikely(error))
 		goto out;
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2156,7 +2158,7 @@ static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2232,7 +2234,7 @@ static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2295,7 +2297,7 @@ static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 /*
@@ -2336,7 +2338,7 @@ static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 out:
 	return error;
 out_status:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 #ifdef CONFIG_NFS_V3_ACL
@@ -2401,7 +2403,7 @@ static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
 out:
 	return error;
 out_default:
-	return nfs_stat_to_errno(status);
+	return nfs3_stat_to_errno(status);
 }
 
 static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
@@ -2420,11 +2422,76 @@ static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
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
1.7.9.4

