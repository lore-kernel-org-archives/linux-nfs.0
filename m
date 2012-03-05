Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61077 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757839Ab2CEXVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 18:21:14 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 16/16] NFSv4: Add a helper encode_uint64
Date: Mon,  5 Mar 2012 18:20:54 -0500
Message-Id: <1330989654-4694-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330989654-4694-15-git-send-email-Trond.Myklebust@netapp.com>
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
 <1330989654-4694-13-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-14-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4ea9f50..e4bb8e6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -909,6 +909,14 @@ static void encode_uint32(struct xdr_stream *xdr, u32 n)
 	*p = cpu_to_be32(n);
 }
 
+static void encode_uint64(struct xdr_stream *xdr, u64 n)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 8);
+	xdr_encode_hyper(p, n);
+}
+
 static void encode_nfs4_seqid(struct xdr_stream *xdr,
 		const struct nfs_seqid *seqid)
 {
@@ -1532,8 +1540,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 		attrs[0] |= FATTR4_WORD0_FILEID;
 
 	encode_op_hdr(xdr, OP_READDIR, decode_readdir_maxsz, hdr);
-	p = reserve_space(xdr, 8);
-	p = xdr_encode_hyper(p, readdir->cookie);
+	encode_uint64(xdr, readdir->cookie);
 	encode_nfs4_verifier(xdr, &readdir->verifier);
 	p = reserve_space(xdr, 20);
 	*p++ = cpu_to_be32(dircount);
@@ -1572,11 +1579,8 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 static void encode_renew(struct xdr_stream *xdr, clientid4 clid,
 			 struct compound_hdr *hdr)
 {
-	__be32 *p;
-
 	encode_op_hdr(xdr, OP_RENEW, decode_renew_maxsz, hdr);
-	p = reserve_space(xdr, 8);
-	xdr_encode_hyper(p, clid);
+	encode_uint64(xdr, clid);
 }
 
 static void
@@ -1632,12 +1636,9 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 
 static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4_setclientid_res *arg, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
 	encode_op_hdr(xdr, OP_SETCLIENTID_CONFIRM,
 			decode_setclientid_confirm_maxsz, hdr);
-	p = reserve_space(xdr, 8);
-	p = xdr_encode_hyper(p, arg->clientid);
+	encode_uint64(xdr, arg->clientid);
 	encode_nfs4_verifier(xdr, &arg->confirm);
 }
 
-- 
1.7.7.6

