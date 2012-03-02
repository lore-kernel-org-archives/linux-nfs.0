Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43557 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab2CBWOd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 17:14:33 -0500
Received: by iagz16 with SMTP id z16so2870350iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 14:14:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Fix nfs4_verifier memory alignment
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 17:14:31 -0500
Message-ID: <20120302221430.13055.59541.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up due to code review.

The nfs4_verifier's data field is not guaranteed to be u32-aligned.
Casting an array of chars to a u32 * is considered generally
hazardous.

Fix this by using a __be32 array to generate a verifier's contents,
and then byte-copy the contents into the verifier field.  The contents
of a verifier, for all intents and purposes, are opaque bytes.  Only
local code that generates a verifier need know the actual content and
format.  Everyone else compares the full byte array for exact
equality.

Also, sizeof(nfs4_verifer) is the size of the in-core verifier data
structure, but NFS4_VERIFIER_SIZE is the number of octets in an XDR'd
verifier.  The two are not interchangeable, even if they happen to
have the same value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   32 +++++++++++++++++++-------------
 fs/nfs/nfs4xdr.c  |   36 ++++++++++++++++++++----------------
 2 files changed, 39 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 07bd1f3..33ef0a1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -833,13 +833,15 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.dir_bitmask = server->cache_consistency_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
 	if (attrs != NULL && attrs->ia_valid != 0) {
-		u32 *s;
+		__be32 verf[2];
 
 		p->o_arg.u.attrs = &p->attrs;
 		memcpy(&p->attrs, attrs, sizeof(p->attrs));
-		s = (u32 *) p->o_arg.u.verifier.data;
-		s[0] = jiffies;
-		s[1] = current->pid;
+
+		verf[0] = jiffies;
+		verf[1] = current->pid;
+		memcpy(p->o_arg.u.verifier.data, verf,
+				sizeof(p->o_arg.u.verifier.data));
 	}
 	p->c_arg.fh = &p->o_res.fh;
 	p->c_arg.stateid = &p->o_res.stateid;
@@ -3810,6 +3812,16 @@ wait_on_recovery:
 	return -EAGAIN;
 }
 
+static void nfs4_construct_boot_verifier(struct nfs_client *clp,
+					 nfs4_verifier *bootverf)
+{
+	__be32 verf[2];
+
+	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
+	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
+	memcpy(bootverf->data, verf, sizeof(bootverf->data));
+}
+
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		unsigned short port, struct rpc_cred *cred,
 		struct nfs4_setclientid_res *res)
@@ -3826,13 +3838,10 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
-	__be32 *p;
 	int loop = 0;
 	int status;
 
-	p = (__be32*)sc_verifier.data;
-	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
-	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
+	nfs4_construct_boot_verifier(clp, &sc_verifier);
 
 	for(;;) {
 		rcu_read_lock();
@@ -4923,6 +4932,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
+		.verifier = &verifier,
 		.client = clp,
 		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
 	};
@@ -4936,15 +4946,11 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
-	__be32 *p;
 
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	p = (u32 *)verifier.data;
-	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
-	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
-	args.verifier = &verifier;
+	nfs4_construct_boot_verifier(clp, &verifier);
 
 	args.id_len = scnprintf(args.id, sizeof(args.id),
 				"%s/%s.%s/%u",
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d8d5b61..bf4aefd 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -903,13 +903,18 @@ static void encode_nops(struct compound_hdr *hdr)
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
@@ -1550,7 +1555,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 		FATTR4_WORD1_MOUNTED_ON_FILEID,
 	};
 	uint32_t dircount = readdir->count >> 1;
-	__be32 *p;
+	__be32 *p, verf[2];
 
 	if (readdir->plus) {
 		attrs[0] |= FATTR4_WORD0_TYPE|FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE|
@@ -1568,7 +1573,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	p = reserve_space(xdr, 12+NFS4_VERIFIER_SIZE+20);
 	*p++ = cpu_to_be32(OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
-	p = xdr_encode_opaque_fixed(p, readdir->verifier.data, NFS4_VERIFIER_SIZE);
+	p = xdr_encode_nfs4_verifier(p, &readdir->verifier);
 	*p++ = cpu_to_be32(dircount);
 	*p++ = cpu_to_be32(readdir->count);
 	*p++ = cpu_to_be32(2);
@@ -1577,11 +1582,11 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	*p = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
 	hdr->nops++;
 	hdr->replen += decode_readdir_maxsz;
+	memcpy(verf, readdir->verifier.data, sizeof(verf));
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
 			(unsigned long long)readdir->cookie,
-			((u32 *)readdir->verifier.data)[0],
-			((u32 *)readdir->verifier.data)[1],
+			verf[0], verf[1],
 			attrs[0] & readdir->bitmask[0],
 			attrs[1] & readdir->bitmask[1]);
 }
@@ -1690,7 +1695,7 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 
 	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID);
-	xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
+	xdr_encode_nfs4_verifier(p, setclientid->sc_verifier);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
 	p = reserve_space(xdr, 4);
@@ -1710,7 +1715,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4
 	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, arg->clientid);
-	xdr_encode_opaque_fixed(p, arg->confirm.data, NFS4_VERIFIER_SIZE);
+	xdr_encode_nfs4_verifier(p, &arg->confirm);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
 }
@@ -1767,9 +1772,9 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
+	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
-	xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
+	xdr_encode_nfs4_verifier(p, args->verifier);
 
 	encode_string(xdr, args->id_len, args->id);
 
@@ -4202,7 +4207,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 
 static int decode_verifier(struct xdr_stream *xdr, void *verifier)
 {
-	return decode_opaque_fixed(xdr, verifier, 8);
+	return decode_opaque_fixed(xdr, verifier, NFS4_VERIFIER_SIZE);
 }
 
 static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
@@ -4894,17 +4899,16 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	size_t		hdrlen;
 	u32		recvd, pglen = rcvbuf->page_len;
 	int		status;
+	__be32		verf[2];
 
 	status = decode_op_hdr(xdr, OP_READDIR);
 	if (!status)
 		status = decode_verifier(xdr, readdir->verifier.data);
 	if (unlikely(status))
 		return status;
+	memcpy(verf, readdir->verifier.data, sizeof(verf));
 	dprintk("%s: verifier = %08x:%08x\n",
-			__func__,
-			((u32 *)readdir->verifier.data)[0],
-			((u32 *)readdir->verifier.data)[1]);
-
+			__func__, verf[0], verf[1]);
 
 	hdrlen = (char *) xdr->p - (char *) iov->iov_base;
 	recvd = rcvbuf->len - hdrlen;
@@ -5151,7 +5155,7 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 		goto out_overflow;
 	res->count = be32_to_cpup(p++);
 	res->verf->committed = be32_to_cpup(p++);
-	memcpy(res->verf->verifier, p, 8);
+	memcpy(res->verf->verifier, p, NFS4_VERIFIER_SIZE);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -5467,7 +5471,7 @@ static int decode_getdevicelist(struct xdr_stream *xdr,
 	p += 2;
 
 	/* Read verifier */
-	p = xdr_decode_opaque_fixed(p, verftemp.verifier, 8);
+	p = xdr_decode_opaque_fixed(p, verftemp.verifier, NFS4_VERIFIER_SIZE);
 
 	res->num_devs = be32_to_cpup(p);
 

