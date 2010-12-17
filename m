Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3132 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755740Ab0LQSUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 13:20:13 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V4 7/9] NFS RPC_AUTH_GSS unsupported on v4.1 back channel
Date: Fri, 17 Dec 2010 13:20:08 -0500
Message-Id: <1292610010-19084-8-git-send-email-andros@netapp.com>
In-Reply-To: <1292610010-19084-7-git-send-email-andros@netapp.com>
References: <1292610010-19084-1-git-send-email-andros@netapp.com>
 <1292610010-19084-2-git-send-email-andros@netapp.com>
 <1292610010-19084-3-git-send-email-andros@netapp.com>
 <1292610010-19084-4-git-send-email-andros@netapp.com>
 <1292610010-19084-5-git-send-email-andros@netapp.com>
 <1292610010-19084-6-git-send-email-andros@netapp.com>
 <1292610010-19084-7-git-send-email-andros@netapp.com>
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
index 1033eae..52e6695 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -369,6 +369,9 @@ static int check_gss_callback_principal(struct nfs_client *clp,
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

