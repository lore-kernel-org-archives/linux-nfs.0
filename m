Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758550Ab3ENVMz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:12:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] svcrpc: introduce init_svc_cred
Date: Tue, 14 May 2013 17:12:51 -0400
Message-Id: <1368565973-16739-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1368565973-16739-1-git-send-email-bfields@redhat.com>
References: <1368565973-16739-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Common helper to zero out fields of the svc_cred.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svcauth.h    |    7 +++++++
 net/sunrpc/auth_gss/svcauth_gss.c |    6 ++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index ff374ab..95c9566 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -25,6 +25,13 @@ struct svc_cred {
 	char			*cr_principal; /* for gss */
 };
 
+static inline void init_svc_cred(struct svc_cred *cred)
+{
+	cred->cr_group_info = NULL;
+	cred->cr_principal = NULL;
+	cred->cr_gss_mech = NULL;
+}
+
 static inline void free_svc_cred(struct svc_cred *cred)
 {
 	if (cred->cr_group_info)
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 871c73c..c59f875 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -377,8 +377,7 @@ rsc_init(struct cache_head *cnew, struct cache_head *ctmp)
 	new->handle.data = tmp->handle.data;
 	tmp->handle.data = NULL;
 	new->mechctx = NULL;
-	new->cred.cr_group_info = NULL;
-	new->cred.cr_principal = NULL;
+	init_svc_cred(&new->cred);
 }
 
 static void
@@ -392,9 +391,8 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 	memset(&new->seqdata, 0, sizeof(new->seqdata));
 	spin_lock_init(&new->seqdata.sd_lock);
 	new->cred = tmp->cred;
-	tmp->cred.cr_group_info = NULL;
 	new->cred.cr_principal = tmp->cred.cr_principal;
-	tmp->cred.cr_principal = NULL;
+	init_svc_cred(&tmp->cred);
 }
 
 static struct cache_head *
-- 
1.7.9.5

