From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Split buffer overflow checking out of struct nfs4_compound
Date: Wed, 20 Nov 2002 05:46:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15835.5015.309510.69666@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18EMkn-0003eF-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 20:46:21 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Here is the first patch that is part of the crusade 'struct
nfs4_compound must die'. It splits out the fields that are meant to do
overflow checking, and iovec adjusting on the XDR buffers, and moves
that functionality into the dedicated structure 'xdr_stream', and the
associated functions 'xdr_inline_encode()', 'xdr_inline_decode()'.

As an added bonus, the patch gets rid of the ugly ENCODE_HEAD,
ENCODE_TAIL, ADJUST_ARGS and DECODE_HEAD macros, and quite a lot of
the DECODE_TAIL macros.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.48-01-fix_time/fs/nfs/nfs4proc.c linux-2.5.48-02-nfsv4_xdr/fs/nfs/nfs4proc.c
--- linux-2.5.48-01-fix_time/fs/nfs/nfs4proc.c	2002-11-18 09:26:57.000000000 -0500
+++ linux-2.5.48-02-nfsv4_xdr/fs/nfs/nfs4proc.c	2002-11-18 11:53:14.000000000 -0500
@@ -65,11 +65,6 @@
 	memset(cp, 0, sizeof(*cp));
 	cp->ops = ops;
 	cp->server = server;
-
-#if NFS4_DEBUG
-	cp->taglen = strlen(tag);
-	cp->tag = tag;
-#endif
 }
 
 static void
@@ -373,6 +368,7 @@
 
 	BUG_ON(cp->flags);
 	
+	open->op_client_state = cp->server->nfs4_state;
 	open->op_share_access = flags & 3;
 	open->op_opentype = (flags & O_CREAT) ? NFS4_OPEN_CREATE : NFS4_OPEN_NOCREATE;
 	open->op_createmode = NFS4_CREATE_UNCHECKED;
@@ -527,6 +523,10 @@
 static void
 nfs4_setup_renew(struct nfs4_compound *cp)
 {
+	struct nfs4_client **client_state = GET_OP(cp, renew);
+
+	*client_state = cp->server->nfs4_state;
+
 	OPNUM(cp) = OP_RENEW;
 	cp->req_nops++;
 	cp->renew_index = cp->req_nops;
@@ -575,6 +575,7 @@
 	sprintf(setclientid->sc_uaddr, "%s.%d.%d", server->ip_addr, port >> 8, port & 255);
 	setclientid->sc_prog = program;
 	setclientid->sc_cb_ident = 0;
+	setclientid->sc_state = server->nfs4_state;
 	
 	OPNUM(cp) = OP_SETCLIENTID;
 	cp->req_nops++;
@@ -583,6 +584,10 @@
 static void
 nfs4_setup_setclientid_confirm(struct nfs4_compound *cp)
 {
+	struct nfs4_client **client_state = GET_OP(cp, setclientid_confirm);
+
+	*client_state = cp->server->nfs4_state;
+
 	OPNUM(cp) = OP_SETCLIENTID_CONFIRM;
 	cp->req_nops++;
 	cp->renew_index = cp->req_nops;
diff -u --recursive --new-file linux-2.5.48-01-fix_time/fs/nfs/nfs4xdr.c linux-2.5.48-02-nfsv4_xdr/fs/nfs/nfs4xdr.c
--- linux-2.5.48-01-fix_time/fs/nfs/nfs4xdr.c	2002-11-18 09:49:48.000000000 -0500
+++ linux-2.5.48-02-nfsv4_xdr/fs/nfs/nfs4xdr.c	2002-11-19 23:20:54.000000000 -0500
@@ -57,8 +57,6 @@
  */
 #define COOKIE_MAX		0x7fffffff
 
-#define NFS4_CLIENTID(server)	((server)->nfs4_state->cl_clientid)
-
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
 /* Mapping from NFS error code to "errno" error code. */
@@ -95,25 +93,22 @@
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define ENCODE_HEAD						\
-	u32 *p;
-#define ENCODE_TAIL						\
-	return 0
-
 #define WRITE32(n)               *p++ = htonl(n)
 #define WRITE64(n)               do {				\
-	*p++ = htonl((u32)((n) >> 32));				\
-	*p++ = htonl((u32)(n));					\
+	*p++ = htonl((uint32_t)((n) >> 32));				\
+	*p++ = htonl((uint32_t)(n));					\
 } while (0)
 #define WRITEMEM(ptr,nbytes)     do {				\
 	p = xdr_writemem(p, ptr, nbytes);			\
 } while (0)
 
-#define RESERVE_SPACE(nbytes)	do { BUG_ON(cp->p + XDR_QUADLEN(nbytes) > cp->end); p = cp->p; } while (0)
-#define ADJUST_ARGS()           cp->p = p
+#define RESERVE_SPACE(nbytes)	do {				\
+	p = xdr_inline_encode(xdr, nbytes);			\
+	BUG_ON(!p);						\
+} while (0)
 
 static inline
-u32 *xdr_writemem(u32 *p, const void *ptr, int nbytes)
+uint32_t *xdr_writemem(uint32_t *p, const void *ptr, int nbytes)
 {
 	int tmp = XDR_QUADLEN(nbytes);
 	if (!tmp)
@@ -146,18 +141,18 @@
 }
 
 static int
-encode_attrs(struct nfs4_compound *cp, struct iattr *iap)
+encode_attrs(struct xdr_stream *xdr, struct iattr *iap)
 {
 	char owner_name[256];
 	char owner_group[256];
 	int owner_namelen = 0;
 	int owner_grouplen = 0;
-	u32 *q;
+	uint32_t *p;
+	uint32_t *q;
 	int len;
-	u32 bmval0 = 0;
-	u32 bmval1 = 0;
+	uint32_t bmval0 = 0;
+	uint32_t bmval1 = 0;
 	int status;
-	ENCODE_HEAD;
 
 	/*
 	 * We reserve enough space to write the entire attribute buffer at once.
@@ -240,8 +235,6 @@
 		WRITE32(NFS4_SET_TO_SERVER_TIME);
 	}
 	
-	ADJUST_ARGS();
-	
 	/*
 	 * Now we backfill the bitmap and the attribute buffer length.
 	 */
@@ -256,69 +249,63 @@
 }
 
 static int
-encode_access(struct nfs4_compound *cp, struct nfs4_access *access)
+encode_access(struct xdr_stream *xdr, struct nfs4_access *access)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(8);
 	WRITE32(OP_ACCESS);
 	WRITE32(access->ac_req_access);
