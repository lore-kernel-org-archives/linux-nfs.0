Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33642 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbbBSTgW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Feb 2015 14:36:22 -0500
Received: by pdjz10 with SMTP id z10so1986474pdj.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2015 11:36:21 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1: Always set up a forward channel when binding the session
Date: Thu, 19 Feb 2015 11:36:10 -0800
Message-Id: <1424374571-4945-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1424374571-4945-2-git-send-email-trond.myklebust@primarydata.com>
References: <1424374571-4945-1-git-send-email-trond.myklebust@primarydata.com>
 <1424374571-4945-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the client requests a back channel or a bidirectional
connection when binding a new TCP channel to an existing session.
Fix that to ask for a forward channel or bidirectional.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 248903b138a8..97d4bdf53541 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1724,7 +1724,7 @@ static void encode_bind_conn_to_session(struct xdr_stream *xdr,
 		decode_bind_conn_to_session_maxsz, hdr);
 	encode_opaque_fixed(xdr, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	p = xdr_reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(NFS4_CDFC4_BACK_OR_BOTH);
+	*p++ = cpu_to_be32(NFS4_CDFC4_FORE_OR_BOTH);
 	*p = 0;	/* use_conn_in_rdma_mode = False */
 }
 
-- 
2.1.0

