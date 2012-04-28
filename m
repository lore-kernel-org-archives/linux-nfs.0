Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42342 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435Ab2D1L2Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 07:28:16 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] mountd: add trivial helpers for client-matching
Date: Sat, 28 Apr 2012 07:28:11 -0400
Message-Id: <1335612492-22574-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20120428112639.GA22396@fieldses.org>
References: <20120428112639.GA22396@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Pull out a tiny bit of common logic from three functions.

Possibly minor overkill, but simplifies the next patch.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/auth.c   |   20 +++++++++++++++++---
 utils/mountd/cache.c  |   14 +++-----------
 utils/mountd/mountd.h |    4 ++++
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index ccc849a..7aa00c4 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -131,6 +131,22 @@ get_client_hostname(const struct sockaddr *caller, struct addrinfo *ai,
 	return strdup("DEFAULT");
 }
 
+bool ipaddr_client_matches(char *dom, nfs_export *exp, struct addrinfo *ai)
+{
+	return use_ipaddr && client_check(exp->m_client, ai);
+}
+
+bool namelist_client_matches(char *dom, nfs_export *exp, struct addrinfo *ai)
+{
+	return !use_ipaddr && client_member(dom, exp->m_client->m_hostname);
+}
+
+bool client_matches(char *dom, nfs_export *exp, struct addrinfo *ai)
+{
+	return ipaddr_client_matches(dom, exp, ai)
+		|| namelist_client_matches(dom, exp, ai);
+}
+
 /* return static nfs_export with details filled in */
 static nfs_export *
 auth_authenticate_newcache(const struct sockaddr *caller,
@@ -155,9 +171,7 @@ auth_authenticate_newcache(const struct sockaddr *caller,
 		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (strcmp(path, exp->m_export.e_path))
 				continue;
-			if (!use_ipaddr && !client_member(my_client.m_hostname, exp->m_client->m_hostname))
-				continue;
-			if (use_ipaddr && !client_check(exp->m_client, ai))
+			if (!client_matches(my_client.m_hostname, exp, ai))
 				continue;
 			break;
 		}
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 08ff150..02d5313 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -587,7 +587,7 @@ static void nfsd_fh(FILE *f)
 				next_exp = exp->m_next;
 			}
 
-			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
+			if (!namelist_client_matches(dom, exp, ai))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -597,7 +597,7 @@ static void nfsd_fh(FILE *f)
 
 			if (!match_fsid(&parsed, exp, path))
 				continue;
-			if (use_ipaddr && !client_check(exp->m_client, ai))
+			if (!ipaddr_client_matches(dom, exp, ai))
 				continue;
 			if (!found || subexport(&exp->m_export, found)) {
 				found = &exp->m_export;
@@ -751,17 +751,9 @@ static int path_matches(nfs_export *exp, char *path)
 }
 
 static int
-client_matches(nfs_export *exp, char *dom, struct addrinfo *ai)
-{
-	if (use_ipaddr)
-		return client_check(exp->m_client, ai);
-	return client_member(dom, exp->m_client->m_hostname);
-}
-
-static int
 export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
 {
-	return path_matches(exp, path) && client_matches(exp, dom, ai);
+	return path_matches(exp, path) && client_matches(dom, exp, ai);
 }
 
 static nfs_export *
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index 4c184d2..189db7e 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -56,4 +56,8 @@ struct nfs_fh_len *
 		cache_get_filehandle(nfs_export *exp, int len, char *p);
 int		cache_export(nfs_export *exp, char *path);
 
+bool ipaddr_client_matches(char *dom, nfs_export *exp, struct addrinfo *ai);
+bool namelist_client_matches(char *dom, nfs_export *exp, struct addrinfo *ai);
+bool client_matches(char *dom, nfs_export *exp, struct addrinfo *ai);
+
 #endif /* MOUNTD_H */
-- 
1.7.7.6

