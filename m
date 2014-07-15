Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754094AbaGOPJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:50 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/15] Clean up: Remove newlines from a couple debugging calls.
Date: Tue, 15 Jul 2014 11:09:28 -0400
Message-Id: <1405436974-4161-10-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c | 8 ++++----
 src/netnamer.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index d8d5a72..bab591c 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -169,7 +169,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 		free(auth);
 		return (NULL);
 	}
-	LIBTIRPC_DEBUG(2, ("authgss_create: name is %p\n", name));
+	LIBTIRPC_DEBUG(3, ("authgss_create: name is %p", name));
 	if (name != GSS_C_NO_NAME) {
 		if (gss_duplicate_name(&min_stat, name, &gd->name)
 						!= GSS_S_COMPLETE) {
@@ -182,7 +182,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	else
 		gd->name = name;
 
-	LIBTIRPC_DEBUG(2, ("authgss_create: gd->name is %p\n", gd->name));
+	LIBTIRPC_DEBUG(3, ("authgss_create: gd->name is %p", gd->name));
 	gd->clnt = clnt;
 	gd->ctx = GSS_C_NO_CONTEXT;
 	gd->sec = *sec;
@@ -235,7 +235,7 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
 	auth = authgss_create(clnt, name, sec);
 
 	if (name != GSS_C_NO_NAME) {
-		LIBTIRPC_DEBUG(1, ("authgss_create_default: freeing name %p\n", name));
+		LIBTIRPC_DEBUG(3, ("authgss_create_default: freeing name %p", name));
  		gss_release_name(&min_stat, &name);
 	}
 
@@ -626,7 +626,7 @@ authgss_destroy(AUTH *auth)
 
 	authgss_destroy_context(auth);
 
-	LIBTIRPC_DEBUG(2, ("authgss_destroy: freeing name %p\n", gd->name));
+	LIBTIRPC_DEBUG(3, ("authgss_destroy: freeing name %p", gd->name));
 	if (gd->name != GSS_C_NO_NAME)
 		gss_release_name(&min_stat, &gd->name);
 
diff --git a/src/netnamer.c b/src/netnamer.c
index 7da2f0d..53ba73b 100644
--- a/src/netnamer.c
+++ b/src/netnamer.c
@@ -279,7 +279,7 @@ getnetid(key, ret)
 			err = yp_match(domain, NETID, key,
 				strlen(key), &lookup, &len);
 			if (err) {
-				LIBTIRPC_DEBUG(1, ("getnetid: match failed error %d\n", err));
+				LIBTIRPC_DEBUG(1, ("getnetid: match failed error %d", err));
 				continue;
 			}
 			lookup[len] = 0;
-- 
1.9.3

