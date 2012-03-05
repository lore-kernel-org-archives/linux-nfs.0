Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61077 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757806Ab2CEXVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 18:21:13 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/16] NFS: Fix nfs4_verifier memory alignment
Date: Mon,  5 Mar 2012 18:20:51 -0500
Message-Id: <1330989654-4694-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330989654-4694-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1330989654-4694-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-7-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-8-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-9-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-10-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-11-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   32 +++++++++++++++++++-------------
 fs/nfs/nfs4xdr.c  |   40 ++++++++++++++++++++--------------------
 2 files changed, 39 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 232935e..21720d5 100644
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
@@ -3808,6 +3810,16 @@ wait_on_recovery:
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
@@ -3824,13 +3836,10 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
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
@@ -4919,6 +4928,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
+		.verifier = &verifier,
 		.client = clp,
 		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
 	};
@@ -4932,15 +4942,11 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
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
index e9d4ac0..62effaf 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1538,7 +1538,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 		FATTR4_WORD1_MOUNTED_ON_FILEID,
 	};
 	uint32_t dircount = readdir->count >> 1;
-	__be32 *p;
+	__be32 *p, verf[2];
 
 	if (readdir->plus) {
 		attrs[0] |= FATTR4_WORD0_TYPE|FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE|
@@ -1553,10 +1553,11 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	if (!(readdir->bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID))
 		attrs[0] |= FATTR4_WORD0_FILEID;
 
-	p = reserve_space(xdr, 12+NFS4_VERIFIER_SIZE+20);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
-	p = xdr_encode_opaque_fixed(p, readdir->verifier.data, NFS4_VERIFIER_SIZE);
+	encode_nfs4_verifier(xdr, &readdir->verifier);
+	p = reserve_space(xdr, 20);
 	*p++ = cpu_to_be32(dircount);
 	*p++ = cpu_to_be32(readdir->count);
 	*p++ = cpu_to_be32(2);
@@ -1565,11 +1566,11 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
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
@@ -1643,9 +1644,9 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
-	*p++ = cpu_to_be32(OP_SETCLIENTID);
-	xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_SETCLIENTID);
+	encode_nfs4_verifier(xdr, setclientid->sc_verifier);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
 	p = reserve_space(xdr, 4);
@@ -1662,10 +1663,10 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, arg->clientid);
-	xdr_encode_opaque_fixed(p, arg->confirm.data, NFS4_VERIFIER_SIZE);
+	encode_nfs4_verifier(xdr, &arg->confirm);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
 }
@@ -1708,9 +1709,9 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	char impl_name[NFS4_OPAQUE_LIMIT];
 	int len = 0;
 
-	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
-	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
-	xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_EXCHANGE_ID);
+	encode_nfs4_verifier(xdr, args->verifier);
 
 	encode_string(xdr, args->id_len, args->id);
 
@@ -4162,7 +4163,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 
 static int decode_verifier(struct xdr_stream *xdr, void *verifier)
 {
-	return decode_opaque_fixed(xdr, verifier, 8);
+	return decode_opaque_fixed(xdr, verifier, NFS4_VERIFIER_SIZE);
 }
 
 static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
@@ -4854,17 +4855,16 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
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
@@ -5111,7 +5111,7 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 		goto out_overflow;
 	res->count = be32_to_cpup(p++);
 	res->verf->committed = be32_to_cpup(p++);
-	memcpy(res->verf->verifier, p, 8);
+	memcpy(res->verf->verifier, p, NFS4_VERIFIER_SIZE);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -5455,7 +5455,7 @@ static int decode_getdevicelist(struct xdr_stream *xdr,
 	p += 2;
 
 	/* Read verifier */
-	p = xdr_decode_opaque_fixed(p, verftemp.verifier, 8);
+	p = xdr_decode_opaque_fixed(p, verftemp.verifier, NFS4_VERIFIER_SIZE);
 
 	res->num_devs = be32_to_cpup(p);
 
-- 
1.7.7.6

