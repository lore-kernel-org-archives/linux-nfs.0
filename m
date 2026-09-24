Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE5D54A2043
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269821; cv=none; b=nFEvxIbqxKKgwGczvm8QALQdo2tvKu7B1DCtLa2uiRCy1IruywvRAP9BrJbQApB+FflelJKuK85MlG+s5Y1hZLyDeFcsNQ5tJa3HLjgR457JWtt+mAMarMoRfSOP8cb0WJgpi+eM4xS7KOuOKDv09k/kjtppma3Ddbs3s7lIPwo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269821; c=relaxed/simple;
	bh=lFRAdbA1IltjQUpNr7g/h9Onc2NYHFuJkarhBqEBHpM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fbsSCwS3Xd8dynHT8xHK0ZXmmEz8WxMfbyZNGahl0fUs3B+34SexkTRjrZMcfu1BIBzuWidGLGznXAc1P+quNnjNPeDMiOIqPiNzuU5777l2J1DoG6462JO/7ZXLtRAYgp9dBsaSnBoPxSwIerGftHe5gBtPprS8sKMLQuYN4bo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=K9S3igj5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="K9S3igj5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CA3D1F00899;
	Thu, 24 Sep 2026 17:10:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269818;
	bh=MITMFn28ipmuZPA9TKo91Yu7JvNHW/1MitI+jY5fyjM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=K9S3igj5f4zbe7jx0XtG/IilxoJjbMqrjL0rV/XjjNv33S5sHyhV7joPe5HxtNXWQ
	 U3xllMpvKsvoZxpYK96WmEFUK7y64L/lnI4MlER35+rgRVhkX9JWXLETSG2f18nHgc
	 fd2JoI6xT/wzdhDRGZuZ+89t7rINrg1xLFkKjK33tn1t22/s1+r9XQQSWHijWZw0cs
	 6IkGwffQsUHIcMuk6Jlnv7xMjSxz2if6HOFJu9AozIKHZhwCrBJCFuIWaclGlfOcCv
	 0h2hMuoDaguQIXmUIr0LkrNRjEQfK2SuyWBIWHM/C9p3ZfiybVkmum4ZGsOWTCqSN1
	 VpEkvK06haYsA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 04/33] NFSD: Replace nfs3.h with nfs3xdr_gen.h
Date: Thu, 24 Sep 2026 13:09:43 -0400
Message-ID: <20260924171012.3978-5-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924171012.3978-1-cel@kernel.org>
References: <20260924171012.3978-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs3xdr_gen.h includes a set of header files that are tool-generated
from the nfs3.x specification. The goal is to replace NFSD's XDR
infrastructure with tool-generated files which are to have better
memory safety and are less brittle to maintain.

