From: Andy Adamson <andros@netapp.com>
Subject: [PATCH_V3 5/7] NFS RPC_AUTH_GSS unsupported on v4.1 back channel
Date: Mon, 13 Dec 2010 15:19:43 -0500
Message-ID: <1292271585-3038-6-git-send-email-andros@netapp.com>
References: <1292271585-3038-1-git-send-email-andros@netapp.com>
 <1292271585-3038-2-git-send-email-andros@netapp.com>
 <1292271585-3038-3-git-send-email-andros@netapp.com>
 <1292271585-3038-4-git-send-email-andros@netapp.com>
 <1292271585-3038-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151Ab0LMUUA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 15:20:00 -0500
In-Reply-To: <1292271585-3038-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 7c21824..dc2ead1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -360,6 +360,9 @@ static int check_gss_callback_principal(struct nfs_client *clp,
 	struct rpc_clnt *r = clp->cl_rpcclient;
 	char *p = svc_gss_principal(rqstp);
 
+	/* No RPC_AUTH_GSS on NFSv4.1 back channel yet */
+	if (clp->cl_minorversion != 0)
+		return SVC_DENIED;
 	/*
 	 * It might just be a normal user principal, in which case
 	 * userspace won't bother to tell us the name at all.
-- 
1.6.6

