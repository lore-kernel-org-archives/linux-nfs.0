From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 14 of 23] Delegation recall callback rpc.
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002eG-Ll@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAc2-0005BY-Ld
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:10 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAby-0006As-O4
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:10 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c     |  316 ++++++++++++++++++++++++++++++++++++++++++-
 ./include/linux/nfsd/state.h |    1 
 2 files changed, 316 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2004-12-15 11:51:29.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2004-12-15 13:19:50.000000000 +1100
@@ -49,24 +49,58 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 #define NFSPROC4_CB_NULL 0
+#define NFSPROC4_CB_COMPOUND 1
 
-/* forward declarations */
+/* declarations */
 static void nfs4_cb_null(struct rpc_task *task);
+extern spinlock_t recall_lock;
 
 /* Index of predefined Linux callback client operations */
 
 enum {
         NFSPROC4_CLNT_CB_NULL = 0,
+	NFSPROC4_CLNT_CB_RECALL,
+};
+
+enum nfs_cb_opnum4 {
+	OP_CB_RECALL            = 4,
 };
 
 #define NFS4_MAXTAGLEN		20
 
 #define NFS4_enc_cb_null_sz		0
 #define NFS4_dec_cb_null_sz		0
+#define cb_compound_enc_hdr_sz		4
+#define cb_compound_dec_hdr_sz		(3 + (NFS4_MAXTAGLEN >> 2))
+#define op_enc_sz			1
+#define op_dec_sz			2
+#define enc_nfs4_fh_sz			(1 + (NFS4_FHSIZE >> 2))
+#define enc_stateid_sz			16
+#define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
+					1 + enc_stateid_sz +            \
+					enc_nfs4_fh_sz)
+
+#define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
+					op_dec_sz)
 
 /*
 * Generic encode routines from fs/nfs/nfs4xdr.c
 */
+static inline u32 *
+xdr_writemem(u32 *p, const void *ptr, int nbytes)
+{
+	int tmp = XDR_QUADLEN(nbytes);
+	if (!tmp)
+		return p;
+	p[tmp-1] = 0;
+	memcpy(p, ptr, nbytes);
+	return p + tmp;
+}
+
+#define WRITE32(n)               *p++ = htonl(n)
+#define WRITEMEM(ptr,nbytes)     do {                           \
+	p = xdr_writemem(p, ptr, nbytes);                       \
+} while (0)
 #define RESERVE_SPACE(nbytes)   do {                            \
 	p = xdr_reserve_space(xdr, nbytes);                     \
 	if (!p) dprintk("NFSD: RESERVE_SPACE(%d) failed in function %s\n", (int) (nbytes), __FUNCTION__); \