The generated header names the NFSv3 wire constants as the
specification spells them, so point NFSD's references at the new
names: NFS3_ACCESS_* becomes ACCESS3_*, NFS3PROC_* becomes
NFSPROC3_*, and the createmode and write-stability constants shed
their prefixes entirely. Move to xdr3.h the constants the generator
does not emit: the NF3NON and NF3BAD ftype3 sentinels and the name
and path length limits, none of which appear on the wire.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c    | 26 ++++++------
 fs/nfsd/nfs3proc.c   | 96 +++++++++++++++++++++++---------------------
 fs/nfsd/nfs3xdr.c    |  9 ++---
 fs/nfsd/nfsctl.c     |  2 +-
 fs/nfsd/nfserr.h     |  2 +-
 fs/nfsd/nfsfh.c      |  2 +-
 fs/nfsd/xdr3.h       |  6 +++
 include/linux/nfs3.h |  3 --
 8 files changed, 76 insertions(+), 70 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index eada1ab51415..13904e2740bf 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -22,19 +22,19 @@
  * the behavior of the two versions to diverge if needed.
  */
 static const struct nfsd_access_map nfsd2_regaccess[] = {
-	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
-	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
-	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
-	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
+	{ ACCESS3_READ,		NFSD_MAY_READ				},
+	{ ACCESS3_EXECUTE,	NFSD_MAY_EXEC				},
+	{ ACCESS3_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
+	{ ACCESS3_EXTEND,	NFSD_MAY_WRITE				},
 	{ 0,			0					}
 };
 
 static const struct nfsd_access_map nfsd2_diraccess[] = {
-	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
-	{ NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
-	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
-	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
-	{ NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
+	{ ACCESS3_READ,		NFSD_MAY_READ				},
+	{ ACCESS3_LOOKUP,	NFSD_MAY_EXEC				},
+	{ ACCESS3_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
+	{ ACCESS3_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
+	{ ACCESS3_DELETE,	NFSD_MAY_REMOVE				},
 	{ 0,			0					}
 };
 
@@ -46,10 +46,10 @@ static const struct nfsd_access_map nfsd2_diraccess[] = {
  * filesystem checks.
  */
 static const struct nfsd_access_map nfsd2_otheraccess[] = {
-	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
-	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
-	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
-	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ ACCESS3_READ,		NFSD_MAY_READ				},
+	{ ACCESS3_EXECUTE,	NFSD_MAY_EXEC				},
+	{ ACCESS3_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ ACCESS3_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
 	{ 0,			0					}
 };
 
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 60cd01b6a37d..223398ada3e3 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -9,7 +9,6 @@
 #include <linux/ext2_fs.h>
 #include <linux/magic.h>
 #include <linux/namei.h>
-#include <linux/nfs3.h>
 
 #include "cache.h"
 #include "xdr3.h"
@@ -18,8 +17,13 @@
 #include "filecache.h"
 #include "trace.h"
 
+#include "nfs3xdr_gen.h"
+
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+#define NFS3_FSF_DEFAULT		0x001b
+#define NFS3_FSF_BILLYBOY		0x0018
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -51,19 +55,19 @@ static bool nfsd3_time_in_range(const struct iattr *iap)
 }
 
 static const struct nfsd_access_map nfsd3_regaccess[] = {
-	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
-	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
-	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
-	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
+	{ ACCESS3_READ,		NFSD_MAY_READ				},
+	{ ACCESS3_EXECUTE,	NFSD_MAY_EXEC				},
+	{ ACCESS3_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
+	{ ACCESS3_EXTEND,	NFSD_MAY_WRITE				},
 	{ 0,			0					}
 };
 
 static const struct nfsd_access_map nfsd3_diraccess[] = {
-	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
-	{ NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
-	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
-	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
-	{ NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
+	{ ACCESS3_READ,		NFSD_MAY_READ				},
+	{ ACCESS3_LOOKUP,	NFSD_MAY_EXEC				},
+	{ ACCESS3_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
+	{ ACCESS3_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
+	{ ACCESS3_DELETE,	NFSD_MAY_REMOVE				},
 	{ 0,			0					}
 };
 
@@ -75,10 +79,10 @@ static const struct nfsd_access_map nfsd3_diraccess[] = {
  * filesystem checks.
  */
 static const struct nfsd_access_map nfsd3_otheraccess[] = {
-	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
-	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
-	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
-	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ ACCESS3_READ,		NFSD_MAY_READ				},
+	{ ACCESS3_EXECUTE,	NFSD_MAY_EXEC				},
+	{ ACCESS3_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ ACCESS3_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
 	{ 0,			0					}
 };
 
@@ -88,13 +92,13 @@ static const struct nfsd_access_maps nfsd3_access_maps = {
 	.other		= nfsd3_otheraccess,
 };
 
-static int nfsd3_iocb_flags(enum nfs3_stable_how how)
+static int nfsd3_iocb_flags(enum stable_how how)
 {
 	switch (how) {
-	case NFS_FILE_SYNC:
+	case FILE_SYNC:
 		/* persist data and timestamps */
 		return IOCB_DSYNC | IOCB_SYNC;
-	case NFS_DATA_SYNC:
+	case DATA_SYNC:
 		/* persist data only */
 		return IOCB_DSYNC;
 	default:
@@ -280,7 +284,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp)
 	 * + 1 (xdr opaque byte count) = 26
 	 */
 	resp->count = argp->count;
-	svc_reserve_auth(rqstp, ((1 + NFS3_POST_OP_ATTR_WORDS + 3) << 2) +
+	svc_reserve_auth(rqstp, ((1 + NFS3_post_op_attr_sz + 3) << 2) +
 			 resp->count + 4);
 
 	fh_copy(&resp->fh, &argp->fh);
@@ -378,7 +382,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	exp = exp_get(fhp->fh_export);
-	if (argp->createmode == NFS3_CREATE_UNCHECKED) {
+	if (argp->createmode == UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
 		 */
@@ -399,7 +403,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (argp->createmode == NFS3_CREATE_EXCLUSIVE) {
+	if (argp->createmode == EXCLUSIVE) {
 		u32 *verifier = (u32 *)argp->verf;
 
 		/*
@@ -415,15 +419,15 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		status = nfs_ok;
 
 		switch (argp->createmode) {
-		case NFS3_CREATE_UNCHECKED:
+		case UNCHECKED:
 			if (!d_is_reg(child))
 				break;
 			iap->ia_valid &= ATTR_SIZE;
 			goto set_attr;
-		case NFS3_CREATE_GUARDED:
+		case GUARDED:
 			status = nfserr_exist;
 			break;
-		case NFS3_CREATE_EXCLUSIVE:
+		case EXCLUSIVE:
 			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 			    inode_get_atime_sec(d_inode(child)) == v_atime &&
 			    d_inode(child)->i_size == 0) {
@@ -450,7 +454,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	/* A newly created file already has a file size of zero. */
 	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
 		iap->ia_valid &= ~ATTR_SIZE;
-	if (argp->createmode == NFS3_CREATE_EXCLUSIVE) {
+	if (argp->createmode == EXCLUSIVE) {
 		iap->ia_valid = ATTR_MTIME | ATTR_ATIME |
 				ATTR_MTIME_SET | ATTR_ATIME_SET;
 		iap->ia_mtime.tv_sec = v_mtime;
@@ -921,7 +925,7 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
 #define WC (7+pAT)	/* WCC attributes */
 
 static const struct svc_procedure nfsd_procedures3[22] = {
-	[NFS3PROC_NULL] = {
+	[NFSPROC3_NULL] = {
 		.pc_func = nfsd3_proc_null,
 		.pc_decode = nfssvc_decode_voidarg,
 		.pc_encode = nfssvc_encode_voidres,
@@ -932,7 +936,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST,
 		.pc_name = "NULL",
 	},
-	[NFS3PROC_GETATTR] = {
+	[NFSPROC3_GETATTR] = {
 		.pc_func = nfsd3_proc_getattr,
 		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = nfs3svc_encode_getattrres,
@@ -944,7 +948,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+AT,
 		.pc_name = "GETATTR",
 	},
-	[NFS3PROC_SETATTR] = {
+	[NFSPROC3_SETATTR] = {
 		.pc_func = nfsd3_proc_setattr,
 		.pc_decode = nfs3svc_decode_sattrargs,
 		.pc_encode = nfs3svc_encode_wccstatres,
@@ -956,7 +960,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC,
 		.pc_name = "SETATTR",
 	},
-	[NFS3PROC_LOOKUP] = {
+	[NFSPROC3_LOOKUP] = {
 		.pc_func = nfsd3_proc_lookup,
 		.pc_decode = nfs3svc_decode_diropargs,
 		.pc_encode = nfs3svc_encode_lookupres,
@@ -968,7 +972,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+FH+pAT+pAT,
 		.pc_name = "LOOKUP",
 	},
-	[NFS3PROC_ACCESS] = {
+	[NFSPROC3_ACCESS] = {
 		.pc_func = nfsd3_proc_access,
 		.pc_decode = nfs3svc_decode_accessargs,
 		.pc_encode = nfs3svc_encode_accessres,
@@ -980,7 +984,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+1,
 		.pc_name = "ACCESS",
 	},
-	[NFS3PROC_READLINK] = {
+	[NFSPROC3_READLINK] = {
 		.pc_func = nfsd3_proc_readlink,
 		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = nfs3svc_encode_readlinkres,
@@ -992,7 +996,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+1+NFS3_MAXPATHLEN/4,
 		.pc_name = "READLINK",
 	},
-	[NFS3PROC_READ] = {
+	[NFSPROC3_READ] = {
 		.pc_func = nfsd3_proc_read,
 		.pc_decode = nfs3svc_decode_readargs,
 		.pc_encode = nfs3svc_encode_readres,
@@ -1004,7 +1008,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+4+NFSSVC_MAXBLKSIZE/4,
 		.pc_name = "READ",
 	},
-	[NFS3PROC_WRITE] = {
+	[NFSPROC3_WRITE] = {
 		.pc_func = nfsd3_proc_write,
 		.pc_decode = nfs3svc_decode_writeargs,
 		.pc_encode = nfs3svc_encode_writeres,
@@ -1016,7 +1020,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC+4,
 		.pc_name = "WRITE",
 	},
-	[NFS3PROC_CREATE] = {
+	[NFSPROC3_CREATE] = {
 		.pc_func = nfsd3_proc_create,
 		.pc_decode = nfs3svc_decode_createargs,
 		.pc_encode = nfs3svc_encode_createres,
@@ -1028,7 +1032,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "CREATE",
 	},
-	[NFS3PROC_MKDIR] = {
+	[NFSPROC3_MKDIR] = {
 		.pc_func = nfsd3_proc_mkdir,
 		.pc_decode = nfs3svc_decode_mkdirargs,
 		.pc_encode = nfs3svc_encode_createres,
@@ -1040,7 +1044,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "MKDIR",
 	},
-	[NFS3PROC_SYMLINK] = {
+	[NFSPROC3_SYMLINK] = {
 		.pc_func = nfsd3_proc_symlink,
 		.pc_decode = nfs3svc_decode_symlinkargs,
 		.pc_encode = nfs3svc_encode_createres,
@@ -1052,7 +1056,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "SYMLINK",
 	},
-	[NFS3PROC_MKNOD] = {
+	[NFSPROC3_MKNOD] = {
 		.pc_func = nfsd3_proc_mknod,
 		.pc_decode = nfs3svc_decode_mknodargs,
 		.pc_encode = nfs3svc_encode_createres,
@@ -1064,7 +1068,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+(1+FH+pAT)+WC,
 		.pc_name = "MKNOD",
 	},
-	[NFS3PROC_REMOVE] = {
+	[NFSPROC3_REMOVE] = {
 		.pc_func = nfsd3_proc_remove,
 		.pc_decode = nfs3svc_decode_diropargs,
 		.pc_encode = nfs3svc_encode_wccstatres,
@@ -1076,7 +1080,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC,
 		.pc_name = "REMOVE",
 	},
-	[NFS3PROC_RMDIR] = {
+	[NFSPROC3_RMDIR] = {
 		.pc_func = nfsd3_proc_rmdir,
 		.pc_decode = nfs3svc_decode_diropargs,
 		.pc_encode = nfs3svc_encode_wccstatres,
@@ -1088,7 +1092,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC,
 		.pc_name = "RMDIR",
 	},
-	[NFS3PROC_RENAME] = {
+	[NFSPROC3_RENAME] = {
 		.pc_func = nfsd3_proc_rename,
 		.pc_decode = nfs3svc_decode_renameargs,
 		.pc_encode = nfs3svc_encode_renameres,
@@ -1100,7 +1104,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+WC+WC,
 		.pc_name = "RENAME",
 	},
-	[NFS3PROC_LINK] = {
+	[NFSPROC3_LINK] = {
 		.pc_func = nfsd3_proc_link,
 		.pc_decode = nfs3svc_decode_linkargs,
 		.pc_encode = nfs3svc_encode_linkres,
@@ -1112,7 +1116,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+WC,
 		.pc_name = "LINK",
 	},
-	[NFS3PROC_READDIR] = {
+	[NFSPROC3_READDIR] = {
 		.pc_func = nfsd3_proc_readdir,
 		.pc_decode = nfs3svc_decode_readdirargs,
 		.pc_encode = nfs3svc_encode_readdirres,
@@ -1123,7 +1127,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_cachetype = RC_NOCACHE,
 		.pc_name = "READDIR",
 	},
-	[NFS3PROC_READDIRPLUS] = {
+	[NFSPROC3_READDIRPLUS] = {
 		.pc_func = nfsd3_proc_readdirplus,
 		.pc_decode = nfs3svc_decode_readdirplusargs,
 		.pc_encode = nfs3svc_encode_readdirres,
@@ -1134,7 +1138,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_cachetype = RC_NOCACHE,
 		.pc_name = "READDIRPLUS",
 	},
-	[NFS3PROC_FSSTAT] = {
+	[NFSPROC3_FSSTAT] = {
 		.pc_func = nfsd3_proc_fsstat,
 		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = nfs3svc_encode_fsstatres,
@@ -1145,7 +1149,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+2*6+1,
 		.pc_name = "FSSTAT",
 	},
-	[NFS3PROC_FSINFO] = {
+	[NFSPROC3_FSINFO] = {
 		.pc_func = nfsd3_proc_fsinfo,
 		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = nfs3svc_encode_fsinfores,
@@ -1156,7 +1160,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+12,
 		.pc_name = "FSINFO",
 	},
-	[NFS3PROC_PATHCONF] = {
+	[NFSPROC3_PATHCONF] = {
 		.pc_func = nfsd3_proc_pathconf,
 		.pc_decode = nfs3svc_decode_fhandleargs,
 		.pc_encode = nfs3svc_encode_pathconfres,
@@ -1167,7 +1171,7 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_xdrressize = ST+pAT+6,
 		.pc_name = "PATHCONF",
 	},
-	[NFS3PROC_COMMIT] = {
+	[NFSPROC3_COMMIT] = {
 		.pc_func = nfsd3_proc_commit,
 		.pc_decode = nfs3svc_decode_commitargs,
 		.pc_encode = nfs3svc_encode_commitres,
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index f0895f5e32f6..d163b51684d5 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -8,7 +8,6 @@
  */
 
 #include <linux/namei.h>
-#include <linux/nfs3.h>
 #include <linux/sunrpc/svc_xprt.h>
 
 #include "nfsd.h"
@@ -560,7 +559,7 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		return false;
 	if (xdr_stream_decode_u32(xdr, &args->stable) < 0)
 		return false;
-	if (args->stable > NFS_FILE_SYNC)
+	if (args->stable > FILE_SYNC)
 		return false;
 
 	/* opaque data */
@@ -588,10 +587,10 @@ nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	if (xdr_stream_decode_u32(xdr, &args->createmode) < 0)
 		return false;
 	switch (args->createmode) {
-	case NFS3_CREATE_UNCHECKED:
-	case NFS3_CREATE_GUARDED:
+	case UNCHECKED:
+	case GUARDED:
 		return svcxdr_decode_sattr3(rqstp, xdr, &args->attrs);
-	case NFS3_CREATE_EXCLUSIVE:
+	case EXCLUSIVE:
 		args->verf = xdr_inline_decode(xdr, NFS3_CREATEVERFSIZE);
 		if (!args->verf)
 			return false;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2379b838c028..15bbc87e08cd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -20,7 +20,7 @@
 #include <linux/module.h>
 #include <linux/fsnotify.h>
 #include <linux/nfslocalio.h>
-#include <linux/nfs3.h>
+#include <linux/sunrpc/xdrgen/nfs3.h>
 
 #include "idmap.h"
 #include "nfsd.h"
diff --git a/fs/nfsd/nfserr.h b/fs/nfsd/nfserr.h
index 35debf1141a3..155a7fa88d52 100644
--- a/fs/nfsd/nfserr.h
+++ b/fs/nfsd/nfserr.h
@@ -11,7 +11,7 @@
 #define LINUX_NFSD_NFSERR_H
 
 #include <linux/sunrpc/xdrgen/nfs2.h>
-#include <linux/nfs3.h>
+#include <linux/sunrpc/xdrgen/nfs3.h>
 #include <linux/nfs4.h>
 
 /*
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 2bd6907f443f..f1ba5a14bb85 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -9,7 +9,7 @@
  */
 
 #include <linux/exportfs.h>
-#include <linux/nfs3.h>
+#include <linux/sunrpc/xdrgen/nfs3.h>
 
 #include <linux/sunrpc/svcauth_gss.h>
 #include <crypto/utils.h>
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 22272695e451..60c7fe131e2e 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -12,6 +12,12 @@
 
 #include "vfs.h"
 
+#define NF3NON		(0)
+#define NF3BAD		(8)
+
+#define NFS3_MAXNAMLEN			NAME_MAX
+#define NFS3_MAXPATHLEN			PATH_MAX
+
 struct nfsd3_sattrargs {
 	struct svc_fh		fh;
 	struct iattr		attrs;
diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
index b6539a75edea..1eb8e99390be 100644
--- a/include/linux/nfs3.h
+++ b/include/linux/nfs3.h
@@ -51,7 +51,4 @@ enum nfs3_stable_how {
 	NFS_INVALID_STABLE_HOW = -1
 };
 
-/* Number of 32bit words in post_op_attr */
-#define NFS3_POST_OP_ATTR_WORDS		22
-
 #endif /* _LINUX_NFS3_H */
-- 
2.55.0

