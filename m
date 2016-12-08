Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43982 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752887AbcLHE2Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:28:16 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:25 +1100
Subject: [PATCH 05/10] conffile: allow embedded spaces in values.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124518.31271.13171167527354823323.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code that said "Skip trailing spaces" actually skipped everything
after the first space.

Change to to only skip trailing spaces, or comments that start after
a space.

This is useful for lists:
   Foo: a, b, c

The list handling already allows for internal spaces.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index e4f685c558fa..57f58a2bcdc7 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -308,14 +308,18 @@ conf_parse_line(int trans, char *line, size_t sz)
 				line ++;
 				j = strcspn(line, "'");
 				line[j] = 0;
-			} else
+			} else {
 				/* Skip trailing spaces and comments */
 				for (j = 0; val[j]; j++) {
-					if (val[j] == '#' || val[j] == ';' || isspace(val[j])) {
+					if ((val[j] == '#' || val[j] == ';')
+					    && (j == 0 || isspace(val[j-1]))) {
 						val[j] = '\0';
 						break;
 					}
 				}
+				while (j && isspace(val[j-1]))
+					val[--j] = '\0';
+			}
 			if (strcasecmp(line, "include") == 0)
 				conf_load(trans, val);
 			else


