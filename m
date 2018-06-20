Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751092AbeFTMLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Jun 2018 08:11:44 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2615D4023826
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 12:11:44 +0000 (UTC)
Message-ID: <1529496701.7473.9.camel@redhat.com>
Subject: [PATCH 1/5] nfs-utils: Ignore empty lines in config
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 20 Jun 2018 13:11:41 +0100
In-Reply-To: <1529496583.7473.8.camel@redhat.com>
References: <1529496583.7473.8.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The test for empty lines didn't ignore whitespace properly

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index ee94031..d20460e 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -255,14 +255,14 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 	char *inc_section = NULL, *inc_subsection = NULL;
 	char *relpath, *subconf;
 
+	/* Strip off any leading blanks */
+	while (isspace(*line))
+		line++;
+
 	/* Ignore blank lines */
 	if (*line == '\0')
 		return;
 
-	/* Strip off any leading blanks */
-	while (isblank(*line))
-		line++;
-
 	/* Lines starting with '#' or ';' are comments.  */
 	if (*line == '#' || *line == ';')
 		return;
-- 
1.8.3.1



