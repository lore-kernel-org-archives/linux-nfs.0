Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756216Ab2DTWqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 18:46:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] mountd: unconditionally resolve ip address
Date: Fri, 20 Apr 2012 18:46:16 -0400
Message-Id: <1334961978-2843-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1334961978-2843-1-git-send-email-bfields@redhat.com>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I don't see the point of waiting to the last minute to resolve an ip
address.  If the client name isn't a legal ip address then this will
fail fairly quickly, so there's not much of a performance penalty.

Also, note the previous code incorrectly assumed client_resolve would
always return non-NULL.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ac9cdbd..0d2f76c 100644
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
@@ -538,6 +551,8 @@ static void nfsd_fh(FILE *f)
 
 	auth_reload();
 
+	ai = lookup_client_addr(dom);
+
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		nfs_export *next_exp;
@@ -579,15 +594,7 @@ static void nfsd_fh(FILE *f)
 			if (!match_fsid(&parsed, exp, path))
 				continue;
 			if (use_ipaddr) {
-				if (ai == NULL) {
-					struct addrinfo *tmp;
-					tmp = host_pton(dom);
-					if (tmp == NULL)
-						goto out;
-					ai = client_resolve(tmp->ai_addr);
-					freeaddrinfo(tmp);
-				}
-				if (!client_check(exp->m_client, ai))
+				if (ai && !client_check(exp->m_client, ai))
 					continue;
 			}
 			if (!found || subexport(&exp->m_export, found)) {
-- 
1.7.7.6

