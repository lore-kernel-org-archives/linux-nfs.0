Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58708 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757773Ab2CUPVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:12 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 01/23] NFS: Relocate the stat_to_errno() function
Date: Wed, 21 Mar 2012 11:20:31 -0400
Message-Id: <1332343253-24970-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This was located in a file belonging to NFS v2, but it is also used by
v3.  I moved it to a generic NFS client file to keep it from
disappearing once v2 becomes a module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c  |   66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs2xdr.c |   64 ----------------------------------------------------
 2 files changed, 66 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2f37848..08e7f24 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -2072,6 +2072,72 @@ void nfs_fs_proc_exit(void)
 
 #endif /* CONFIG_PROC_FS */
 
+/* Mapping from NFS error code to "errno" error code. */
+#define errno_NFSERR_IO		EIO
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
+ * nfs_stat_to_errno - convert an NFS status code to a local errno
+ * @status: NFS status code to convert
+ *
+ * Returns a local errno value, or -EIO if the NFS status code is
+ * not recognized.  This function is used jointly by NFSv2 and NFSv3.
+ */
+int nfs_stat_to_errno(enum nfs_stat status)
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
 module_param(nfs4_disable_idmapping, bool, 0644);
 MODULE_PARM_DESC(nfs4_disable_idmapping,
 		"Turn off NFSv4 idmapping when using 'sec=sys'");
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f56000..a01084d 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1057,70 +1057,6 @@ out_default:
 	return nfs_stat_to_errno(status);
 }
 
-
-/*
- * We need to translate between nfs status return values and
- * the local errno values which may not be the same.
- */
-static const struct {
-	int stat;
-	int errno;
-} nfs_errtbl[] = {
-	{ NFS_OK,		0		},
-	{ NFSERR_PERM,		-EPERM		},
-	{ NFSERR_NOENT,		-ENOENT		},
-	{ NFSERR_IO,		-errno_NFSERR_IO},
-	{ NFSERR_NXIO,		-ENXIO		},
-/*	{ NFSERR_EAGAIN,	-EAGAIN		}, */
-	{ NFSERR_ACCES,		-EACCES		},
-	{ NFSERR_EXIST,		-EEXIST		},
-	{ NFSERR_XDEV,		-EXDEV		},
-	{ NFSERR_NODEV,		-ENODEV		},
-	{ NFSERR_NOTDIR,	-ENOTDIR	},
-	{ NFSERR_ISDIR,		-EISDIR		},
-	{ NFSERR_INVAL,		-EINVAL		},
-	{ NFSERR_FBIG,		-EFBIG		},
-	{ NFSERR_NOSPC,		-ENOSPC		},
-	{ NFSERR_ROFS,		-EROFS		},
-	{ NFSERR_MLINK,		-EMLINK		},
-	{ NFSERR_NAMETOOLONG,	-ENAMETOOLONG	},
-	{ NFSERR_NOTEMPTY,	-ENOTEMPTY	},
-	{ NFSERR_DQUOT,		-EDQUOT		},
-	{ NFSERR_STALE,		-ESTALE		},
-	{ NFSERR_REMOTE,	-EREMOTE	},
-#ifdef EWFLUSH
-	{ NFSERR_WFLUSH,	-EWFLUSH	},
-#endif
-	{ NFSERR_BADHANDLE,	-EBADHANDLE	},
-	{ NFSERR_NOT_SYNC,	-ENOTSYNC	},
-	{ NFSERR_BAD_COOKIE,	-EBADCOOKIE	},
-	{ NFSERR_NOTSUPP,	-ENOTSUPP	},
-	{ NFSERR_TOOSMALL,	-ETOOSMALL	},
-	{ NFSERR_SERVERFAULT,	-EREMOTEIO	},
-	{ NFSERR_BADTYPE,	-EBADTYPE	},
-	{ NFSERR_JUKEBOX,	-EJUKEBOX	},
-	{ -1,			-EIO		}
-};
-
-/**
- * nfs_stat_to_errno - convert an NFS status code to a local errno
- * @status: NFS status code to convert
- *
- * Returns a local errno value, or -EIO if the NFS status code is
- * not recognized.  This function is used jointly by NFSv2 and NFSv3.
- */
-int nfs_stat_to_errno(enum nfs_stat status)
-{
-	int i;
-
-	for (i = 0; nfs_errtbl[i].stat != -1; i++) {
-		if (nfs_errtbl[i].stat == (int)status)
-			return nfs_errtbl[i].errno;
-	}
-	dprintk("NFS: Unrecognized nfs status value: %u\n", status);
-	return nfs_errtbl[i].errno;
-}
-
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
-- 
1.7.9.4