-	ADJUST_ARGS();
 	
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_close(struct nfs4_compound *cp, struct nfs4_close *close)
+encode_close(struct xdr_stream *xdr, struct nfs4_close *close)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(20);
 	WRITE32(OP_CLOSE);
 	WRITE32(close->cl_seqid);
 	WRITEMEM(close->cl_stateid, sizeof(nfs4_stateid));
-	ADJUST_ARGS();
 	
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_commit(struct nfs4_compound *cp, struct nfs4_commit *commit)
+encode_commit(struct xdr_stream *xdr, struct nfs4_commit *commit)
 {
-        ENCODE_HEAD;
+	uint32_t *p;
         
         RESERVE_SPACE(16);
         WRITE32(OP_COMMIT);
         WRITE64(commit->co_start);
         WRITE32(commit->co_len);
-        ADJUST_ARGS();
 
-        ENCODE_TAIL;
+        return 0;
 }
 
 static int
-encode_create(struct nfs4_compound *cp, struct nfs4_create *create)
+encode_create(struct xdr_stream *xdr, struct nfs4_create *create)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 	
 	RESERVE_SPACE(8);
 	WRITE32(OP_CREATE);
 	WRITE32(create->cr_ftype);
-	ADJUST_ARGS();
 
 	switch (create->cr_ftype) {
 	case NF4LNK:
 		RESERVE_SPACE(4 + create->cr_textlen);
 		WRITE32(create->cr_textlen);
 		WRITEMEM(create->cr_text, create->cr_textlen);
-		ADJUST_ARGS();
 		break;
 
 	case NF4BLK: case NF4CHR:
 		RESERVE_SPACE(8);
 		WRITE32(create->cr_specdata1);
 		WRITE32(create->cr_specdata2);
-		ADJUST_ARGS();
 		break;
 
 	default:
@@ -328,74 +315,69 @@
 	RESERVE_SPACE(4 + create->cr_namelen);
 	WRITE32(create->cr_namelen);
 	WRITEMEM(create->cr_name, create->cr_namelen);
-	ADJUST_ARGS();
 
-	return encode_attrs(cp, create->cr_attrs);
+	return encode_attrs(xdr, create->cr_attrs);
 }
 
 static int
-encode_getattr(struct nfs4_compound *cp, struct nfs4_getattr *getattr)
+encode_getattr(struct xdr_stream *xdr, struct nfs4_getattr *getattr)
 {
-        ENCODE_HEAD;
+        uint32_t *p;
 
         RESERVE_SPACE(16);
         WRITE32(OP_GETATTR);
         WRITE32(2);
         WRITE32(getattr->gt_bmval[0]);
         WRITE32(getattr->gt_bmval[1]);
-        ADJUST_ARGS();
 
-        ENCODE_TAIL;
+        return 0;
 }
 
 static int
-encode_getfh(struct nfs4_compound *cp)
+encode_getfh(struct xdr_stream *xdr)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_GETFH);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_link(struct nfs4_compound *cp, struct nfs4_link *link)
+encode_link(struct xdr_stream *xdr, struct nfs4_link *link)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(8 + link->ln_namelen);
 	WRITE32(OP_LINK);
 	WRITE32(link->ln_namelen);
 	WRITEMEM(link->ln_name, link->ln_namelen);
