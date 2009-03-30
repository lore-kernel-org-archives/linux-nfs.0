From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 7/7] SQUASHME: nfs41: get getacl replen before encoding the GETATTR
Date: Mon, 30 Mar 2009 17:00:49 +0300
Message-ID: <1238421649-25216-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14497 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752318AbZC3OAy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:54 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ff847fa..302bf47 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2137,14 +2137,16 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
+	uint32_t replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
+	replen = hdr.replen + nfs4_fattr_bitmap_maxsz + 1;
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
 		args->acl_pages, args->acl_pgbase, args->acl_len);
 	encode_nops(&hdr);
 	return 0;
-- 
1.6.2.1

