From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 07/24] Removed warnings from conffile.c
Date: Tue, 20 Jul 2010 19:37:20 -0400
Message-ID: <1279669057-17509-8-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60383 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761683Ab0GUAnU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:20 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNX-0004K5-3B
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:39 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

conffile.c: In function 'conf_parse_line':
conffile.c:301: warning: comparison between signed and unsigned integer expressions

conffile.c: In function 'conf_load_defaults':
conffile.c:356: warning: unused parameter 'tr'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/conffile.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index b277c2a..24640f4 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -49,7 +49,7 @@
 #include "conffile.h"
 #include "xlog.h"
 
-static void conf_load_defaults (int);
+static void conf_load_defaults(void);
 static int conf_set(int , char *, char *, char *, 
 	char *, int , int );
 
@@ -212,7 +212,7 @@ conf_parse_line(int trans, char *line, size_t sz)
 {
 	char *val, *ptr;
 	size_t i;
-	int j;
+	size_t j;
 	static char *section = 0;
 	static char *arg = 0;
 	static int ln = 0;
@@ -353,7 +353,7 @@ conf_parse(int trans, char *buf, size_t sz)
 }
 
 static void
-conf_load_defaults(int tr)
+conf_load_defaults(void)
 {
 	/* No defaults */
 	return;
@@ -412,7 +412,7 @@ conf_reinit(void)
 		trans = conf_begin();
 
 	/* Load default configuration values.  */
-	conf_load_defaults(trans);
+	conf_load_defaults();
 
 	/* Free potential existing configuration.  */
 	if (conf_addr) {
-- 
1.7.0.1

