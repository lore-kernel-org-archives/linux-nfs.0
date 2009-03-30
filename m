From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 6/7] SQUASHME: nfs41: get fs_locations replen before encoding the GETATTR
Date: Mon, 30 Mar 2009 17:00:46 +0300
Message-ID: <1238421646-25160-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15346 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752789AbZC3OAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:52 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 358efe2..ff847fa 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2356,15 +2356,17 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
+	uint32_t replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
+	replen = hdr.replen;	/* get the attribute into args->page */
 	encode_fs_locations(&xdr, args->bitmask, &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, &args->page,
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
 			0, PAGE_SIZE);
 	encode_nops(&hdr);
 	return 0;
-- 
1.6.2.1

