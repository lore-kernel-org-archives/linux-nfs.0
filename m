Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57379 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2DXPAJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 11:00:09 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: SteveD@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] mountd: support IPv6 [] escaping with fsloc hosts
Date: Tue, 24 Apr 2012 11:00:07 -0400
Message-Id: <1335279607-46861-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mountd uses colons to split fsloc hosts, but this doesn't work with IPv6
addresses (they contain ':').
To fix this, mountd is changed to expect all IPv6 addresses to be escaped
by '[' and ']' so colons that are part of the address may be skipped.
To fix IPv6 referrals, this patch must be used with the nfsd patch that
properly parses escaped IPv6 addresses in fs_location->hosts.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 utils/mountd/fsloc.c |   20 +++++++++++++++++---
 1 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/fsloc.c b/utils/mountd/fsloc.c
index 704b7a0..bc737d1 100644
--- a/utils/mountd/fsloc.c
+++ b/utils/mountd/fsloc.c
@@ -120,10 +120,11 @@ static struct servers *parse_list(char **list)
  */
 static struct servers *method_list(char *data)
 {
-	char *copy, *ptr=data;
+	char *copy, *ptr=data, *p;
 	char **list;
 	int i, listsize;
 	struct servers *rv=NULL;
+	bool v6esc = false;
 
 	xlog(L_NOTICE, "method_list(%s)", data);
 	for (ptr--, listsize=1; ptr; ptr=index(ptr, ':'), listsize++)
@@ -134,9 +135,22 @@ static struct servers *method_list(char *data)
 		xlog(L_NOTICE, "converted to %s", copy);
 	if (list && copy) {
 		ptr = copy;
-		for (i=0; i<listsize; i++) {
-			list[i] = strsep(&ptr, ":");
+		for (p = ptr, i = 0; *p && i < listsize; p++) {
+			if (*p == '[')
+				v6esc = true;
+			else if (*p == ']')
+				v6esc = false;
+
+			if (!v6esc && *p == ':') {
+				*p = '\0';
+				if (*ptr)
+					list[i++] = ptr;
+				ptr = p + 1;
+			}
 		}
+		if (*ptr)
+			list[i++] = ptr;
+		list[i] = NULL;
 		rv = parse_list(list);
 	}
 	free(copy);
-- 
1.7.4.4

