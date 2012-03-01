Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41115 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab2CAWCQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:02:16 -0500
Received: by ghrr11 with SMTP id r11so545114ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:02:15 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/15] NFS: Fix some minor problems with nfs4_verifiers
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:02:14 -0500
Message-ID: <20120301220213.2138.19498.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up due to code review.

sizeof(nfs4_verifer) is the size of the in-core verifier data
structure, but NFS4_VERIFIER_SIZE is the number of octets in an XDR'd
verifier.  The two are not interchangeable, even if they happen to
have the same value.  If the nfs4_verifier struct is padded by the
compiler, sizeof(nfs4_verifier) may not be the same as the XDR'd
size.  Not likely, but still.

Ensure that the data field in the nfs4_verifier structure is aligned
to the largest pointer type that is used to access it: in this case,
that's u32.  Type-punning among types with different alignment has
been discouraged in user space and the kernel, to avoid unneeded
pointer aliasing.  The use of a union is preferred instead.

As a micro-optimization, this change also ensures that the compiler
may perform memcpy() and memcmp() operations on these fields in
larger, more efficient, chunks.

Pull out some common nfs4_verifier XDR encoding logic into a helper.

I'm sure I missed a few spots.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c    |    6 +++---
 fs/nfs/nfs4xdr.c     |   27 ++++++++++++++++-----------
 fs/nfsd/nfs4proc.c   |    4 ++--
 fs/nfsd/nfs4state.c  |    2 +-
 fs/nfsd/nfs4xdr.c    |   28 ++++++++++++++--------------
 include/linux/nfs4.h |    5 ++++-
 6 files changed, 40 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 07bd1f3..cb08b1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -837,7 +837,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 
 		p->o_arg.u.attrs = &p->attrs;
 		memcpy(&p->attrs, attrs, sizeof(p->attrs));
-		s = (u32 *) p->o_arg.u.verifier.data;
+		s = p->o_arg.u.verifier.data32;
 		s[0] = jiffies;
 		s[1] = current->pid;
 	}
@@ -3830,7 +3830,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	int loop = 0;
 	int status;
 
-	p = (__be32*)sc_verifier.data;
+	p = (__be32*)sc_verifier.data32;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 
@@ -4941,7 +4941,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	p = (u32 *)verifier.data;
+	p = verifier.data32;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 	args.verifier = &verifier;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 018bbd7..80ba010 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -906,13 +906,18 @@ static void encode_nops(struct compound_hdr *hdr)
 	*hdr->nops_p = htonl(hdr->nops);
 }
 
+static __be32 *xdr_encode_nfs4_verifier(__be32 *p, const nfs4_verifier *verf)
+{
+	return xdr_encode_opaque_fixed(p, verf->data, NFS4_VERIFIER_SIZE);
+}
+
 static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
 {
 	__be32 *p;
 
 	p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
 	BUG_ON(p == NULL);
-	xdr_encode_opaque_fixed(p, verf->data, NFS4_VERIFIER_SIZE);
+	xdr_encode_nfs4_verifier(p, verf);
 }
 
 static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
@@ -1571,7 +1576,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	p = reserve_space(xdr, 12+NFS4_VERIFIER_SIZE+20);
 	*p++ = cpu_to_be32(OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
-	p = xdr_encode_opaque_fixed(p, readdir->verifier.data, NFS4_VERIFIER_SIZE);
+	p = xdr_encode_nfs4_verifier(p, &readdir->verifier);
 	*p++ = cpu_to_be32(dircount);
 	*p++ = cpu_to_be32(readdir->count);
 	*p++ = cpu_to_be32(2);
@@ -1583,8 +1588,8 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
 			(unsigned long long)readdir->cookie,
-			((u32 *)readdir->verifier.data)[0],
-			((u32 *)readdir->verifier.data)[1],
+			readdir->verifier.data32[0],
+			readdir->verifier.data32[1],
 			attrs[0] & readdir->bitmask[0],
 			attrs[1] & readdir->bitmask[1]);
 }
@@ -1693,7 +1698,7 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 
 	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID);
-	xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
+	xdr_encode_nfs4_verifier(p, setclientid->sc_verifier);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
 	p = reserve_space(xdr, 4);
@@ -1713,7 +1718,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4
 	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, arg->clientid);
-	xdr_encode_opaque_fixed(p, arg->confirm.data, NFS4_VERIFIER_SIZE);
+	xdr_encode_nfs4_verifier(p, &arg->confirm);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
 }
@@ -1770,9 +1775,9 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
+	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
-	xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
+	xdr_encode_nfs4_verifier(p, args->verifier);
 
 	encode_string(xdr, args->id_len, args->id);
 
@@ -4205,7 +4210,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 
 static int decode_verifier(struct xdr_stream *xdr, void *verifier)
 {
-	return decode_opaque_fixed(xdr, verifier, 8);
+	return decode_opaque_fixed(xdr, verifier, NFS4_VERIFIER_SIZE);
 }
 
 static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
