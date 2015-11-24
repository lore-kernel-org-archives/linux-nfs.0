Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887AbbKXRSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 12:18:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] svcrpc: move some initialization to common code
Date: Tue, 24 Nov 2015 12:18:13 -0500
Message-Id: <1448385497-23737-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1448385497-23737-1-git-send-email-bfields@redhat.com>
References: <1448385497-23737-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Minor cleanup, no change in behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcauth.c      | 2 ++
 net/sunrpc/svcauth_unix.c | 8 --------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
index 79c0f3459b5c..69841db1f533 100644
--- a/net/sunrpc/svcauth.c
+++ b/net/sunrpc/svcauth.c
@@ -55,6 +55,7 @@ svc_authenticate(struct svc_rqst *rqstp, __be32 *authp)
 	spin_unlock(&authtab_lock);
 
 	rqstp->rq_auth_slack = 0;
+	init_svc_cred(&rqstp->rq_cred);
 
 	rqstp->rq_authop = aops;
 	return aops->accept(rqstp, authp);
@@ -63,6 +64,7 @@ EXPORT_SYMBOL_GPL(svc_authenticate);
 
 int svc_set_client(struct svc_rqst *rqstp)
 {
+	rqstp->rq_client = NULL;
 	return rqstp->rq_authop->set_client(rqstp);
 }
 EXPORT_SYMBOL_GPL(svc_set_client);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 621ca7b4a155..dfacdc95b3f5 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -728,10 +728,6 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
 
-	cred->cr_group_info = NULL;
-	cred->cr_principal = NULL;
-	rqstp->rq_client = NULL;
-
 	if (argv->iov_len < 3*4)
 		return SVC_GARBAGE;
 
@@ -794,10 +790,6 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	u32		slen, i;
 	int		len   = argv->iov_len;
 
-	cred->cr_group_info = NULL;
-	cred->cr_principal = NULL;
-	rqstp->rq_client = NULL;
-
 	if ((len -= 3*4) < 0)
 		return SVC_GARBAGE;
 
-- 
2.5.0

