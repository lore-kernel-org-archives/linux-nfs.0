From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/5] NFSv4: Clean up for lockowner XDR encoding
Date: Wed, 30 Jun 2010 17:25:35 -0400
Message-ID: <1277933137-6955-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-3-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757272Ab0F3VZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 17:25:55 -0400
In-Reply-To: <1277933137-6955-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 873b62f..49df05a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -202,14 +202,17 @@ static int nfs4_stat_to_errno(int);
 #define encode_link_maxsz	(op_encode_hdr_maxsz + \
 				nfs4_name_maxsz)
 #define decode_link_maxsz	(op_decode_hdr_maxsz + decode_change_info_maxsz)
+#define encode_lockowner_maxsz	(7)
 #define encode_lock_maxsz	(op_encode_hdr_maxsz + \
 				 7 + \
-				 1 + encode_stateid_maxsz + 8)
+				 1 + encode_stateid_maxsz + 1 + \
+				 encode_lockowner_maxsz)
 #define decode_lock_denied_maxsz \
 				(8 + decode_lockowner_maxsz)
 #define decode_lock_maxsz	(op_decode_hdr_maxsz + \
 				 decode_lock_denied_maxsz)
-#define encode_lockt_maxsz	(op_encode_hdr_maxsz + 12)
+#define encode_lockt_maxsz	(op_encode_hdr_maxsz + 5 + \
+				encode_lockowner_maxsz)
 #define decode_lockt_maxsz	(op_decode_hdr_maxsz + \
 				 decode_lock_denied_maxsz)
 #define encode_locku_maxsz	(op_encode_hdr_maxsz + 3 + \
@@ -1042,6 +1045,17 @@ static inline uint64_t nfs4_lock_length(struct file_lock *fl)
 	return fl->fl_end - fl->fl_start + 1;
 }
 
+static void encode_lockowner(struct xdr_stream *xdr, const struct nfs_lowner *lowner)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 28);
+	p = xdr_encode_hyper(p, lowner->clientid);
+	*p++ = cpu_to_be32(16);
+	p = xdr_encode_opaque_fixed(p, "lock id:", 8);
+	xdr_encode_hyper(p, lowner->id);
+}
+
 /*
  * opcode,type,reclaim,offset,length,new_lock_owner = 32
  * open_seqid,open_stateid,lock_seqid,lock_owner.clientid, lock_owner.id = 40
@@ -1058,14 +1072,11 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	*p = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
-		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+32);
+		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
 		p = xdr_encode_opaque_fixed(p, args->open_stateid->data, NFS4_STATEID_SIZE);
 		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
-		p = xdr_encode_hyper(p, args->lock_owner.clientid);
-		*p++ = cpu_to_be32(16);
-		p = xdr_encode_opaque_fixed(p, "lock id:", 8);
-		xdr_encode_hyper(p, args->lock_owner.id);
+		encode_lockowner(xdr, &args->lock_owner);
 	}
 	else {
 		p = reserve_space(xdr, NFS4_STATEID_SIZE+4);
@@ -1080,15 +1091,12 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 52);
+	p = reserve_space(xdr, 24);
 	*p++ = cpu_to_be32(OP_LOCKT);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
-	p = xdr_encode_hyper(p, args->lock_owner.clientid);
-	*p++ = cpu_to_be32(16);
-	p = xdr_encode_opaque_fixed(p, "lock id:", 8);
-	xdr_encode_hyper(p, args->lock_owner.id);
+	encode_lockowner(xdr, &args->lock_owner);
 	hdr->nops++;
 	hdr->replen += decode_lockt_maxsz;
 }
-- 
1.7.0.1

