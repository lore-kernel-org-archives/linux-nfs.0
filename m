Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36530 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752480AbcLBD7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:48 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:29 +1100
Subject: [PATCH 10/15] conffile: strip "quotes" from values in conf file.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110966.28046.11665582674746389410.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When "include = " is used to read and "environment" file such as
/etc/sysconfig/nfs, there might be quotes around values.
Stripe those off, just like a 'shell' reading the file would.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |   25 ++++++++++++++++---------
 systemd/nfs.conf.man   |    2 ++
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 8de580bd6970..947bf9bad1e7 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -212,7 +212,7 @@ static void
 conf_parse_line(int trans, char *line, size_t sz)
 {
 	char *val, *ptr;
-	size_t i, valsize;
+	size_t i;
 	size_t j;
 	static char *section = 0;
 	static char *arg = 0;
@@ -299,16 +299,23 @@ conf_parse_line(int trans, char *line, size_t sz)
 			}
 			line[strcspn (line, " \t=")] = '\0';
 			val = line + i + 1 + strspn (line + i + 1, " \t");
-			valsize = 0;
-			while (val[valsize++]);
 
-			/* Skip trailing spaces and comments */
-			for (j = 0; j < valsize; j++) {
-				if (val[j] == '#' || val[j] == ';' || isspace(val[j])) {
-					val[j] = '\0';
-					break;
+			if (line[0] == '"') {
+				line ++;
+				j = strcspn(line, "\"");
+				line[j] = 0;
+			} else if (line[0] == '\'') {
+				line ++;
+				j = strcspn(line, "'");
+				line[j] = 0;
+			} else
+				/* Skip trailing spaces and comments */
+				for (j = 0; val[j]; j++) {
+					if (val[j] == '#' || val[j] == ';' || isspace(val[j])) {
+						val[j] = '\0';
+						break;
+					}
 				}
-			}
 			if (strcasecmp(line, "include") == 0)
 				conf_load(trans, val);
 			else
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 13459ea85744..8e2f034d0b9b 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -35,6 +35,8 @@ in the current section to
 .BR 4 .
 Leading and trailing spaces and tab
 are ignored, as are spaces and tabs surrounding the equals sign.
+Single and double quotes surrounding the assigned value are also
+removed.
 .PP
 Any line starting with
 .RB \*(lq # \*(rq


