From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 34/39] nfs41: Backchannel: update cb_sequence args and results
Date: Fri,  1 May 2009 02:25:14 +0300
Message-ID: <1241133914-1422-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2115 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758985AbZD3XZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:25:20 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Change the type of cs_addr and csr_status to 'struct sockaddr' and
'__be32' since the cb_sequence processing function will use existing
functionality that expects these types.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h     |    4 ++--
 fs/nfs/callback_xdr.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 0316a06..4bd0daf 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -84,7 +84,7 @@ struct referring_call_list {
 };
 
 struct cb_sequenceargs {
-	struct sockaddr_in		*csa_addr;
+	struct sockaddr			*csa_addr;
 	struct nfs4_sessionid		csa_sessionid;
 	uint32_t			csa_sequenceid;
 	uint32_t			csa_slotid;
@@ -95,7 +95,7 @@ struct cb_sequenceargs {
 };
 
 struct cb_sequenceres {
-	uint32_t			csr_status;
+	__be32				csr_status;
 	struct nfs4_sessionid		csr_sessionid;
 	uint32_t			csr_sequenceid;
 	uint32_t			csr_slotid;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 17cf089..27ac457 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -291,7 +291,7 @@ static unsigned decode_cb_sequence_args(struct svc_rqst *rqstp,
 	if (unlikely(p == NULL))
 		goto out;
 
-	args->csa_addr = svc_addr_in(rqstp);
+	args->csa_addr = svc_addr(rqstp);
 	args->csa_sequenceid = ntohl(*p++);
 	args->csa_slotid = ntohl(*p++);
 	args->csa_highestslotid = ntohl(*p++);
-- 
1.6.2.1

