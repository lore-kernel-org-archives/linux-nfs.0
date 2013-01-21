Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39857 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab3AUUqm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:46:42 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 04/13] nfs: Use request destination addr as callback source addr.
Date: Mon, 21 Jan 2013 12:45:50 -0800
Message-Id: <1358801159-18829-5-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This helps make sure that responses use the correct
source address on multi-homed machines.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/callback.h          |    3 +++
 fs/nfs/callback_xdr.c      |    3 +++
 include/linux/sunrpc/svc.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 4251c2a..1a695f7 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -59,6 +59,7 @@ struct cb_compound_hdr_res {
 
 struct cb_getattrargs {
 	struct sockaddr *addr;
+	struct sockaddr *srcaddr;
 	struct nfs_fh fh;
 	uint32_t bitmap[2];
 };
@@ -74,6 +75,7 @@ struct cb_getattrres {
 
 struct cb_recallargs {
 	struct sockaddr *addr;
+	struct sockaddr *srcaddr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
@@ -94,6 +96,7 @@ struct referring_call_list {
 
 struct cb_sequenceargs {
 	struct sockaddr			*csa_addr;
+	struct sockaddr                 *csa_daddr;
 	struct nfs4_sessionid		csa_sessionid;
 	uint32_t			csa_sequenceid;
 	uint32_t			csa_slotid;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 742ff4f..75cff02 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -198,6 +198,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	if (unlikely(status != 0))
 		goto out;
 	args->addr = svc_addr(rqstp);
+	args->srcaddr = svc_daddr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
@@ -210,6 +211,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 status;
 
 	args->addr = svc_addr(rqstp);
+	args->srcaddr = svc_daddr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
@@ -448,6 +450,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 		goto out;
 
 	args->csa_addr = svc_addr(rqstp);
+	args->csa_daddr = svc_daddr(rqstp);
 	args->csa_sequenceid = ntohl(*p++);
 	args->csa_slotid = ntohl(*p++);
 	args->csa_highestslotid = ntohl(*p++);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index d83db80..bf134c3 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -313,6 +313,7 @@ static inline struct sockaddr *svc_daddr(const struct svc_rqst *rqst)
 	return (struct sockaddr *) &rqst->rq_daddr;
 }
 
+
 /*
  * Check buffer bounds after decoding arguments
  */
-- 
1.7.3.4