@@ -74,10 +108,130 @@ enum {
 } while (0)
 
 /*
+ * Generic decode routines from fs/nfs/nfs4xdr.c
+ */
+#define DECODE_TAIL                             \
+	status = 0;                             \
+out:                                            \
+	return status;                          \
+xdr_error:                                      \
+	dprintk("NFSD: xdr error! (%s:%d)\n", __FILE__, __LINE__); \
+	status = -EIO;                          \
+	goto out
+
+#define READ32(x)         (x) = ntohl(*p++)
+#define READ64(x)         do {                  \
+	(x) = (u64)ntohl(*p++) << 32;           \
+	(x) |= ntohl(*p++);                     \
+} while (0)
+#define READTIME(x)       do {                  \
+	p++;                                    \
+	(x.tv_sec) = ntohl(*p++);               \
+	(x.tv_nsec) = ntohl(*p++);              \
+} while (0)
+#define READ_BUF(nbytes)  do { \
+	p = xdr_inline_decode(xdr, nbytes); \
+	if (!p) { \
+		dprintk("NFSD: %s: reply buffer overflowed in line %d.", \
+			__FUNCTION__, __LINE__); \
+		return -EIO; \
+	} \
+} while (0)
+
+struct nfs4_cb_compound_hdr {
+	int		status;
+	u32		ident;
+	u32		nops;
+	u32		taglen;
+	char *		tag;
+};
+
+static struct {
+int stat;
+int errno;
+} nfs_cb_errtbl[] = {
+	{ NFS4_OK,		0               },
+	{ NFS4ERR_PERM,		EPERM           },
+	{ NFS4ERR_NOENT,	ENOENT          },
+	{ NFS4ERR_IO,		EIO             },
+	{ NFS4ERR_NXIO,		ENXIO           },
+	{ NFS4ERR_ACCESS,	EACCES          },
+	{ NFS4ERR_EXIST,	EEXIST          },
+	{ NFS4ERR_XDEV,		EXDEV           },
+	{ NFS4ERR_NOTDIR,	ENOTDIR         },
+	{ NFS4ERR_ISDIR,	EISDIR          },
+	{ NFS4ERR_INVAL,	EINVAL          },
+	{ NFS4ERR_FBIG,		EFBIG           },
+	{ NFS4ERR_NOSPC,	ENOSPC          },
+	{ NFS4ERR_ROFS,		EROFS           },
+	{ NFS4ERR_MLINK,	EMLINK          },
+	{ NFS4ERR_NAMETOOLONG,	ENAMETOOLONG    },
+	{ NFS4ERR_NOTEMPTY,	ENOTEMPTY       },
+	{ NFS4ERR_DQUOT,	EDQUOT          },
+	{ NFS4ERR_STALE,	ESTALE          },
+	{ NFS4ERR_BADHANDLE,	EBADHANDLE      },
+	{ NFS4ERR_BAD_COOKIE,	EBADCOOKIE      },
+	{ NFS4ERR_NOTSUPP,	ENOTSUPP        },
+	{ NFS4ERR_TOOSMALL,	ETOOSMALL       },
+	{ NFS4ERR_SERVERFAULT,	ESERVERFAULT    },
+	{ NFS4ERR_BADTYPE,	EBADTYPE        },
+	{ NFS4ERR_LOCKED,	EAGAIN          },
+	{ NFS4ERR_RESOURCE,	EREMOTEIO       },
+	{ NFS4ERR_SYMLINK,	ELOOP           },
+	{ NFS4ERR_OP_ILLEGAL,	EOPNOTSUPP      },
+	{ NFS4ERR_DEADLOCK,	EDEADLK         },
+	{ -1,                   EIO             }
+};
+
+static int
+nfs_cb_stat_to_errno(int stat)
+{
+	int i;
+	for (i = 0; nfs_cb_errtbl[i].stat != -1; i++) {
+		if (nfs_cb_errtbl[i].stat == stat)
+			return nfs_cb_errtbl[i].errno;
+	}
+	/* If we cannot translate the error, the recovery routines should
+	* handle it.
+	* Note: remaining NFSv4 error codes have values > 10000, so should
+	* not conflict with native Linux error codes.
+	*/
+	return stat;
+}
+
+/*
  * XDR encode
  */
 
 static int
+encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
+{
+	u32 * p;
+
+	RESERVE_SPACE(16);
+	WRITE32(0);            /* tag length is always 0 */
+	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(hdr->ident);
+	WRITE32(hdr->nops);
+	return 0;
+}
+
+static int
+encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
+{
+	u32 *p;
+	int len = cb_rec->cbr_fhlen;
+
+	RESERVE_SPACE(12+sizeof(cb_rec->cbr_stateid) + len);
+	WRITE32(OP_CB_RECALL);
+	WRITEMEM(&cb_rec->cbr_stateid, sizeof(stateid_t));
+	WRITE32(cb_rec->cbr_trunc);
+	WRITE32(len);
+	WRITEMEM(cb_rec->cbr_fhval, len);
+	return 0;
+}
+
+static int
 nfs4_xdr_enc_cb_null(struct rpc_rqst *req, u32 *p)
 {
 	struct xdr_stream xdrs, *xdr = &xdrs;
@@ -88,11 +242,76 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *re
 }
 
 static int
+nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, u32 *p, struct nfs4_cb_recall *args)
+{
+	struct xdr_stream xdr;
+	struct nfs4_cb_compound_hdr hdr = {
+		.nops   = 1,
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cb_compound_hdr(&xdr, &hdr);
+	return (encode_cb_recall(&xdr, args));
+}
+
+
+static int
+decode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr){
+        u32 *p;
+
+        READ_BUF(8);
+        READ32(hdr->status);
+        READ32(hdr->taglen);
+        READ_BUF(hdr->taglen + 4);
+        hdr->tag = (char *)p;
+        p += XDR_QUADLEN(hdr->taglen);
+        READ32(hdr->nops);
+        return 0;
+}
+
+static int
+decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
+{
+	u32 *p;
+	u32 op;
+	int32_t nfserr;
+
+	READ_BUF(8);
+	READ32(op);
+	if (op != expected) {
+		dprintk("NFSD: decode_cb_op_hdr: Callback server returned "
+		         " operation %d but we issued a request for %d\n",
+		         op, expected);
+		return -EIO;
+	}
+	READ32(nfserr);
+	if (nfserr != NFS_OK)
+		return -nfs_cb_stat_to_errno(nfserr);
+	return 0;
+}
+
+static int
 nfs4_xdr_dec_cb_null(struct rpc_rqst *req, u32 *p)
 {
 	return 0;
 }
 
