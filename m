From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 20/67] nfs41: nfs41: pass *session in seq_args and seq_res
Date: Thu,  2 Apr 2009 16:52:58 +0300
Message-ID: <1238680378-14025-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32314 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756732AbZDBNxG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:53:06 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be used for getting the rpc's minorversion and for nfs41 xdr
{en,de}coding of the sequence operation.
Reset the seq session ptrs for minorversion=0 rpc calls.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    1 +
 include/linux/nfs_xdr.h |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 95c0ace..df2a786 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -291,6 +291,7 @@ int _nfs4_call_sync(struct nfs_server *server,
 		    struct nfs4_sequence_res *res,
 		    int cache_reply)
 {
+	args->sa_session = res->sr_session = NULL;
 	return rpc_call_sync(server->client, msg, 0);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d32a112..f933413 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -162,11 +162,11 @@ struct nfs4_slot {
 };
 
 struct nfs4_sequence_args {
-	/* stub */
+	struct nfs4_session	*sa_session;
 };
 
 struct nfs4_sequence_res {
-	/* stub */
+	struct nfs4_session	*sr_session;
 };
 
 /*
-- 
1.6.2.1

