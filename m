Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33909 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756213Ab2DTWqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 18:46:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] mountd: helper function for export upcall's client matching
Date: Fri, 20 Apr 2012 18:46:17 -0400
Message-Id: <1334961978-2843-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1334961978-2843-1-git-send-email-bfields@redhat.com>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is just minor cleanup.  It also reorders the tests
slightly--perhaps there was some performance advantage to doing them the
other way, but if so I doubt it's significant.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 0d2f76c..a6bad07 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -495,6 +495,14 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
 	return false;
 }
 
+static bool match_client(char *dom, nfs_export *exp, struct addinfo *ai)
+{
+	if (!use_ipaddr && client_member(dom, exp->m_client->m_hostname))
+		return true;
+	if (use_ipaddr && ai && client_check(exp->m_client, ai))
+		return true;
+}
+
 struct addrinfo *lookup_client_addr(char *dom)
 {
 	struct addrinfo *ret;
@@ -583,7 +591,7 @@ static void nfsd_fh(FILE *f)
 				next_exp = exp->m_next;
 			}
 
-			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
+			if (!match_client(dom, exp, ai))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -593,10 +601,6 @@ static void nfsd_fh(FILE *f)
 
 			if (!match_fsid(&parsed, exp, path))
 				continue;
-			if (use_ipaddr) {
-				if (ai && !client_check(exp->m_client, ai))
-					continue;
-			}
 			if (!found || subexport(&exp->m_export, found)) {
 				found = &exp->m_export;
 				free(found_path);
-- 
1.7.7.6

