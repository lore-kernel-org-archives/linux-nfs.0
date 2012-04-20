Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33913 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241Ab2DTWqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 18:46:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] mountd: ignore use_ipaddr and just try both client types
Date: Fri, 20 Apr 2012 18:46:18 -0400
Message-Id: <1334961978-2843-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1334961978-2843-1-git-send-email-bfields@redhat.com>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There are races when switching use_ipaddr on or off: it's possible the
kernel may still do export upcalls with the previous client type.  So,
let's just match either one.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index a6bad07..181922b 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -495,12 +495,13 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
 	return false;
 }
 
-static bool match_client(char *dom, nfs_export *exp, struct addinfo *ai)
+static bool match_client(char *dom, nfs_export *exp, struct addrinfo *ai)
 {
-	if (!use_ipaddr && client_member(dom, exp->m_client->m_hostname))
+	if (client_member(dom, exp->m_client->m_hostname))
 		return true;
-	if (use_ipaddr && ai && client_check(exp->m_client, ai))
+	if (ai && client_check(exp->m_client, ai))
 		return true;
+	return false;
 }
 
 struct addrinfo *lookup_client_addr(char *dom)
-- 
1.7.7.6

