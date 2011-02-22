Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27802 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab1BVWn0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 17:43:26 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: fix decode_cb_sequence4resok
Date: Tue, 22 Feb 2011 14:43:22 -0800
Message-Id: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix bug introduced in patch
85a56480 NFSD: Update XDR decoders in NFSv4 callback client

Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
it must account for their space in their xdr stream when calling xdr_inline_decode

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index da54498..d046bdb 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -592,7 +592,7 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 	 * If the server returns different values for sessionID, slotID or
 	 * sequence number, the server is looney tunes.
 	 */
-	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4);
+	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4 + 4 + 4);
 	if (unlikely(p == NULL))
 		goto out_overflow;
 	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
-- 
1.7.3.4