+static int
+nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, u32 *p)
+{
+	struct xdr_stream xdr;
+	struct nfs4_cb_compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_cb_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
+out	:
+	return status;
+}
+
 /*
  * RPC procedure tables
  */
@@ -110,6 +329,7 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *re
 
 struct rpc_procinfo     nfs4_cb_procedures[] = {
     PROC(CB_NULL,      NULL,     enc_cb_null,     dec_cb_null),
+    PROC(CB_RECALL,    COMPOUND,   enc_cb_recall,      dec_cb_recall),
 };
 
 struct rpc_version              nfs_cb_version4 = {
@@ -267,3 +487,97 @@ nfs4_cb_null(struct rpc_task *task)
 out:
 	put_nfs4_client(clp);
 }
+
+/*
+ *  Called with dp->dl_count incremented
+ */
+static void
+nfs4_cb_recall_done(struct rpc_task *task)
+{
+	struct nfs4_cb_recall *cbr = (struct nfs4_cb_recall *)task->tk_calldata;
+	struct nfs4_delegation *dp = cbr->cbr_dp;
+	int status;
+
+	/* all is well... */
+	if (task->tk_status == 0)
+		goto out;
+
+	/* network partition, retry nfsd4_cb_recall once.  */
+	if (task->tk_status == -EIO) {
+		if (atomic_read(&dp->dl_recall_cnt) == 0)
+			goto retry;
+		else
+			/* callback channel no longer available */
+			atomic_set(&dp->dl_client->cl_callback.cb_set, 0);
+	}
+
+	/* Race: a recall occurred miliseconds after a delegation was granted.
+	* Client may have received recall prior to delegation. retry recall
+	* once.
+	*/
+	if ((task->tk_status == -EBADHANDLE) || (task->tk_status == -NFS4ERR_BAD_STATEID)){
+		if (atomic_read(&dp->dl_recall_cnt) == 0)
+			goto retry;
+	}
+	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+
+out:
+	if (atomic_dec_and_test(&dp->dl_count))
+		atomic_set(&dp->dl_state, NFS4_REAP_DELEG);
+	BUG_ON(atomic_read(&dp->dl_count) < 0);
+	dprintk("NFSD: nfs4_cb_recall_done: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
+	return;
+
+retry:
+	atomic_inc(&dp->dl_recall_cnt);
+	/* sleep 2 seconds before retrying recall */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(2*HZ);
+	status = nfsd4_cb_recall(dp);
+	dprintk("NFSD: nfs4_cb_recall_done: retry status: %d  dp %p dl_flock %p\n",status,dp, dp->dl_flock);
+}
+
+/*
+ * called with dp->dl_count inc'ed.
+ * nfs4_lock_state() may or may not have been called.
+ */
+int
+nfsd4_cb_recall(struct nfs4_delegation *dp)
+{
+	struct nfs4_client *clp;
+	struct rpc_clnt *clnt;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
+	};
+	struct nfs4_cb_recall *cbr = &dp->dl_recall;
+	int status;
+
+	dprintk("NFSD: nfsd4_cb_recall NFS4_enc_cb_recall_sz %d NFS4_dec_cb_recall_sz %d \n",NFS4_enc_cb_recall_sz,NFS4_dec_cb_recall_sz);
+
+	clp = dp->dl_client;
+	clnt = clp->cl_callback.cb_client;
+	status = EIO;
+	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
+		goto out_free;
+
+	msg.rpc_argp = cbr;
+	msg.rpc_resp = cbr;
+	msg.rpc_cred = nfsd4_lookupcred(clp,0);
+
+	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
+	cbr->cbr_dp = dp;
+
+	if ((status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
+		nfs4_cb_recall_done, cbr ))) {
+		dprintk("NFSD: recall_delegation: rpc_call_async failed %d\n",
+			status);
+		goto out_fail;
+	}
+out:
+	return status;
+out_fail:
+	status = nfserrno(status);
+	out_free:
+	kfree(cbr);
+	goto out;
+}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-12-15 11:59:23.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-12-15 13:19:50.000000000 +1100
@@ -291,6 +291,7 @@ extern int nfs4_check_open_reclaim(clien
 extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
+extern int nfsd4_cb_recall(struct nfs4_delegation *dp);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
