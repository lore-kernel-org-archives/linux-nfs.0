Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34530 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550Ab1FIXEV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:04:21 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 04/11] nfs:  Use request destination addr as callback source addr.
Date: Thu,  9 Jun 2011 16:02:48 -0700
Message-Id: <1307660575-6994-5-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
References: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This helps make sure that responses use the correct
source address on multi-homed machines.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 b257383... 00902ec... M	fs/nfs/callback.h
:100644 100644 c6c86a7... ed5be89... M	fs/nfs/callback_xdr.c
:100644 100644 ea29330... 45d5d7c... M	include/linux/sunrpc/svc.h
 fs/nfs/callback.h          |    3 +++
 fs/nfs/callback_xdr.c      |    3 +++
 include/linux/sunrpc/svc.h |    5 +++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b257383..00902ec 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -57,6 +57,7 @@ struct cb_compound_hdr_res {
 
 struct cb_getattrargs {
 	struct sockaddr *addr;
+	struct sockaddr *srcaddr;
 	struct nfs_fh fh;
 	uint32_t bitmap[2];
 };
@@ -72,6 +73,7 @@ struct cb_getattrres {
 
 struct cb_recallargs {
 	struct sockaddr *addr;
+	struct sockaddr *srcaddr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
@@ -92,6 +94,7 @@ struct referring_call_list {
 
 struct cb_sequenceargs {
 	struct sockaddr			*csa_addr;
+	struct sockaddr                 *csa_daddr;
 	struct nfs4_sessionid		csa_sessionid;
 	uint32_t			csa_sequenceid;
 	uint32_t			csa_slotid;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c6c86a7..ed5be89 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -196,6 +196,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	if (unlikely(status != 0))
 		goto out;
 	args->addr = svc_addr(rqstp);
+	args->srcaddr = svc_daddr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
@@ -208,6 +209,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 status;
 
 	args->addr = svc_addr(rqstp);
+	args->srcaddr = svc_daddr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
@@ -442,6 +444,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 		goto out;
 
 	args->csa_addr = svc_addr(rqstp);
+	args->csa_daddr = svc_daddr(rqstp);
 	args->csa_sequenceid = ntohl(*p++);
 	args->csa_slotid = ntohl(*p++);
 	args->csa_highestslotid = ntohl(*p++);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index ea29330..45d5d7c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -299,6 +299,11 @@ static inline struct sockaddr *svc_addr(const struct svc_rqst *rqst)
 	return (struct sockaddr *) &rqst->rq_addr;
 }
 
+static inline struct sockaddr *svc_daddr(struct svc_rqst *rqst)
+{
+	return (struct sockaddr *) &rqst->rq_daddr;
+}
+
 /*
  * Check buffer bounds after decoding arguments
  */
-- 
1.7.3.4

