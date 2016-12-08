Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43999 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932193AbcLHE2W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:28:22 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:25 +1100
Subject: [PATCH 06/10] conffile: fix striping of quotes from values.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124536.31271.10187990246409032535.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There were being stripes from the name instead!

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 57f58a2bcdc7..e717c1e39bab 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -300,14 +300,14 @@ conf_parse_line(int trans, char *line, size_t sz)
 			line[strcspn (line, " \t=")] = '\0';
 			val = line + i + 1 + strspn (line + i + 1, " \t");
 
-			if (line[0] == '"') {
-				line ++;
-				j = strcspn(line, "\"");
-				line[j] = 0;
-			} else if (line[0] == '\'') {
-				line ++;
-				j = strcspn(line, "'");
-				line[j] = 0;
+			if (val[0] == '"') {
+				val ++;
+				j = strcspn(val, "\"");
+				val[j] = 0;
+			} else if (val[0] == '\'') {
+				val ++;
+				j = strcspn(val, "'");
+				val[j] = 0;
 			} else {
 				/* Skip trailing spaces and comments */
 				for (j = 0; val[j]; j++) {


