Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38456 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab1ADUnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 15:43:43 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V7 10/12] NFS RPC_AUTH_GSS unsupported on v4.1 back channel
Date: Tue,  4 Jan 2011 15:42:44 -0500
Message-Id: <1294173766-5573-11-git-send-email-andros@netapp.com>
In-Reply-To: <1294173766-5573-10-git-send-email-andros@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
 <1294173766-5573-2-git-send-email-andros@netapp.com>
 <1294173766-5573-3-git-send-email-andros@netapp.com>
 <1294173766-5573-4-git-send-email-andros@netapp.com>
 <1294173766-5573-5-git-send-email-andros@netapp.com>
 <1294173766-5573-6-git-send-email-andros@netapp.com>
 <1294173766-5573-7-git-send-email-andros@netapp.com>
 <1294173766-5573-8-git-send-email-andros@netapp.com>
 <1294173766-5573-9-git-send-email-andros@netapp.com>
 <1294173766-5573-10-git-send-email-andros@netapp.com>
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
index 7b3ff08..b1b09a6 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -384,6 +384,9 @@ static int check_gss_callback_principal(struct nfs_client *clp,
 	struct rpc_clnt *r = clp->cl_rpcclient;
 	char *p = svc_gss_principal(rqstp);
 
+	/* No RPC_AUTH_GSS on NFSv4.1 back channel yet */
+	if (clp->cl_minorversion != 0)
+		return SVC_DROP;
 	/*
 	 * It might just be a normal user principal, in which case
 	 * userspace won't bother to tell us the name at all.
-- 
1.6.6