-	ADJUST_ARGS();
 	
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_lookup(struct nfs4_compound *cp, struct nfs4_lookup *lookup)
+encode_lookup(struct xdr_stream *xdr, struct nfs4_lookup *lookup)
 {
 	int len = lookup->lo_name->len;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(8 + len);
 	WRITE32(OP_LOOKUP);
 	WRITE32(len);
 	WRITEMEM(lookup->lo_name->name, len);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_open(struct nfs4_compound *cp, struct nfs4_open *open)
+encode_open(struct xdr_stream *xdr, struct nfs4_open *open)
 {
 	static int global_id = 0;
 	int id = global_id++;
 	int status;
-	ENCODE_HEAD;
+	uint32_t *p;
 	
 	/* seqid, share_access, share_deny, clientid, ownerlen, owner, opentype */
 	RESERVE_SPACE(52);
@@ -403,24 +385,21 @@
 	WRITE32(0);                       /* seqid */
 	WRITE32(open->op_share_access);
 	WRITE32(0);                       /* for us, share_deny== 0 always */
-	WRITE64(NFS4_CLIENTID(cp->server));
+	WRITE64(open->op_client_state->cl_clientid);
 	WRITE32(4);
 	WRITE32(id);
 	WRITE32(open->op_opentype);
-	ADJUST_ARGS();
 	
 	if (open->op_opentype == NFS4_OPEN_CREATE) {
 		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE) {
 			RESERVE_SPACE(12);
 			WRITE32(open->op_createmode);
 			WRITEMEM(open->op_verifier, sizeof(nfs4_verifier));
-			ADJUST_ARGS();
 		}
 		else if (open->op_attrs) {
 			RESERVE_SPACE(4);
 			WRITE32(open->op_createmode);
-			ADJUST_ARGS();
-			if ((status = encode_attrs(cp, open->op_attrs)))
+			if ((status = encode_attrs(xdr, open->op_attrs)))
 				return status;
 		}
 		else {
@@ -428,7 +407,6 @@
 			WRITE32(open->op_createmode);
 			WRITE32(0);
 			WRITE32(0);
-			ADJUST_ARGS();
 		}
 	}
 
@@ -436,15 +414,14 @@
 	WRITE32(NFS4_OPEN_CLAIM_NULL);
 	WRITE32(open->op_name->len);
 	WRITEMEM(open->op_name->name, open->op_name->len);
-	ADJUST_ARGS();
 	
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_open_confirm(struct nfs4_compound *cp, struct nfs4_open_confirm *open_confirm)
+encode_open_confirm(struct xdr_stream *xdr, struct nfs4_open_confirm *open_confirm)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	/*
 	 * Note: In this "stateless" implementation, the OPEN_CONFIRM
@@ -454,44 +431,41 @@
 	WRITE32(OP_OPEN_CONFIRM);
 	WRITEMEM(open_confirm->oc_stateid, sizeof(nfs4_stateid));
 	WRITE32(1);
-	ADJUST_ARGS();
 	
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_putfh(struct nfs4_compound *cp, struct nfs4_putfh *putfh)
+encode_putfh(struct xdr_stream *xdr, struct nfs4_putfh *putfh)
 {
 	int len = putfh->pf_fhandle->size;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(8 + len);
 	WRITE32(OP_PUTFH);
 	WRITE32(len);
 	WRITEMEM(putfh->pf_fhandle->data, len);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_putrootfh(struct nfs4_compound *cp)
+encode_putrootfh(struct xdr_stream *xdr)
 {
-        ENCODE_HEAD;
+        uint32_t *p;
         
         RESERVE_SPACE(4);
         WRITE32(OP_PUTROOTFH);
-        ADJUST_ARGS();
 
-        ENCODE_TAIL;
+        return 0;
 }
 
 static int
-encode_read(struct nfs4_compound *cp, struct nfs4_read *read, struct rpc_rqst *req)
+encode_read(struct xdr_stream *xdr, struct nfs4_read *read, struct rpc_rqst *req)
 {
 	struct rpc_auth	*auth = req->rq_task->tk_auth;
 	int		replen;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(32);
 	WRITE32(OP_READ);
@@ -501,26 +475,24 @@
 	WRITE32(0);
 	WRITE64(read->rd_offset);
 	WRITE32(read->rd_length);
-	ADJUST_ARGS();
 
 	/* set up reply iovec
 	 *    toplevel status + taglen + rescount + OP_PUTFH + status
 	 *       + OP_READ + status + eof + datalen = 9
 	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 9 + XDR_QUADLEN(cp->taglen)) << 2;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + 9) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 			 read->rd_pages, read->rd_pgbase, read->rd_length);
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_readdir(struct nfs4_compound *cp, struct nfs4_readdir *readdir, struct rpc_rqst *req)
+encode_readdir(struct xdr_stream *xdr, struct nfs4_readdir *readdir, struct rpc_rqst *req)
 {
 	struct rpc_auth *auth = req->rq_task->tk_auth;
 	int replen;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(40);
 	WRITE32(OP_READDIR);
@@ -531,135 +503,124 @@
 	WRITE32(2);
 	WRITE32(readdir->rd_bmval[0]);
 	WRITE32(readdir->rd_bmval[1]);
-	ADJUST_ARGS();
 
 	/* set up reply iovec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
 	 *      + OP_READDIR + status + verifer(2)  = 9
 	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 9 + XDR_QUADLEN(cp->taglen)) << 2;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + 9) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen, readdir->rd_pages,
 			 readdir->rd_pgbase, readdir->rd_count);
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_readlink(struct nfs4_compound *cp, struct nfs4_readlink *readlink, struct rpc_rqst *req)
+encode_readlink(struct xdr_stream *xdr, struct nfs4_readlink *readlink, struct rpc_rqst *req)
 {
 	struct rpc_auth *auth = req->rq_task->tk_auth;
 	int replen;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_READLINK);
-	ADJUST_ARGS();
 
 	/* set up reply iovec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
 	 *      + OP_READLINK + status  = 7
 	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 7 + XDR_QUADLEN(cp->taglen)) << 2;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + 7) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen, readlink->rl_pages, 0, readlink->rl_count);
 	
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_remove(struct nfs4_compound *cp, struct nfs4_remove *remove)
+encode_remove(struct xdr_stream *xdr, struct nfs4_remove *remove)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(8 + remove->rm_namelen);
 	WRITE32(OP_REMOVE);
 	WRITE32(remove->rm_namelen);
 	WRITEMEM(remove->rm_name, remove->rm_namelen);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_rename(struct nfs4_compound *cp, struct nfs4_rename *rename)
+encode_rename(struct xdr_stream *xdr, struct nfs4_rename *rename)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(8 + rename->rn_oldnamelen);
 	WRITE32(OP_RENAME);
 	WRITE32(rename->rn_oldnamelen);
 	WRITEMEM(rename->rn_oldname, rename->rn_oldnamelen);
-	ADJUST_ARGS();
 	
 	RESERVE_SPACE(8 + rename->rn_newnamelen);
 	WRITE32(rename->rn_newnamelen);
 	WRITEMEM(rename->rn_newname, rename->rn_newnamelen);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_renew(struct nfs4_compound *cp)
+encode_renew(struct xdr_stream *xdr, struct nfs4_client *client_stateid)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(12);
 	WRITE32(OP_RENEW);
-	WRITE64(NFS4_CLIENTID(cp->server));
-	ADJUST_ARGS();
+	WRITE64(client_stateid->cl_clientid);
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_restorefh(struct nfs4_compound *cp)
+encode_restorefh(struct xdr_stream *xdr)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_RESTOREFH);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_savefh(struct nfs4_compound *cp)
+encode_savefh(struct xdr_stream *xdr)
 {
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_SAVEFH);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_setattr(struct nfs4_compound *cp, struct nfs4_setattr *setattr)
+encode_setattr(struct xdr_stream *xdr, struct nfs4_setattr *setattr)
 {
 	int status;
-	ENCODE_HEAD;
+	uint32_t *p;
 	
         RESERVE_SPACE(20);
         WRITE32(OP_SETATTR);
 	WRITEMEM(setattr->st_stateid, sizeof(nfs4_stateid));
-        ADJUST_ARGS();
 
-        if ((status = encode_attrs(cp, setattr->st_iap)))
+        if ((status = encode_attrs(xdr, setattr->st_iap)))
 		return status;
 
-        ENCODE_TAIL;
+        return 0;
 }
 
 static int
-encode_setclientid(struct nfs4_compound *cp, struct nfs4_setclientid *setclientid)
+encode_setclientid(struct xdr_stream *xdr, struct nfs4_setclientid *setclientid)
 {
-	u32 total_len;
-	u32 len1, len2, len3;
-	ENCODE_HEAD;
+	uint32_t total_len;
+	uint32_t len1, len2, len3;
+	uint32_t *p;
 
 	len1 = strlen(setclientid->sc_name);
 	len2 = strlen(setclientid->sc_netid);
@@ -678,30 +639,28 @@
 	WRITE32(len3);
 	WRITEMEM(setclientid->sc_uaddr, len3);
 	WRITE32(setclientid->sc_cb_ident);
-	ADJUST_ARGS();
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 static int
-encode_setclientid_confirm(struct nfs4_compound *cp)
+encode_setclientid_confirm(struct xdr_stream *xdr, struct nfs4_client *client_state)
 {
-        ENCODE_HEAD;
+        uint32_t *p;
 
         RESERVE_SPACE(12 + sizeof(nfs4_verifier));
         WRITE32(OP_SETCLIENTID_CONFIRM);
-        WRITE64(cp->server->nfs4_state->cl_clientid);
-        WRITEMEM(cp->server->nfs4_state->cl_confirm,sizeof(nfs4_verifier));
-        ADJUST_ARGS();
+        WRITE64(client_state->cl_clientid);
+        WRITEMEM(client_state->cl_confirm,sizeof(nfs4_verifier));
 
-        ENCODE_TAIL;
+        return 0;
 }
 
 static int
-encode_write(struct nfs4_compound *cp, struct nfs4_write *write, struct rpc_rqst *req)
+encode_write(struct xdr_stream *xdr, struct nfs4_write *write, struct rpc_rqst *req)
 {
 	struct xdr_buf *sndbuf = &req->rq_snd_buf;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	RESERVE_SPACE(36);
 	WRITE32(OP_WRITE);
@@ -712,20 +671,18 @@
 	WRITE64(write->wr_offset);
 	WRITE32(write->wr_stable_how);
 	WRITE32(write->wr_len);
-	ADJUST_ARGS();
 
-	sndbuf->len = xdr_adjust_iovec(sndbuf->head, p);
 	xdr_encode_pages(sndbuf, write->wr_pages, write->wr_pgbase, write->wr_len);
 
-	ENCODE_TAIL;
+	return 0;
 }
 
 /* FIXME: this sucks */
 static int
-encode_compound(struct nfs4_compound *cp, struct rpc_rqst *req)
+encode_compound(struct xdr_stream *xdr, struct nfs4_compound *cp, struct rpc_rqst *req)
 {
 	int i, status = 0;
-	ENCODE_HEAD;
+	uint32_t *p;
 
 	dprintk("encode_compound: tag=%.*s\n", (int)cp->taglen, cp->tag);
 	
@@ -734,81 +691,80 @@
 	WRITEMEM(cp->tag, cp->taglen);
 	WRITE32(NFS4_MINOR_VERSION);
 	WRITE32(cp->req_nops);
-	ADJUST_ARGS();
 
 	for (i = 0; i < cp->req_nops; i++) {
 		switch (cp->ops[i].opnum) {
 		case OP_ACCESS:
-			status = encode_access(cp, &cp->ops[i].u.access);
+			status = encode_access(xdr, &cp->ops[i].u.access);
 			break;
 		case OP_CLOSE:
-			status = encode_close(cp, &cp->ops[i].u.close);
+			status = encode_close(xdr, &cp->ops[i].u.close);
 			break;
 		case OP_COMMIT:
-			status = encode_commit(cp, &cp->ops[i].u.commit);
+			status = encode_commit(xdr, &cp->ops[i].u.commit);
 			break;
 		case OP_CREATE:
-			status = encode_create(cp, &cp->ops[i].u.create);
+			status = encode_create(xdr, &cp->ops[i].u.create);
 			break;
 		case OP_GETATTR:
-			status = encode_getattr(cp, &cp->ops[i].u.getattr);
+			status = encode_getattr(xdr, &cp->ops[i].u.getattr);
 			break;
 		case OP_GETFH:
-			status = encode_getfh(cp);
+			status = encode_getfh(xdr);
 			break;
 		case OP_LINK:
-			status = encode_link(cp, &cp->ops[i].u.link);
+			status = encode_link(xdr, &cp->ops[i].u.link);
 			break;
 		case OP_LOOKUP:
-			status = encode_lookup(cp, &cp->ops[i].u.lookup);
+			status = encode_lookup(xdr, &cp->ops[i].u.lookup);
 			break;
 		case OP_OPEN:
-			status = encode_open(cp, &cp->ops[i].u.open);
+			status = encode_open(xdr, &cp->ops[i].u.open);
 			break;
 		case OP_OPEN_CONFIRM:
-			status = encode_open_confirm(cp, &cp->ops[i].u.open_confirm);
+			status = encode_open_confirm(xdr, &cp->ops[i].u.open_confirm);
 			break;
 		case OP_PUTFH:
-			status = encode_putfh(cp, &cp->ops[i].u.putfh);
+			status = encode_putfh(xdr, &cp->ops[i].u.putfh);
 			break;
 		case OP_PUTROOTFH:
-			status = encode_putrootfh(cp);
+			status = encode_putrootfh(xdr);
 			break;
 		case OP_READ:
-			status = encode_read(cp, &cp->ops[i].u.read, req);
+			status = encode_read(xdr, &cp->ops[i].u.read, req);
 			break;
 		case OP_READDIR:
-			status = encode_readdir(cp, &cp->ops[i].u.readdir, req);
+			status = encode_readdir(xdr, &cp->ops[i].u.readdir, req);
 			break;
 		case OP_READLINK:
-			status = encode_readlink(cp, &cp->ops[i].u.readlink, req);
+			status = encode_readlink(xdr, &cp->ops[i].u.readlink, req);
 			break;
 		case OP_REMOVE:
-			status = encode_remove(cp, &cp->ops[i].u.remove);
+			status = encode_remove(xdr, &cp->ops[i].u.remove);
 			break;
 		case OP_RENAME:
-			status = encode_rename(cp, &cp->ops[i].u.rename);
+			status = encode_rename(xdr, &cp->ops[i].u.rename);
 			break;
 		case OP_RENEW:
-			status = encode_renew(cp);
+			status = encode_renew(xdr, cp->ops[i].u.renew);
 			break;
 		case OP_RESTOREFH:
-			status = encode_restorefh(cp);
+			status = encode_restorefh(xdr);
 			break;
 		case OP_SAVEFH:
-			status = encode_savefh(cp);
+			status = encode_savefh(xdr);
 			break;
 		case OP_SETATTR:
-			status = encode_setattr(cp, &cp->ops[i].u.setattr);
+			status = encode_setattr(xdr, &cp->ops[i].u.setattr);
 			break;
 		case OP_SETCLIENTID:
-			status = encode_setclientid(cp, &cp->ops[i].u.setclientid);
+			status = encode_setclientid(xdr, &cp->ops[i].u.setclientid);
 			break;
 		case OP_SETCLIENTID_CONFIRM:
-			status = encode_setclientid_confirm(cp);
+			status = encode_setclientid_confirm(xdr, cp->ops[i].u.setclientid_confirm);
 			break;
 		case OP_WRITE:
-			status = encode_write(cp, &cp->ops[i].u.write, req);
+			status = encode_write(xdr, &cp->ops[i].u.write, req);
 			break;
 		default:
 			BUG();
@@ -817,7 +773,7 @@
 			return status;
 	}
 	
-	ENCODE_TAIL;
+	return 0;
 }
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
@@ -828,18 +784,14 @@
  * Encode COMPOUND argument
  */
 static int
-nfs4_xdr_enc_compound(struct rpc_rqst *req, u32 *p, struct nfs4_compound *cp)
+nfs4_xdr_enc_compound(struct rpc_rqst *req, uint32_t *p, struct nfs4_compound *cp)
 {
+	struct xdr_stream xdr;
 	int status;
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
 	
-	cp->p = p;
-	cp->end = (u32 *) ((char *)req->rq_svec[0].iov_base + req->rq_svec[0].iov_len);
-	status = encode_compound(cp, req);
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	status = encode_compound(&xdr, cp, req);
 	cp->timestamp = jiffies;
-
-	if (!status && !sndbuf->page_len)
-		req->rq_slen = xdr_adjust_iovec(sndbuf->head, cp->p);
 	return status;
 }
 
@@ -854,9 +806,6 @@
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define DECODE_HEAD				\
-	u32 *p;					\
-	int status
 #define DECODE_TAIL				\
 	status = 0;				\
 out:						\
@@ -881,11 +830,13 @@
 	p += XDR_QUADLEN(nbytes);		\
 } while (0)
 
-#define READ_BUF(nbytes)  do {			\
-	if (nbytes > (u32)((char *)cp->end - (char *)cp->p))  \
-		goto xdr_error;			\
-	p = cp->p;				\
-	cp->p += XDR_QUADLEN(nbytes);		\
+#define READ_BUF(nbytes)  do { \
+	p = xdr_inline_decode(xdr, nbytes); \
+	if (!p) { \
+		printk(KERN_WARNING "%s: reply buffer overflowed in line %d.", \
+				__FUNCTION__, __LINE__); \
+			return -EIO; \
+	} \
 } while (0)
 
 /*
@@ -893,7 +844,7 @@
  * upcall gets in...
  */
 static int
