From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 2/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:41:22 -0400
Message-ID: <4A7B23D2.6080900@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35272 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbZHFSoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 14:44:37 -0400
In-Reply-To: <4A7B2324.9090406-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit f6f4d0b872c01eaffbcb4c3919f13237aa8678e1
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 13:55:25 2009 -0400

    Taught conf_parse_line() to ignore spaces in the
     '[section]' parsing and before the assignment statements
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index c5f9fa7..5f491eb 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -50,11 +50,6 @@
 #include "xlog.h"
 
 static void conf_load_defaults (int);
-#if 0
-static int conf_find_trans_xf (int, char *);
-#endif
-
-size_t  strlcpy(char *, const char *, size_t);
 
 struct conf_trans {
 	TAILQ_ENTRY (conf_trans) link;
@@ -219,26 +214,48 @@ conf_parse_line(int trans, char *line, size_t sz)
 	if (*line == '#' || *line == ';')
 		return;
 
+	/* Ignore blank lines */
+	if (*line == '\0')
+		return;
+
+	/* Strip off any leading blanks */
+	while (isblank(*line)) 
+		line++;
+
 	/* '[section]' parsing...  */
 	if (*line == '[') {
-		for (i = 1; i < sz; i++)
-			if (line[i] == ']')
+		line++;
+		/* Strip off any blanks after '[' */
+		while (isblank(*line)) 
+			line++;
+
+		for (i = 0; i < sz; i++) {
+			if (line[i] == ']') {
 				break;
+			}
+		}
 		if (section)
-			free (section);
+			free(section);
 		if (i == sz) {
 			xlog_warn("conf_parse_line: %d:"
  				"non-matched ']', ignoring until next section", ln);
 			section = 0;
 			return;
 		}
+		/* Strip off any blanks before ']' */
+		val = line;
+		while (*val && !isblank(*val)) 
+			val++, j++;
+		if (*val)
+			i = j;
+
 		section = malloc(i);
 		if (!section) {
 			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
 						(unsigned long)i);
 			return;
 		}
-		strlcpy(section, line + 1, i);
+		strncpy(section, line, i);
 		return;
 	}
 

