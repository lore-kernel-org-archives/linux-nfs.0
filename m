Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17919 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758222Ab0LTWKj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 17:10:39 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V5 09/11] NFS RPC_AUTH_GSS unsupported on v4.1 back channel
Date: Mon, 20 Dec 2010 16:04:46 -0500
Message-Id: <1292879088-7821-10-git-send-email-andros@netapp.com>
In-Reply-To: <1292879088-7821-9-git-send-email-andros@netapp.com>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <1292879088-7821-3-git-send-email-andros@netapp.com>
 <1292879088-7821-4-git-send-email-andros@netapp.com>
 <1292879088-7821-5-git-send-email-andros@netapp.com>
 <1292879088-7821-6-git-send-email-andros@netapp.com>
 <1292879088-7821-7-git-send-email-andros@netapp.com>
 <1292879088-7821-8-git-send-email-andros@netapp.com>
 <1292879088-7821-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 541be39..4a9c517 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -368,6 +368,9 @@ static int check_gss_callback_principal(struct nfs_client *clp,
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

