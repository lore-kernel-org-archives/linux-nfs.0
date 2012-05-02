Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36415 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758065Ab2EBBni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 21:43:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] mountd: add trivial helpers for client-matching
Date: Tue,  1 May 2012 21:43:33 -0400
Message-Id: <1335923014-2789-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20120502014155.GA2684@fieldses.org>
References: <20120502014155.GA2684@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Pull out a tiny bit of common logic from three functions.

Possibly minor overkill, but simplifies the next patch.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/auth.c   |   21 ++++++++++++++++++---
 utils/mountd/cache.c  |   12 ++----------
 utils/mountd/mountd.h |    4 ++++
 3 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index ccc849a..1ed9a4b 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -131,6 +131,23 @@ get_client_hostname(const struct sockaddr *caller, struct addrinfo *ai,
 	return strdup("DEFAULT");
 }
 
+bool ipaddr_client_matches(nfs_export *exp, struct addrinfo *ai)
+{
+	return client_check(exp->m_client, ai);
+}
+
+bool namelist_client_matches(nfs_export *exp, char *dom)
+{
+	return client_member(dom, exp->m_client->m_hostname);
+}
+
+bool client_matches(nfs_export *exp, char *dom, struct addrinfo *ai)
+{
+	if (use_ipaddr)
+		return ipaddr_client_matches(exp, ai);
+	return namelist_client_matches(exp, dom);
+}
+
 /* return static nfs_export with details filled in */
 static nfs_export *
 auth_authenticate_newcache(const struct sockaddr *caller,
@@ -155,9 +172,7 @@ auth_authenticate_newcache(const struct sockaddr *caller,
 		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (strcmp(path, exp->m_export.e_path))
 				continue;
-			if (!use_ipaddr && !client_member(my_client.m_hostname, exp->m_client->m_hostname))
-				continue;
-			if (use_ipaddr && !client_check(exp->m_client, ai))
+			if (!client_matches(exp, my_client.m_hostname, ai))
 				continue;
 			break;
 		}
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 08ff150..6cc58d2 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -587,7 +587,7 @@ static void nfsd_fh(FILE *f)
 				next_exp = exp->m_next;
 			}
 
-			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
+			if (!use_ipaddr && !namelist_client_matches(exp, dom))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -597,7 +597,7 @@ static void nfsd_fh(FILE *f)
 
 			if (!match_fsid(&parsed, exp, path))
 				continue;
-			if (use_ipaddr && !client_check(exp->m_client, ai))
+			if (use_ipaddr && !ipaddr_client_matches(exp, ai))
 				continue;
 			if (!found || subexport(&exp->m_export, found)) {
 				found = &exp->m_export;
@@ -751,14 +751,6 @@ static int path_matches(nfs_export *exp, char *path)
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
 	return path_matches(exp, path) && client_matches(exp, dom, ai);
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index 4c184d2..c969a27 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -56,4 +56,8 @@ struct nfs_fh_len *
 		cache_get_filehandle(nfs_export *exp, int len, char *p);
 int		cache_export(nfs_export *exp, char *path);
 
+bool ipaddr_client_matches(nfs_export *exp, struct addrinfo *ai);
+bool namelist_client_matches(nfs_export *exp, char *dom);
+bool client_matches(nfs_export *exp, char *dom, struct addrinfo *ai);
+
 #endif /* MOUNTD_H */
-- 
1.7.7.6

