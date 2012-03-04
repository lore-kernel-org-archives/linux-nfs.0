Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38040 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960Ab2CDXDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 18:03:14 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/11] NFSv4: Add a helper for encoding NFSv4 sequence ids
Date: Sun,  4 Mar 2012 18:03:02 -0500
Message-Id: <1330902183-18879-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-7-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-8-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   47 ++++++++++++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d6e8306..604da06 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -901,6 +901,20 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
 	xdr_encode_opaque(p, str, len);
 }
 
+static void encode_word(struct xdr_stream *xdr, u32 n)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(n);
+}
+
+static void encode_nfs4_seqid(struct xdr_stream *xdr,
+		const struct nfs_seqid *seqid)
+{
+	encode_word(xdr, seqid->sequence->counter);
+}
+
 static void encode_compound_hdr(struct xdr_stream *xdr,
 				struct rpc_rqst *req,
 				struct compound_hdr *hdr)
@@ -1074,9 +1088,9 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_CLOSE);
-	*p = cpu_to_be32(arg->seqid->sequence->counter);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_CLOSE);
+	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	hdr->nops++;
 	hdr->replen += decode_close_maxsz;
@@ -1264,17 +1278,14 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	*p = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(args->open_seqid->sequence->counter);
+		encode_nfs4_seqid(xdr, args->open_seqid);
 		encode_nfs4_stateid(xdr, args->open_stateid);
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(args->lock_seqid->sequence->counter);
+		encode_nfs4_seqid(xdr, args->lock_seqid);
 		encode_lockowner(xdr, &args->lock_owner);
 	}
 	else {
 		encode_nfs4_stateid(xdr, args->lock_stateid);
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(args->lock_seqid->sequence->counter);
+		encode_nfs4_seqid(xdr, args->lock_seqid);
 	}
 	hdr->nops++;
 	hdr->replen += decode_lock_maxsz;
@@ -1298,10 +1309,10 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 12);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_LOCKU);
-	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
-	*p = cpu_to_be32(args->seqid->sequence->counter);
+	*p = cpu_to_be32(nfs4_lock_type(args->fl, 0));
+	encode_nfs4_seqid(xdr, args->seqid);
 	encode_nfs4_stateid(xdr, args->stateid);
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
@@ -1360,9 +1371,9 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * opcode 4, seqid 4, share_access 4, share_deny 4, clientid 8, ownerlen 4,
  * owner 4 = 32
  */
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_OPEN);
-	*p = cpu_to_be32(arg->seqid->sequence->counter);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_OPEN);
+	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_share_access(xdr, arg->fmode);
 	p = reserve_space(xdr, 32);
 	p = xdr_encode_hyper(p, arg->clientid);
@@ -1496,8 +1507,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_OPEN_CONFIRM);
 	encode_nfs4_stateid(xdr, arg->stateid);
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(arg->seqid->sequence->counter);
+	encode_nfs4_seqid(xdr, arg->seqid);
 	hdr->nops++;
 	hdr->replen += decode_open_confirm_maxsz;
 }
@@ -1509,8 +1519,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_OPEN_DOWNGRADE);
 	encode_nfs4_stateid(xdr, arg->stateid);
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(arg->seqid->sequence->counter);
+	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
 	hdr->replen += decode_open_downgrade_maxsz;
-- 
1.7.7.6