-decode_uid(char *p, u32 len, uid_t *uid)
+decode_uid(char *p, uint32_t len, uid_t *uid)
 {
 	*uid = -2;
 	return 0;
@@ -904,82 +855,78 @@
  * upcall gets in...
  */
 static int
-decode_gid(char *p, u32 len, gid_t *gid)
+decode_gid(char *p, uint32_t len, gid_t *gid)
 {
 	*gid = -2;
 	return 0;
 }
 
 static int
-decode_change_info(struct nfs4_compound *cp, struct nfs4_change_info *cinfo)
+decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 {
-	DECODE_HEAD;
+	uint32_t *p;
 
 	READ_BUF(20);
 	READ32(cinfo->atomic);
 	READ64(cinfo->before);
 	READ64(cinfo->after);
-	
-	DECODE_TAIL;
+	return 0;
 }
 
 static int
-decode_access(struct nfs4_compound *cp, int nfserr, struct nfs4_access *access)
+decode_access(struct xdr_stream *xdr, int nfserr, struct nfs4_access *access)
 {
-	u32 supp, acc;
-	DECODE_HEAD;
+	uint32_t *p;
+	uint32_t supp, acc;
 
 	if (!nfserr) {
 		READ_BUF(8);
 		READ32(supp);
 		READ32(acc);
 
-		status = -EIO;
 		if ((supp & ~access->ac_req_access) || (acc & ~supp)) {
 			printk(KERN_NOTICE "NFS: server returned bad bits in access call!\n");
-			goto out;
+			return -EIO;
 		}
 		*access->ac_resp_supported = supp;
 		*access->ac_resp_access = acc;
 	}
-	
-	DECODE_TAIL;
+	return 0;
 }
 
 static int
-decode_close(struct nfs4_compound *cp, int nfserr, struct nfs4_close *close)
+decode_close(struct xdr_stream *xdr, int nfserr, struct nfs4_close *close)
 {
-	DECODE_HEAD;
+	uint32_t *p;
 
 	if (!nfserr) {
 		READ_BUF(sizeof(nfs4_stateid));
 		COPYMEM(close->cl_stateid, sizeof(nfs4_stateid));
 	}
-	
-	DECODE_TAIL;
+	return 0;
 }
 
 static int
-decode_commit(struct nfs4_compound *cp, int nfserr, struct nfs4_commit *commit)
+decode_commit(struct xdr_stream *xdr, int nfserr, struct nfs4_commit *commit)
 {
-        DECODE_HEAD;
+	uint32_t *p;
 
         if (!nfserr) {
                 READ_BUF(8);
                 COPYMEM(commit->co_verifier->verifier, 8);
         }
-
-        DECODE_TAIL;
+	return 0;
 }
 
 static int
-decode_create(struct nfs4_compound *cp, int nfserr, struct nfs4_create *create)
+decode_create(struct xdr_stream *xdr, int nfserr, struct nfs4_create *create)
 {
-	u32 bmlen;
-	DECODE_HEAD;
+	uint32_t *p;
+	uint32_t bmlen;
+	int status;
 
 	if (!nfserr) {
-		if ((status = decode_change_info(cp, create->cr_cinfo)))
+		if ((status = decode_change_info(xdr, create->cr_cinfo)))
 			goto out;
 		READ_BUF(4);
 		READ32(bmlen);
@@ -991,27 +938,28 @@
 	DECODE_TAIL;
 }
 
-extern u32 nfs4_fattr_bitmap[2];
-extern u32 nfs4_fsinfo_bitmap[2];
-extern u32 nfs4_fsstat_bitmap[2];
-extern u32 nfs4_pathconf_bitmap[2];
+extern uint32_t nfs4_fattr_bitmap[2];
+extern uint32_t nfs4_fsinfo_bitmap[2];
+extern uint32_t nfs4_fsstat_bitmap[2];
+extern uint32_t nfs4_pathconf_bitmap[2];
 
 static int
-decode_getattr(struct nfs4_compound *cp, int nfserr, struct nfs4_getattr *getattr)
+decode_getattr(struct xdr_stream *xdr, int nfserr, struct nfs4_getattr *getattr)
 {
         struct nfs_fattr *nfp = getattr->gt_attrs;
 	struct nfs_fsstat *fsstat = getattr->gt_fsstat;
 	struct nfs_fsinfo *fsinfo = getattr->gt_fsinfo;
 	struct nfs_pathconf *pathconf = getattr->gt_pathconf;
-        u32 bmlen;
-        u32 bmval0 = 0;
-        u32 bmval1 = 0;
-        u32 attrlen;
-        u32 dummy32;
-        u32 len = 0;
+	uint32_t *p;
+        uint32_t bmlen;
+        uint32_t bmval0 = 0;
+        uint32_t bmval1 = 0;
+        uint32_t attrlen;
+        uint32_t dummy32;
+        uint32_t len = 0;
 	unsigned int type;
 	int fmode = 0;
-        DECODE_HEAD;
+	int status;
 	
         if (nfserr)
                 goto success;
@@ -1060,7 +1008,7 @@
                 }
 		nfp->type = nfs_type2fmt[type].nfs2type;
 		fmode = nfs_type2fmt[type].mode;
-                dprintk("read_attrs: type=%d\n", (u32)nfp->type);
+                dprintk("read_attrs: type=%d\n", (uint32_t)nfp->type);
         }
         if (bmval0 & FATTR4_WORD0_CHANGE) {
                 READ_BUF(8);
@@ -1250,11 +1198,12 @@
 }
 
 static int
-decode_getfh(struct nfs4_compound *cp, int nfserr, struct nfs4_getfh *getfh)
+decode_getfh(struct xdr_stream *xdr, int nfserr, struct nfs4_getfh *getfh)
 {
 	struct nfs_fh *fh = getfh->gf_fhandle;
-	int len;
-        DECODE_HEAD;
+	uint32_t *p;
+	uint32_t len;
+	int status;
 
 	/* Zero handle first to allow comparisons */
 	memset(fh, 0, sizeof(*fh));
@@ -1273,26 +1222,27 @@
 }
 
 static int
-decode_link(struct nfs4_compound *cp, int nfserr, struct nfs4_link *link)
+decode_link(struct xdr_stream *xdr, int nfserr, struct nfs4_link *link)
 {
 	int status = 0;
 	
 	if (!nfserr)
-		status = decode_change_info(cp, link->ln_cinfo);
+		status = decode_change_info(xdr, link->ln_cinfo);
 	return status;
 }
 
 static int
-decode_open(struct nfs4_compound *cp, int nfserr, struct nfs4_open *open)
+decode_open(struct xdr_stream *xdr, int nfserr, struct nfs4_open *open)
 {
-	u32 bmlen, delegation_type;
-	DECODE_HEAD;
+	uint32_t *p;
+	uint32_t bmlen, delegation_type;
+	int status;
 	
 	if (!nfserr) {
 		READ_BUF(sizeof(nfs4_stateid));
 		COPYMEM(open->op_stateid, sizeof(nfs4_stateid));
 
-		decode_change_info(cp, open->op_cinfo);
+		decode_change_info(xdr, open->op_cinfo);
 
 		READ_BUF(8);
 		READ32(*open->op_rflags);
@@ -1311,23 +1261,23 @@
 }
 
 static int
-decode_open_confirm(struct nfs4_compound *cp, int nfserr, struct nfs4_open_confirm *open_confirm)
+decode_open_confirm(struct xdr_stream *xdr, int nfserr, struct nfs4_open_confirm *open_confirm)
 {
-	DECODE_HEAD;
+	uint32_t *p;
 
 	if (!nfserr) {
 		READ_BUF(sizeof(nfs4_stateid));
 		COPYMEM(open_confirm->oc_stateid, sizeof(nfs4_stateid));
 	}
-
-	DECODE_TAIL;
+	return 0;
 }
 
 static int
-decode_read(struct nfs4_compound *cp, int nfserr, struct nfs4_read *read)
+decode_read(struct xdr_stream *xdr, int nfserr, struct nfs4_read *read)
 {
-	u32 throwaway;
-	DECODE_HEAD;
+	uint32_t throwaway;
+	uint32_t *p;
+	int status;
 
 	if (!nfserr) {
 		READ_BUF(8);
@@ -1344,23 +1294,22 @@
 }
 
 static int
-decode_readdir(struct nfs4_compound *cp, int nfserr, struct rpc_rqst *req, struct nfs4_readdir *readdir)
+decode_readdir(struct xdr_stream *xdr, int nfserr, struct rpc_rqst *req, struct nfs4_readdir *readdir)
 {
 	struct xdr_buf	*rcvbuf = &req->rq_rcv_buf;
 	struct page	*page = *rcvbuf->pages;
 	unsigned int	pglen = rcvbuf->page_len;
-	u32		*end, *entry;
-	u32		len, attrlen, word;
-	int 		i;
-	DECODE_HEAD;
+	uint32_t *end, *entry, *p;
+	uint32_t len, attrlen, word;
+	int i;
 
 	if (!nfserr) {
 		READ_BUF(8);
 		COPYMEM(readdir->rd_resp_verifier, 8);
 
 		BUG_ON(pglen > PAGE_CACHE_SIZE);
-		p   = (u32 *) kmap(page);
-		end = (u32 *) ((char *)p + pglen + readdir->rd_pgbase);
+		p   = (uint32_t *) kmap(page);
+		end = (uint32_t *) ((char *)p + pglen + readdir->rd_pgbase);
 
 		while (*p++) {
 			entry = p - 1;
@@ -1406,7 +1355,7 @@
 		kunmap(page);
 	}
 	
-	DECODE_TAIL;
+	return 0;
 short_pkt:
 	printk(KERN_NOTICE "NFS: short packet in readdir reply!\n");
 	/* truncate listing */
@@ -1419,11 +1368,11 @@
 }
 
 static int
-decode_readlink(struct nfs4_compound *cp, int nfserr, struct rpc_rqst *req, struct nfs4_readlink *readlink)
+decode_readlink(struct xdr_stream *xdr, int nfserr, struct rpc_rqst *req, struct nfs4_readlink *readlink)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	u32 *strlen;
-	u32 len;
+	uint32_t *strlen;
+	uint32_t len;
 	char *string;
 
 	if (!nfserr) {
@@ -1434,7 +1383,7 @@
 		 * and and null-terminate the text (the VFS expects
 		 * null-termination).
 		 */
-		strlen = (u32 *) kmap(rcvbuf->pages[0]);
+		strlen = (uint32_t *) kmap(rcvbuf->pages[0]);
 		len = ntohl(*strlen);
 		if (len > PAGE_CACHE_SIZE - 5) {
 			printk(KERN_WARNING "nfs: server returned giant symlink!\n");
@@ -1451,25 +1400,25 @@
 }
 
 static int
-decode_remove(struct nfs4_compound *cp, int nfserr, struct nfs4_remove *remove)
+decode_remove(struct xdr_stream *xdr, int nfserr, struct nfs4_remove *remove)
 {
 	int status;
 
 	status = 0;
 	if (!nfserr) 
-		status = decode_change_info(cp, remove->rm_cinfo);
+		status = decode_change_info(xdr, remove->rm_cinfo);
 	return status;
 }
 
 static int
-decode_rename(struct nfs4_compound *cp, int nfserr, struct nfs4_rename *rename)
+decode_rename(struct xdr_stream *xdr, int nfserr, struct nfs4_rename *rename)
 {
 	int status = 0;
 
 	if (!nfserr) {
-		if ((status = decode_change_info(cp, rename->rn_src_cinfo)))
+		if ((status = decode_change_info(xdr, rename->rn_src_cinfo)))
 			goto out;
-		if ((status = decode_change_info(cp, rename->rn_dst_cinfo)))
+		if ((status = decode_change_info(xdr, rename->rn_dst_cinfo)))
 			goto out;
 	}
 out:
@@ -1477,10 +1426,11 @@
 }
 
 static int
-decode_setattr(struct nfs4_compound *cp)
+decode_setattr(struct xdr_stream *xdr)
 {
-        u32 bmlen;
-        DECODE_HEAD;
+	uint32_t *p;
+        uint32_t bmlen;
+	int status;
         
         READ_BUF(4);
         READ32(bmlen);
@@ -1492,17 +1442,17 @@
 }
 
 static int
-decode_setclientid(struct nfs4_compound *cp, int nfserr)
+decode_setclientid(struct xdr_stream *xdr, int nfserr, struct nfs4_setclientid *setclientid)
 {
-	DECODE_HEAD;
+	uint32_t *p;
 
 	if (!nfserr) {
 		READ_BUF(8 + sizeof(nfs4_verifier));
-		READ64(cp->server->nfs4_state->cl_clientid);
-		COPYMEM(cp->server->nfs4_state->cl_confirm, sizeof(nfs4_verifier));
+		READ64(setclientid->sc_state->cl_clientid);
+		COPYMEM(setclientid->sc_state->cl_confirm, sizeof(nfs4_verifier));
 	}
 	else if (nfserr == NFSERR_CLID_INUSE) {
-		u32 len;
+		uint32_t len;
 
 		/* skip netid string */
 		READ_BUF(4);
@@ -1515,13 +1465,14 @@
 		READ_BUF(len);
 	}
 
-	DECODE_TAIL;
+	return 0;
 }
 
 static int
-decode_write(struct nfs4_compound *cp, int nfserr, struct nfs4_write *write)
+decode_write(struct xdr_stream *xdr, int nfserr, struct nfs4_write *write)
 {
-	DECODE_HEAD;
+	uint32_t *p;
+	int status;
 
 	if (!nfserr) {
 		READ_BUF(16);
@@ -1537,11 +1488,12 @@
 
 /* FIXME: this sucks */
 static int
-decode_compound(struct nfs4_compound *cp, struct rpc_rqst *req)
+decode_compound(struct xdr_stream *xdr, struct nfs4_compound *cp, struct rpc_rqst *req)
 {
-	u32 taglen;
-	u32 opnum, nfserr;
-	DECODE_HEAD;
+	uint32_t *p;
+	uint32_t taglen;
+	uint32_t opnum, nfserr;
+	int status;
 
 	READ_BUF(8);
 	READ32(cp->toplevel_status);
@@ -1584,34 +1536,34 @@
 
 		switch (opnum) {
 		case OP_ACCESS:
-			status = decode_access(cp, nfserr, &cp->ops[cp->nops].u.access);
+			status = decode_access(xdr, nfserr, &cp->ops[cp->nops].u.access);
 			break;
 		case OP_CLOSE:
-			status = decode_close(cp, nfserr, &cp->ops[cp->nops].u.close);
+			status = decode_close(xdr, nfserr, &cp->ops[cp->nops].u.close);
 			break;
 		case OP_COMMIT:
-			status = decode_commit(cp, nfserr, &cp->ops[cp->nops].u.commit);
+			status = decode_commit(xdr, nfserr, &cp->ops[cp->nops].u.commit);
 			break;
 		case OP_CREATE:
-			status = decode_create(cp, nfserr, &cp->ops[cp->nops].u.create);
+			status = decode_create(xdr, nfserr, &cp->ops[cp->nops].u.create);
 			break;
 		case OP_GETATTR:
-			status = decode_getattr(cp, nfserr, &cp->ops[cp->nops].u.getattr);
+			status = decode_getattr(xdr, nfserr, &cp->ops[cp->nops].u.getattr);
 			break;
 		case OP_GETFH:
-			status = decode_getfh(cp, nfserr, &cp->ops[cp->nops].u.getfh);
+			status = decode_getfh(xdr, nfserr, &cp->ops[cp->nops].u.getfh);
 			break;
 		case OP_LINK:
-			status = decode_link(cp, nfserr, &cp->ops[cp->nops].u.link);
+			status = decode_link(xdr, nfserr, &cp->ops[cp->nops].u.link);
 			break;
 		case OP_LOOKUP:
 			status = 0;
 			break;
 		case OP_OPEN:
-			status = decode_open(cp, nfserr, &cp->ops[cp->nops].u.open);
+			status = decode_open(xdr, nfserr, &cp->ops[cp->nops].u.open);
 			break;
 		case OP_OPEN_CONFIRM:
-			status = decode_open_confirm(cp, nfserr, &cp->ops[cp->nops].u.open_confirm);
+			status = decode_open_confirm(xdr, nfserr, &cp->ops[cp->nops].u.open_confirm);
 			break;
 		case OP_PUTFH:
 			status = 0;
@@ -1620,22 +1572,22 @@
 			status = 0;
 			break;
 		case OP_READ:
-			status = decode_read(cp, nfserr, &cp->ops[cp->nops].u.read);
+			status = decode_read(xdr, nfserr, &cp->ops[cp->nops].u.read);
 			break;
 		case OP_READDIR:
-			status = decode_readdir(cp, nfserr, req, &cp->ops[cp->nops].u.readdir);
+			status = decode_readdir(xdr, nfserr, req, &cp->ops[cp->nops].u.readdir);
 			break;
 		case OP_READLINK:
-			status = decode_readlink(cp, nfserr, req, &cp->ops[cp->nops].u.readlink);
+			status = decode_readlink(xdr, nfserr, req, &cp->ops[cp->nops].u.readlink);
 			break;
 		case OP_RESTOREFH:
 			status = 0;
 			break;
 		case OP_REMOVE:
-			status = decode_remove(cp, nfserr, &cp->ops[cp->nops].u.remove);
+			status = decode_remove(xdr, nfserr, &cp->ops[cp->nops].u.remove);
 			break;
 		case OP_RENAME:
-			status = decode_rename(cp, nfserr, &cp->ops[cp->nops].u.rename);
+			status = decode_rename(xdr, nfserr, &cp->ops[cp->nops].u.rename);
 			break;
 		case OP_RENEW:
 			status = 0;
@@ -1644,16 +1596,16 @@
 			status = 0;
 			break;
 		case OP_SETATTR:
-			status = decode_setattr(cp);
+			status = decode_setattr(xdr);
 			break;
 		case OP_SETCLIENTID:
-			status = decode_setclientid(cp, nfserr);
+			status = decode_setclientid(xdr, nfserr, &cp->ops[cp->nops].u.setclientid);
 			break;
 		case OP_SETCLIENTID_CONFIRM:
 			status = 0;
 			break;
 		case OP_WRITE:
-			status = decode_write(cp, nfserr, &cp->ops[cp->nops].u.write);
+			status = decode_write(xdr, nfserr, &cp->ops[cp->nops].u.write);
 			break;
 		default:
 			BUG();
@@ -1673,14 +1625,13 @@
  * Decode COMPOUND response
  */
 static int
-nfs4_xdr_dec_compound(struct rpc_rqst *rqstp, u32 *p, struct nfs4_compound *cp)
+nfs4_xdr_dec_compound(struct rpc_rqst *rqstp, uint32_t *p, struct nfs4_compound *cp)
 {
+	struct xdr_stream xdr;
 	int status;
 	
-	cp->p = p;
-	cp->end = (u32 *) ((u8 *) rqstp->rq_rvec->iov_base + rqstp->rq_rvec->iov_len);
-
-	if ((status = decode_compound(cp, rqstp)))
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	if ((status = decode_compound(&xdr, cp, rqstp)))
 		goto out;
 	
 	status = 0;
@@ -1691,10 +1642,10 @@
 	return status;
 }
 
-u32 *
-nfs4_decode_dirent(u32 *p, struct nfs_entry *entry, int plus)
+uint32_t *
+nfs4_decode_dirent(uint32_t *p, struct nfs_entry *entry, int plus)
 {
-	u32 len;
+	uint32_t len;
 
 	if (!*p++) {
 		if (!*p)
diff -u --recursive --new-file linux-2.5.48-01-fix_time/include/linux/nfs_xdr.h linux-2.5.48-02-nfsv4_xdr/include/linux/nfs_xdr.h
--- linux-2.5.48-01-fix_time/include/linux/nfs_xdr.h	2002-11-18 08:16:31.000000000 -0500
+++ linux-2.5.48-02-nfsv4_xdr/include/linux/nfs_xdr.h	2002-11-18 11:53:14.000000000 -0500
@@ -398,6 +398,7 @@
 };
 
 struct nfs4_open {
+	struct nfs4_client *		op_client_state;  /* request */
 	u32				op_share_access;  /* request */
 	u32				op_opentype;      /* request */
 	u32				op_createmode;    /* request */
@@ -472,6 +473,7 @@
 	char				sc_netid[4];	  /* request */
 	char				sc_uaddr[24];     /* request */
 	u32				sc_cb_ident;      /* request */
+	struct nfs4_client *		sc_state;	  /* response */
 };
 
 struct nfs4_write {
@@ -504,8 +506,10 @@
 		struct nfs4_readlink	readlink;
 		struct nfs4_remove	remove;
 		struct nfs4_rename	rename;
+		struct nfs4_client *	renew;
 		struct nfs4_setattr	setattr;
 		struct nfs4_setclientid	setclientid;
+		struct nfs4_client *	setclientid_confirm;
 		struct nfs4_write	write;
 	} u;
 };
diff -u --recursive --new-file linux-2.5.48-01-fix_time/include/linux/sunrpc/xdr.h linux-2.5.48-02-nfsv4_xdr/include/linux/sunrpc/xdr.h
--- linux-2.5.48-01-fix_time/include/linux/sunrpc/xdr.h	2002-11-08 12:09:05.000000000 -0500
+++ linux-2.5.48-02-nfsv4_xdr/include/linux/sunrpc/xdr.h	2002-11-18 11:53:14.000000000 -0500
@@ -155,6 +155,79 @@
 extern void xdr_partial_copy_from_skb(struct xdr_buf *, unsigned int,
 		skb_reader_t *, skb_read_actor_t);
 
+/*
+ * Provide some simple tools for XDR buffer overflow-checking etc.
+ */
+struct xdr_stream {
+	uint32_t *p;		/* start of available buffer */
+	struct xdr_buf *buf;	/* XDR buffer to read/write */
+
+	uint32_t *end;		/* end of available buffer space */
+	struct iovec *iov;	/* pointer to the current iovec */
+};
+
+/*
+ * Initialize an xdr_stream for encoding data.
+ *
+ * Note: at the moment the RPC client only passes the length of our
+ *	 scratch buffer in the xdr_buf's header iovec. Previously this
+ *	 meant we needed to call xdr_adjust_iovec() after encoding the
+ *	 data. With the new scheme, the xdr_stream both caches the details
+ *	 of the buffer length, and takes care of adjusting the iovec
+ *	 length for us.
+ */
+static inline void
+xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, uint32_t *p)
+{
+	struct iovec *iov = buf->head;
+
+	xdr->buf = buf;
+	xdr->iov = iov;
+	xdr->end = (uint32_t *)((char *)iov->iov_base + iov->iov_len);
+	buf->len = iov->iov_len = (char *)p - (char *)iov->iov_base;
+	xdr->p = p;
+}
+
+static inline uint32_t *
+xdr_inline_encode(struct xdr_stream *xdr, size_t nbytes)
+{
+	uint32_t *p = xdr->p;
+	uint32_t *q;
+
+	/* align nbytes on next 32-bit boundary */
+	nbytes += 3;
+	nbytes &= ~3;
+	q = p + (nbytes >> 2);
+	if (unlikely(q > xdr->end || q < p))
+		return NULL;
+	xdr->p = q;
+	xdr->iov->iov_len += nbytes;
+	xdr->buf->len += nbytes;
+	return p;
+}
+
+static inline void
+xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, uint32_t *p)
+{
+	struct iovec *iov = buf->head;
+	xdr->buf = buf;
+	xdr->iov = iov;
+	xdr->p = p;
+	xdr->end = (uint32_t *)((char *)iov->iov_base + iov->iov_len);
+}
+
+static inline uint32_t *
+xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
+{
+	uint32_t *p = xdr->p;
+	uint32_t *q = p + XDR_QUADLEN(nbytes);
+
+	if (unlikely(q > xdr->end || q < p))
+		return NULL;
+	xdr->p = q;
+	return p;
+}
+
 #endif /* __KERNEL__ */
 
 #endif /* _SUNRPC_XDR_H_ */


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
