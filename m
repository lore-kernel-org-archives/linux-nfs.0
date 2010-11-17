Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52633 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0KQSAH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:00:07 -0500
Received: by mail-iw0-f174.google.com with SMTP id 35so2387538iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:00:07 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/12] NFSD: Update XDR decoders in NFSv4 callback client
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:00:03 -0500
Message-ID: <20101117180003.29429.68707.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Remove old-style NFSv4 XDR macros in favor of the style now used in
fs/nfs/nfs4xdr.c.  These were forgotten during the recent nfs4xdr.c
rewrite.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfsd/nfs4callback.c |  415 ++++++++++++++++++++++++++++--------------------
 1 files changed, 239 insertions(+), 176 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d8148cc..c3c6a90 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -74,37 +74,6 @@ enum {
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
 
-/*
- * Generic decode routines from fs/nfs/nfs4xdr.c
- */
-#define DECODE_TAIL                             \
-	status = 0;                             \
-out:                                            \
-	return status;                          \
-xdr_error:                                      \
-	dprintk("NFSD: xdr error! (%s:%d)\n", __FILE__, __LINE__); \
-	status = -EIO;                          \
-	goto out
-
-#define READ32(x)         (x) = ntohl(*p++)
-#define READ64(x)         do {                  \
-	(x) = (u64)ntohl(*p++) << 32;           \
-	(x) |= ntohl(*p++);                     \
-} while (0)
-#define READTIME(x)       do {                  \
-	p++;                                    \
-	(x.tv_sec) = ntohl(*p++);               \
-	(x.tv_nsec) = ntohl(*p++);              \
-} while (0)
-#define READ_BUF(nbytes)  do { \
-	p = xdr_inline_decode(xdr, nbytes); \
-	if (!p) { \
-		dprintk("NFSD: %s: reply buffer overflowed in line %d.\n", \
-			__func__, __LINE__); \
-		return -EIO; \
-	} \
-} while (0)
-
 struct nfs4_cb_compound_hdr {
 	/* args */
 	u32		ident;	/* minorversion 0 only */
@@ -115,57 +84,14 @@ struct nfs4_cb_compound_hdr {
 	int		status;
 };
 
-static struct {
-int stat;
-int errno;
-} nfs_cb_errtbl[] = {
-	{ NFS4_OK,		0               },
-	{ NFS4ERR_PERM,		EPERM           },
-	{ NFS4ERR_NOENT,	ENOENT          },
-	{ NFS4ERR_IO,		EIO             },
-	{ NFS4ERR_NXIO,		ENXIO           },
-	{ NFS4ERR_ACCESS,	EACCES          },
-	{ NFS4ERR_EXIST,	EEXIST          },
-	{ NFS4ERR_XDEV,		EXDEV           },
-	{ NFS4ERR_NOTDIR,	ENOTDIR         },
-	{ NFS4ERR_ISDIR,	EISDIR          },
-	{ NFS4ERR_INVAL,	EINVAL          },
-	{ NFS4ERR_FBIG,		EFBIG           },
-	{ NFS4ERR_NOSPC,	ENOSPC          },
-	{ NFS4ERR_ROFS,		EROFS           },
-	{ NFS4ERR_MLINK,	EMLINK          },
-	{ NFS4ERR_NAMETOOLONG,	ENAMETOOLONG    },
-	{ NFS4ERR_NOTEMPTY,	ENOTEMPTY       },
-	{ NFS4ERR_DQUOT,	EDQUOT          },
-	{ NFS4ERR_STALE,	ESTALE          },
-	{ NFS4ERR_BADHANDLE,	EBADHANDLE      },
-	{ NFS4ERR_BAD_COOKIE,	EBADCOOKIE      },
-	{ NFS4ERR_NOTSUPP,	ENOTSUPP        },
-	{ NFS4ERR_TOOSMALL,	ETOOSMALL       },
-	{ NFS4ERR_SERVERFAULT,	ESERVERFAULT    },
-	{ NFS4ERR_BADTYPE,	EBADTYPE        },
-	{ NFS4ERR_LOCKED,	EAGAIN          },
-	{ NFS4ERR_RESOURCE,	EREMOTEIO       },
-	{ NFS4ERR_SYMLINK,	ELOOP           },
-	{ NFS4ERR_OP_ILLEGAL,	EOPNOTSUPP      },
-	{ NFS4ERR_DEADLOCK,	EDEADLK         },
-	{ -1,                   EIO             }
-};
-
-static int
-nfs_cb_stat_to_errno(int stat)
+/*
+ * Handle decode buffer overflows out-of-line.
+ */
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 {
-	int i;
-	for (i = 0; nfs_cb_errtbl[i].stat != -1; i++) {
-		if (nfs_cb_errtbl[i].stat == stat)
-			return nfs_cb_errtbl[i].errno;
-	}
-	/* If we cannot translate the error, the recovery routines should
-	* handle it.
-	* Note: remaining NFSv4 error codes have values > 10000, so should
-	* not conflict with native Linux error codes.
-	*/
-	return stat;
+	dprintk("NFS: %s prematurely hit the end of our receive buffer. "
+		"Remaining buffer length is %tu words.\n",
+		func, xdr->end - xdr->p);
 }
 
 static __be32 *xdr_encode_empty_array(__be32 *p)
@@ -263,6 +189,89 @@ static void encode_sessionid4(struct xdr_stream *xdr,
 }
 
 /*
+ * nfsstat4
+ */
+static const struct {
+	int stat;
+	int errno;
+} nfs_cb_errtbl[] = {
+	{ NFS4_OK,		0		},
+	{ NFS4ERR_PERM,		-EPERM		},
+	{ NFS4ERR_NOENT,	-ENOENT		},
+	{ NFS4ERR_IO,		-EIO		},
+	{ NFS4ERR_NXIO,		-ENXIO		},
+	{ NFS4ERR_ACCESS,	-EACCES		},
+	{ NFS4ERR_EXIST,	-EEXIST		},
+	{ NFS4ERR_XDEV,		-EXDEV		},
+	{ NFS4ERR_NOTDIR,	-ENOTDIR	},
+	{ NFS4ERR_ISDIR,	-EISDIR		},
+	{ NFS4ERR_INVAL,	-EINVAL		},
+	{ NFS4ERR_FBIG,		-EFBIG		},
+	{ NFS4ERR_NOSPC,	-ENOSPC		},
+	{ NFS4ERR_ROFS,		-EROFS		},
+	{ NFS4ERR_MLINK,	-EMLINK		},
+	{ NFS4ERR_NAMETOOLONG,	-ENAMETOOLONG	},
+	{ NFS4ERR_NOTEMPTY,	-ENOTEMPTY	},
+	{ NFS4ERR_DQUOT,	-EDQUOT		},
+	{ NFS4ERR_STALE,	-ESTALE		},
+	{ NFS4ERR_BADHANDLE,	-EBADHANDLE	},
+	{ NFS4ERR_BAD_COOKIE,	-EBADCOOKIE	},
+	{ NFS4ERR_NOTSUPP,	-ENOTSUPP	},
+	{ NFS4ERR_TOOSMALL,	-ETOOSMALL	},
+	{ NFS4ERR_SERVERFAULT,	-ESERVERFAULT	},
+	{ NFS4ERR_BADTYPE,	-EBADTYPE	},
+	{ NFS4ERR_LOCKED,	-EAGAIN		},
+	{ NFS4ERR_RESOURCE,	-EREMOTEIO	},
+	{ NFS4ERR_SYMLINK,	-ELOOP		},
+	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
+	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
+	{ -1,			-EIO		}
+};
+
+/*
+ * If we cannot translate the error, the recovery routines should
+ * handle it.
+ *
+ * Note: remaining NFSv4 error codes have values > 10000, so should
+ * not conflict with native Linux error codes.
+ */
+static int nfs_cb_stat_to_errno(int status)
+{
+	int i;
+
+	for (i = 0; nfs_cb_errtbl[i].stat != -1; i++) {
+		if (nfs_cb_errtbl[i].stat == status)
+			return nfs_cb_errtbl[i].errno;
+	}
+
+	dprintk("NFSD: Unrecognized NFS CB status value: %u\n", status);
+	return -status;
+}
+
+static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
+			       enum nfsstat4 *status)
+{
+	__be32 *p;
+	u32 op;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	op = be32_to_cpup(p++);
+	if (unlikely(op != expected))
+		goto out_unexpected;
+	*status = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+out_unexpected:
+	dprintk("NFSD: Callback server returned operation %d but "
+		"we issued a request for %d\n", op, expected);
+	return -EIO;
+}
+
+/*
  * CB_COMPOUND4args
  *
  *	struct CB_COMPOUND4args {
@@ -296,6 +305,37 @@ static void encode_cb_nops(struct nfs4_cb_compound_hdr *hdr)
 }
 
 /*
+ * CB_COMPOUND4res
+ *
+ *	struct CB_COMPOUND4res {
+ *		nfsstat4	status;
+ *		utf8str_cs	tag;
+ *		nfs_cb_resop4	resarray<>;
+ *	};
+ */
+static int decode_cb_compound4res(struct xdr_stream *xdr,
+				  struct nfs4_cb_compound_hdr *hdr)
+{
+	u32 length;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	hdr->status = be32_to_cpup(p++);
+	/* Ignore the tag */
+	length = be32_to_cpup(p++);
+	p = xdr_inline_decode(xdr, length + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	hdr->nops = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
  * CB_RECALL4args
  *
  *	struct CB_RECALL4args {
@@ -357,6 +397,97 @@ static void encode_cb_sequence4args(struct xdr_stream *xdr,
 }
 
 /*
+ * CB_SEQUENCE4resok
+ *
+ *	struct CB_SEQUENCE4resok {
+ *		sessionid4	csr_sessionid;
+ *		sequenceid4	csr_sequenceid;
+ *		slotid4		csr_slotid;
+ *		slotid4		csr_highest_slotid;
+ *		slotid4		csr_target_highest_slotid;
+ *	};
+ *
+ *	union CB_SEQUENCE4res switch (nfsstat4 csr_status) {
+ *	case NFS4_OK:
+ *		CB_SEQUENCE4resok	csr_resok4;
+ *	default:
+ *		void;
+ *	};
+ *
+ * Our current back channel implmentation supports a single backchannel
+ * with a single slot.
+ */
+static int decode_cb_sequence4resok(struct xdr_stream *xdr,
+				    struct nfsd4_callback *cb)
+{
+	struct nfsd4_session *session = cb->cb_clp->cl_cb_session;
+	struct nfs4_sessionid id;
+	int status;
+	__be32 *p;
+	u32 dummy;
+
+	status = -ESERVERFAULT;
+
+	/*
+	 * If the server returns different values for sessionID, slotID or
+	 * sequence number, the server is looney tunes.
+	 */
+	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
+	if (memcmp(id.data, session->se_sessionid.data,
+					NFS4_MAX_SESSIONID_LEN) != 0) {
+		dprintk("NFS: %s Invalid session id\n", __func__);
+		goto out;
+	}
+	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
+
+	dummy = be32_to_cpup(p++);
+	if (dummy != session->se_cb_seq_nr) {
+		dprintk("NFS: %s Invalid sequence number\n", __func__);
+		goto out;
+	}
+
+	dummy = be32_to_cpup(p++);
+	if (dummy != 0) {
+		dprintk("NFS: %s Invalid slotid\n", __func__);
+		goto out;
+	}
+
+	/*
+	 * FIXME: process highest slotid and target highest slotid
+	 */
+	status = 0;
+out:
+	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_cb_sequence4res(struct xdr_stream *xdr,
+				  struct nfsd4_callback *cb)
+{
+	enum nfsstat4 nfserr;
+	int status;
+
+	if (cb->cb_minorversion == 0)
+		return 0;
+
+	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &nfserr);
+	if (unlikely(status))
+		goto out;
+	if (unlikely(nfserr != NFS4_OK))
+		goto out_default;
+	status = decode_cb_sequence4resok(xdr, cb);
+out:
+	return status;
+out_default:
+	return nfs_cb_stat_to_errno(status);
+}
+
+/*
  * NFSv4.0 and NFSv4.1 XDR encode functions
  *
  * NFSv4.0 callback argument types are defined in section 15 of RFC
@@ -399,119 +530,51 @@ static int nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
 }
 
 
-static int
-decode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr){
-        __be32 *p;
-	u32 taglen;
-
-        READ_BUF(8);
-        READ32(hdr->status);
-	/* We've got no use for the tag; ignore it: */
-        READ32(taglen);
-        READ_BUF(taglen + 4);
-        p += XDR_QUADLEN(taglen);
-        READ32(hdr->nops);
-        return 0;
-}
-
-static int
-decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
-{
-	__be32 *p;
-	u32 op;
-	int32_t nfserr;
-
-	READ_BUF(8);
-	READ32(op);
-	if (op != expected) {
-		dprintk("NFSD: decode_cb_op_hdr: Callback server returned "
-		         " operation %d but we issued a request for %d\n",
-		         op, expected);
-		return -EIO;
-	}
-	READ32(nfserr);
-	if (nfserr != NFS_OK)
-		return -nfs_cb_stat_to_errno(nfserr);
-	return 0;
-}
-
 /*
- * Our current back channel implmentation supports a single backchannel
- * with a single slot.
+ * NFSv4.0 and NFSv4.1 XDR decode functions
+ *
+ * NFSv4.0 callback result types are defined in section 15 of RFC
+ * 3530: "Network File System (NFS) version 4 Protocol" and section 20
+ * of RFC 5661:  "Network File System (NFS) Version 4 Minor Version 1
+ * Protocol".
  */
-static int
-decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
-		   struct rpc_rqst *rqstp)
-{
-	struct nfsd4_session *ses = cb->cb_clp->cl_cb_session;
-	struct nfs4_sessionid id;
-	int status;
-	u32 dummy;
-	__be32 *p;
-
-	if (cb->cb_minorversion == 0)
-		return 0;
-
-	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
-	if (status)
-		return status;
-
-	/*
-	 * If the server returns different values for sessionID, slotID or
-	 * sequence number, the server is looney tunes.
-	 */
-	status = -ESERVERFAULT;
-
-	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
-	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
-	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
-	if (memcmp(id.data, ses->se_sessionid.data, NFS4_MAX_SESSIONID_LEN)) {
-		dprintk("%s Invalid session id\n", __func__);
-		goto out;
-	}
-	READ32(dummy);
-	if (dummy != ses->se_cb_seq_nr) {
-		dprintk("%s Invalid sequence number\n", __func__);
-		goto out;
-	}
-	READ32(dummy); 	/* slotid must be 0 */
-	if (dummy != 0) {
-		dprintk("%s Invalid slotid\n", __func__);
-		goto out;
-	}
-	/* FIXME: process highest slotid and target highest slotid */
-	status = 0;
-out:
-	return status;
-}
-
 
-static int
-nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
+static int nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p, void *__unused)
 {
 	return 0;
 }
 
-static int
-nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
-		struct nfsd4_callback *cb)
+/*
+ * 20.2. Operation 4: CB_RECALL - Recall a Delegation
+ */
+static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
+				  struct nfsd4_callback *cb)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
+	enum nfsstat4 nfserr;
 	int status;
 
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_cb_compound_hdr(&xdr, &hdr);
-	if (status)
+	status = decode_cb_compound4res(&xdr, &hdr);
+	if (unlikely(status))
 		goto out;
-	if (cb) {
-		status = decode_cb_sequence(&xdr, cb, rqstp);
-		if (status)
+
+	if (cb != NULL) {
+		status = decode_cb_sequence4res(&xdr, cb);
+		if (unlikely(status))
 			goto out;
 	}
-	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
+
+	status = decode_cb_op_status(&xdr, OP_CB_RECALL, &nfserr);
+	if (unlikely(status))
+		goto out;
+	if (unlikely(nfserr != NFS4_OK))
+		goto out_default;
 out:
 	return status;
+out_default:
+	return nfs_cb_stat_to_errno(status);
 }
 
 /*

