Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52610 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbdITQmN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Sep 2017 12:42:13 -0400
Date: Wed, 20 Sep 2017 12:42:13 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: RPC_MAX_AUTH_SIZE is in bytes
Message-ID: <20170920164213.GF14329@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The units of RPC_MAX_AUTH_SIZE is bytes, not 4-byte words.  This causes
the client to request a larger-than-necessary session replay slot size.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 37c8af003275..14ed9791ec9c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1842,8 +1842,8 @@ static void encode_create_session(struct xdr_stream *xdr,
 	 * Assumes OPEN is the biggest non-idempotent compound.
 	 * 2 is the verifier.
 	 */
-	max_resp_sz_cached = (NFS4_dec_open_sz + RPC_REPHDRSIZE +
-			      RPC_MAX_AUTH_SIZE + 2) * XDR_UNIT;
+	max_resp_sz_cached = (NFS4_dec_open_sz + RPC_REPHDRSIZE + 2)
+				* XDR_UNIT + RPC_MAX_AUTH_SIZE;
 
 	encode_op_hdr(xdr, OP_CREATE_SESSION, decode_create_session_maxsz, hdr);
 	p = reserve_space(xdr, 16 + 2*28 + 20 + clnt->cl_nodelen + 12);
-- 
2.13.5