@@ -4905,8 +4910,8 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		return status;
 	dprintk("%s: verifier = %08x:%08x\n",
 			__func__,
-			((u32 *)readdir->verifier.data)[0],
-			((u32 *)readdir->verifier.data)[1]);
+			readdir->verifier.data32[0],
+			readdir->verifier.data32[1]);
 
 
 	hdrlen = (char *) xdr->p - (char *) iov->iov_base;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 896da74..73ac8c6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -221,7 +221,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 		status = do_nfsd_create(rqstp, current_fh, open->op_fname.data,
 					open->op_fname.len, &open->op_iattr,
 					&resfh, open->op_createmode,
-					(u32 *)open->op_verf.data,
+					open->op_verf.data32,
 					&open->op_truncate, &open->op_created);
 
 		/*
@@ -485,7 +485,7 @@ static __be32
 nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_commit *commit)
 {
-	u32 *p = (u32 *)commit->co_verf.data;
+	u32 *p = commit->co_verf.data32;
 	*p++ = nfssvc_boot.tv_sec;
 	*p++ = nfssvc_boot.tv_usec;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c5cddd6..c8ec181 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1141,7 +1141,7 @@ static void gen_confirm(struct nfs4_client *clp)
 	static u32 i;
 	u32 *p;
 
-	p = (u32 *)clp->cl_confirm.data;
+	p = clp->cl_confirm.data32;
 	*p++ = get_seconds();
 	*p++ = i++;
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0ec5a1b..f8dbc80 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -755,14 +755,14 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 				goto out;
 			break;
 		case NFS4_CREATE_EXCLUSIVE:
-			READ_BUF(8);
-			COPYMEM(open->op_verf.data, 8);
+			READ_BUF(NFS4_VERIFIER_SIZE);
+			COPYMEM(open->verf.data, NFS4_VERIFIER_SIZE);
 			break;
 		case NFS4_CREATE_EXCLUSIVE4_1:
 			if (argp->minorversion < 1)
 				goto xdr_error;
-			READ_BUF(8);
-			COPYMEM(open->op_verf.data, 8);
+			READ_BUF(NFS4_VERIFIER_SIZE);
+			COPYMEM(open->verf.data, NFS4_VERIFIER_SIZE);
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
 				&open->op_iattr, &open->op_acl);
 			if (status)
@@ -994,8 +994,8 @@ nfsd4_decode_setclientid(struct nfsd4_compoundargs *argp, struct nfsd4_setclient
 {
 	DECODE_HEAD;
 
-	READ_BUF(8);
-	COPYMEM(setclientid->se_verf.data, 8);
+	READ_BUF(NFS4_VERIFIER_SIZE);
+	COPYMEM(setclientid->se_verf.data, NFS4_VERIFIER_SIZE);
 
 	status = nfsd4_decode_opaque(argp, &setclientid->se_name);
 	if (status)
@@ -1020,9 +1020,9 @@ nfsd4_decode_setclientid_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_s
 {
 	DECODE_HEAD;
 
-	READ_BUF(8 + sizeof(nfs4_verifier));
+	READ_BUF(8 + NFS4_VERIFIER_SIZE);
 	COPYMEM(&scd_c->sc_clientid, 8);
-	COPYMEM(&scd_c->sc_confirm, sizeof(nfs4_verifier));
+	COPYMEM(&scd_c->sc_confirm, NFS4_VERIFIER_SIZE);
 
 	DECODE_TAIL;
 }
@@ -2661,8 +2661,8 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(8);
-		WRITEMEM(commit->co_verf.data, 8);
+		RESERVE_SPACE(NFS4_VERIFIER_SIZE);
+		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
 		ADJUST_ARGS();
 	}
 	return nfserr;
@@ -3008,7 +3008,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	if (resp->xbuf->page_len)
 		return nfserr_resource;
 
-	RESERVE_SPACE(8);  /* verifier */
+	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
 	savep = p;
 
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
@@ -3209,9 +3209,9 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(8 + sizeof(nfs4_verifier));
+		RESERVE_SPACE(8 + NFS4_VERIFIER_SIZE);
 		WRITEMEM(&scd->se_clientid, 8);
-		WRITEMEM(&scd->se_confirm, sizeof(nfs4_verifier));
+		WRITEMEM(&scd->se_confirm, NFS4_VERIFIER_SIZE);
 		ADJUST_ARGS();
 	}
 	else if (nfserr == nfserr_clid_inuse) {
@@ -3232,7 +3232,7 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 		RESERVE_SPACE(16);
 		WRITE32(write->wr_bytes_written);
 		WRITE32(write->wr_how_written);
-		WRITEMEM(write->wr_verifier.data, 8);
+		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
 		ADJUST_ARGS();
 	}
 	return nfserr;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 32345c2..b1e6b64 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -181,7 +181,10 @@ struct nfs4_acl {
 	struct nfs4_ace	aces[0];
 };
 
-typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
+typedef union {
+	unsigned char	data[NFS4_VERIFIER_SIZE];
+	u32		data32[NFS4_VERIFIER_SIZE / sizeof(u32)];
+} nfs4_verifier;
 
 struct nfs41_stateid {
 	__be32 seqid;

