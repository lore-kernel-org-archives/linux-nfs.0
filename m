Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36633 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804Ab1AFCFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 21:05:12 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V9 10/12] NFS RPC_AUTH_GSS unsupported on v4.1 back channel
Date: Wed,  5 Jan 2011 21:04:33 -0500
Message-Id: <1294279475-8540-11-git-send-email-andros@netapp.com>
In-Reply-To: <1294279475-8540-10-git-send-email-andros@netapp.com>
References: <1294279475-8540-1-git-send-email-andros@netapp.com>
 <1294279475-8540-2-git-send-email-andros@netapp.com>
 <1294279475-8540-3-git-send-email-andros@netapp.com>
 <1294279475-8540-4-git-send-email-andros@netapp.com>
 <1294279475-8540-5-git-send-email-andros@netapp.com>
 <1294279475-8540-6-git-send-email-andros@netapp.com>
 <1294279475-8540-7-git-send-email-andros@netapp.com>
 <1294279475-8540-8-git-send-email-andros@netapp.com>
 <1294279475-8540-9-git-send-email-andros@netapp.com>
 <1294279475-8540-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Acked-by: Bruce Fields <bfields@redhat.com>
---
 fs/nfs/callback.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 15677e7..753a9e3 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -365,6 +365,9 @@ static int check_gss_callback_principal(struct nfs_client *clp,
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

