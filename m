Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:42668 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758045Ab2CFAOi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 19:14:38 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1S4i31-0003mi-LI
	for linux-nfs@vger.kernel.org; Mon, 05 Mar 2012 19:14:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] nfsmount: Fixed parsing error in the nfsmount.conf code.
Date: Mon,  5 Mar 2012 19:13:20 -0500
Message-Id: <1330992800-6895-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the options where prefixed with spaces (instead of tabs)
the second option in the list was missed to so a miscalculation
the the nfsmount.conf parsing code.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/conffile.c |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 3990578..2f1e235 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -211,7 +211,7 @@ static void
 conf_parse_line(int trans, char *line, size_t sz)
 {
 	char *val, *ptr;
-	size_t i;
+	size_t i, valsize;
 	size_t j;
 	static char *section = 0;
 	static char *arg = 0;
@@ -298,23 +298,16 @@ conf_parse_line(int trans, char *line, size_t sz)
 			}
 			line[strcspn (line, " \t=")] = '\0';
 			val = line + i + 1 + strspn (line + i + 1, " \t");
+			valsize = 0;
+			while (val[valsize++]);
 
-			/* Skip trailing comments, if any */
-			for (j = 0; j < sz - (val - line); j++) {
-				if (val[j] == '#' || val[j] == ';') {
+			/* Skip trailing spaces and comments */
+			for (j = 0; j < valsize; j++) {
+				if (val[j] == '#' || val[j] == ';' || isspace(val[j])) {
 					val[j] = '\0';
 					break;
 				}
 			}
-
-			/* Skip trailing whitespace, if any */
-			for (j--; j > 0; j--) {
-				if (isspace(val[j]))
-					val[j] = '\0';
-				else 
-					break;
-			}
-
 			/* XXX Perhaps should we not ignore errors?  */
 			conf_set(trans, section, arg, line, val, 0, 0);
 			return;
-- 
1.7.7.5

