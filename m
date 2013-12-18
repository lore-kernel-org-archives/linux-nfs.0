Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273Ab3LRUGa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Dec 2013 15:06:30 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBIK6ULs023007
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 15:06:30 -0500
Received: from tasleson.csb (vpn-229-185.phx2.redhat.com [10.3.229.185])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id rBIK6TMX032331
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 15:06:29 -0500
From: Tony Asleson <tasleson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] exportfs.c: Escape path for '-s' option
Date: Wed, 18 Dec 2013 14:06:29 -0600
Message-Id: <1387397189-9591-3-git-send-email-tasleson@redhat.com>
In-Reply-To: <1387397189-9591-1-git-send-email-tasleson@redhat.com>
References: <1387397189-9591-1-git-send-email-tasleson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When outputing the paths and the user has specified the option
-s, escape the path.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 utils/exportfs/exportfs.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 019961b..9ea86cb 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -666,6 +666,9 @@ dumpopt(char c, char *fmt, ...)
 static void
 dump(int verbose, int export_format)
 {
+	char buf[1024];
+	char *bp;
+	int len;
 	nfs_export	*exp;
 	struct exportent *ep;
 	int		htype;
@@ -683,7 +686,15 @@ dump(int verbose, int export_format)
 			if (strlen(ep->e_path) > 14 && !export_format)
 				printf("%-14s\n\t\t%s", ep->e_path, hname);
 			else
-				printf(((export_format)? "%s %s" : "%-14s\t%s"), ep->e_path, hname);
+				if (export_format) {
+					bp = buf;
+					len = sizeof(buf) - 1;
+					qword_add(&bp, &len, ep->e_path);
+					*bp = '\0';
+					printf("%s %s", buf, hname);
+				} else {
+					printf("%-14s\t%s", ep->e_path, hname);
+				}
 
 			if (!verbose && !export_format) {
 				printf("\n");
-- 
1.8.2.1

