Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45498 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab2EBV4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 17:56:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] mountd: parse ip address earlier
Date: Wed,  2 May 2012 17:56:12 -0400
Message-Id: <1335995775-12009-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1335995775-12009-1-git-send-email-bfields@redhat.com>
References: <1335995775-12009-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I don't see the point of waiting to the last minute to parse the ip
address.  If the client name isn't a legal ip address then this will
fail fairly quickly, so there's not much of a performance penalty.

Also, note the previous code incorrectly assumed client_resolve would
always return non-NULL.

Also factor out some common code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   40 ++++++++++++++++++++++------------------
 1 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index cf07b56..d2ac258 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -495,6 +495,19 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
 	return false;
 }
 
+struct addrinfo *lookup_client_addr(char *dom)
+{
+	struct addrinfo *ret;
+	struct addrinfo *tmp;
+
+	tmp = host_pton(dom);
+	if (tmp == NULL)
+		return NULL;
+	ret = client_resolve(tmp->ai_addr);
+	freeaddrinfo(tmp);
+	return ret;
+}
+
 static void nfsd_fh(FILE *f)
 {
 	/* request are:
@@ -538,6 +551,12 @@ static void nfsd_fh(FILE *f)
 
 	auth_reload();
 
+	if (use_ipaddr) {
+		ai = lookup_client_addr(dom);
+		if (!ai)
+			goto out;
+	}
+
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		nfs_export *next_exp;
@@ -578,18 +597,8 @@ static void nfsd_fh(FILE *f)
 
 			if (!match_fsid(&parsed, exp, path))
 				continue;
-			if (use_ipaddr) {
-				if (ai == NULL) {
-					struct addrinfo *tmp;
-					tmp = host_pton(dom);
-					if (tmp == NULL)
-						goto out;
-					ai = client_resolve(tmp->ai_addr);
-					freeaddrinfo(tmp);
-				}
-				if (!client_check(exp->m_client, ai))
-					continue;
-			}
+			if (use_ipaddr && !client_check(exp->m_client, ai))
+				continue;
 			if (!found || subexport(&exp->m_export, found)) {
 				found = &exp->m_export;
 				free(found_path);
@@ -1058,12 +1067,7 @@ static void nfsd_export(FILE *f)
 	auth_reload();
 
 	if (use_ipaddr) {
-		struct addrinfo *tmp;
-		tmp = host_pton(dom);
-		if (tmp == NULL)
-			goto out;
-		ai = client_resolve(tmp->ai_addr);
-		freeaddrinfo(tmp);
+		ai = lookup_client_addr(dom);
 		if (!ai)
 			goto out;
 	}
-- 
1.7.7.6

