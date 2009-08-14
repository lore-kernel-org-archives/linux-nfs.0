From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in encode_create_session and encode_sequence
Date: Fri, 14 Aug 2009 17:19:13 +0300
Message-ID: <1250259553-13672-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:30303
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756880AbZHNOTV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:21 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Coalesce multilpe constant RESERVE_SPACEs into one

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   22 +++++-----------------
 1 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 17915c8..d460d81 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1562,17 +1562,15 @@ static void encode_create_session(struct xdr_stream *xdr,
 	uint32_t len;
 	struct nfs_client *clp = args->client;
 
-	RESERVE_SPACE(4);
-	*p++ = cpu_to_be32(OP_CREATE_SESSION);
+	len = scnprintf(machine_name, sizeof(machine_name), "%s",
+			clp->cl_ipaddr);
 
-	RESERVE_SPACE(8);
+	RESERVE_SPACE(20 + 2*28 + 20 + len + 12);
+	*p++ = cpu_to_be32(OP_CREATE_SESSION);
 	p = xdr_encode_hyper(p, clp->cl_ex_clid);
-
-	RESERVE_SPACE(8);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
 	*p++ = cpu_to_be32(args->flags);			/*flags */
 
-	RESERVE_SPACE(2*28);			/* 2 channel_attrs */
 	/* Fore Channel */
 	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
 	*p++ = cpu_to_be32(args->fc_attrs.max_rqst_sz);	/* max req size */
@@ -1591,21 +1589,12 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->bc_attrs.max_reqs);	/* max requests */
 	*p++ = cpu_to_be32(0);				/* rdmachannel_attrs */
 
-	RESERVE_SPACE(4);
 	*p++ = cpu_to_be32(args->cb_program);		/* cb_program */
-
-	RESERVE_SPACE(4);			/* # of security flavors */
 	*p++ = cpu_to_be32(1);
-
-	RESERVE_SPACE(4);
 	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
-	RESERVE_SPACE(4);
 	*p++ = cpu_to_be32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
-	len = scnprintf(machine_name, sizeof(machine_name), "%s",
-			clp->cl_ipaddr);
-	RESERVE_SPACE(16 + len);
 	*p++ = cpu_to_be32(len);
 	p = xdr_encode_opaque_fixed(p, machine_name, len);
 	*p++ = cpu_to_be32(0);				/* UID */
@@ -1646,7 +1635,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
 	slot = tp->slots + args->sa_slotid;
 
-	RESERVE_SPACE(4);
+	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN + 16);
 	*p++ = cpu_to_be32(OP_SEQUENCE);
 
 	/*
@@ -1661,7 +1650,6 @@ static void encode_sequence(struct xdr_stream *xdr,
 		((u32 *)session->sess_id.data)[3],
 		slot->seq_nr, args->sa_slotid,
 		tp->highest_used_slotid, args->sa_cache_this);
-	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 16);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(slot->seq_nr);
 	*p++ = cpu_to_be32(args->sa_slotid);
-- 
1.6.4

