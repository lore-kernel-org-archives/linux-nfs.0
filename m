Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636Ab1A0Stg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jan 2011 13:49:36 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0RInafY005750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:36 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p0RInZcQ018723
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] Make the stat command ignore lines that it is not looking for.
Date: Thu, 27 Jan 2011 13:49:32 -0500
Message-Id: <1296154174-13076-2-git-send-email-steved@redhat.com>
In-Reply-To: <1296154174-13076-1-git-send-email-steved@redhat.com>
References: <1296154174-13076-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 general/stat.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/general/stat.c b/general/stat.c
index c4e4fc0..2ce604e 100644
--- a/general/stat.c
+++ b/general/stat.c
@@ -30,7 +30,7 @@ main(argc, argv)
 {
 	FILE	*fp;
 	int	i, n;
-	char	c, *fmt;
+	char	c, *fmt, buf[BUFSIZ];
 	int	attfmt = 0;	/* set if using att time format */
 
 	Prog = argv[0];
@@ -45,6 +45,7 @@ main(argc, argv)
 			Prog, File);
 		exit(1);
 	}
+getnewch:
 	if ((i = fgetc(fp)) == EOF) {
 		fprintf(stderr, "%s: %s is empty\n",
 			Prog, File);
@@ -53,8 +54,12 @@ main(argc, argv)
 	c = i & 0x7f;
 	if (c == '\n' || c == '\r' || c == 'r')
 		attfmt = 1;
-	else
+	else if (isdigit(c))
 		fmt = "%lf %*s %lf %*s %lf %*s";	/* BSD fmt */
+	else { /* skip the line */
+		fgets(buf, BUFSIZ, fp);
+		goto getnewch;
+	}
 	if (ungetc(c, fp) == EOF) {
 		fprintf(stderr, "%s: can't push char back to %s\n",
 			Prog, File);
-- 
1.7.3.3

