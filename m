From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 2/9] Ignore blanks in section definitions and before assignment
	statements
Date: Mon, 09 Mar 2009 16:50:08 -0400
Message-ID: <49B58100.8030906@RedHat.com>
References: <49B57FB2.9020000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49B57FB2.9020000@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 5974cd0fdc295fed36f6bc092d9569b41808d19e
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 13:55:25 2009 -0400

    Taught conf_parse_line() to ignore spaces in the
     '[section]' parsing and before the assignment statements
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 754bed9..1b8d098 100644
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
