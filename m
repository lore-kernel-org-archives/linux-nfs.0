Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbbD3SJG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 14:09:06 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 663E48E774
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2015 18:09:06 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-56-224.rdu2.redhat.com [10.10.56.224])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t3UI95Ua000381
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2015 14:09:05 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Handle NULL names better
Date: Thu, 30 Apr 2015 14:09:03 -0400
Message-Id: <1430417344-25020-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Detect when an application passes in NULL names
and fail gracefully instead of crashing hard.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfsidmap.c | 5 ++++-
 nss.c         | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/libnfsidmap.c b/libnfsidmap.c
index 833f94c..a8a9229 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -100,8 +100,11 @@ static char * toupper_str(char *s)
 
 static int id_as_chars(char *name, uid_t *id)
 {
-	long int value = strtol(name, NULL, 10);
+	long int value;
 
+	if (name == NULL)
+		return 0;
+	value = strtol(name, NULL, 10);
 	if (value == 0) {
 		/* zero value ids are valid */
 		if (strcmp(name, "0") != 0)
diff --git a/nss.c b/nss.c
index f8129fe..b3fef5a 100644
--- a/nss.c
+++ b/nss.c
@@ -135,6 +135,9 @@ static char *strip_domain(const char *name, const char *domain)
 	char *l = NULL;
 	int len;
 
+	if (name == NULL)
+		goto out;
+
 	c = strrchr(name, '@');
 	if (c == NULL && domain != NULL)
 		goto out;
-- 
2.1.0

