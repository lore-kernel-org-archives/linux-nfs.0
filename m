Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36024 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbFDWkX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 18:40:23 -0400
Received: by igbpi8 with SMTP id pi8so2392238igb.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 15:40:23 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: William.Adamson@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: deny backchannel RPCs with an incorrect authflavor instead of dropping them
Date: Thu,  4 Jun 2015 18:40:13 -0400
Message-Id: <1433457613-23300-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A drop should really only be done when the frame is malformed or we have
reason to think that there is some sort of DoS going on. When we get an
RPC with bad auth, we should send back an error instead.

Cc: Andy Adamson <William.Adamson@netapp.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/callback.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 8d129bb7355a..682529c00996 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -458,7 +458,7 @@ check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
  * pg_authenticate method for nfsv4 callback threads.
  *
  * The authflavor has been negotiated, so an incorrect flavor is a server
- * bug. Drop packets with incorrect authflavor.
+ * bug. Deny packets with incorrect authflavor.
  *
  * All other checking done after NFS decoding where the nfs_client can be
  * found in nfs4_callback_compound
@@ -468,12 +468,12 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 	switch (rqstp->rq_authop->flavour) {
 	case RPC_AUTH_NULL:
 		if (rqstp->rq_proc != CB_NULL)
-			return SVC_DROP;
+			return SVC_DENIED;
 		break;
 	case RPC_AUTH_GSS:
 		/* No RPC_AUTH_GSS support yet in NFSv4.1 */
 		 if (svc_is_backchannel(rqstp))
-			return SVC_DROP;
+			return SVC_DENIED;
 	}
 	return SVC_OK;
 }
-- 
2.4.2

