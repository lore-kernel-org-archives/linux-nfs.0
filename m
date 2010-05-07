From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] mountd: Convert colons in IPv6 presentation addresses to
	semicolons
Date: Fri, 07 May 2010 13:45:40 -0400
Message-ID: <20100507174540.4221.46279.stgit@localhost.localdomain>
References: <20100507174128.4221.36914.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:44423 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756347Ab0EGRpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 May 2010 13:45:44 -0400
Received: by mail-qy0-f183.google.com with SMTP id 13so1957785qyk.1
        for <linux-nfs@vger.kernel.org>; Fri, 07 May 2010 10:45:44 -0700 (PDT)
In-Reply-To: <20100507174128.4221.36914.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The /var/lib/nfs/rmtab file delineates fields in each of its lines
with a ":".  The first field contains the IP address of a client, in
presentation format.  IPv6 presentation format addresses contain
colons, which screws up the field delineation of rmtab.

Use a simple simple scheme to convert the colons in incoming client
names to some other character, and then convert them back when the
rmtab file is read.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rmtab.c |   42 +++++++++++++++++++++++++++++++++++++++---
 1 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/support/nfs/rmtab.c b/support/nfs/rmtab.c
index a28abf3..ca789a3 100644
--- a/support/nfs/rmtab.c
+++ b/support/nfs/rmtab.c
@@ -19,6 +19,18 @@
 #include <signal.h>
 #include "nfslib.h"
 
+/*
+ * Colons in incoming IPv6 presentation addresses have to
+ * replaced with another character, since rmtab already
+ * uses colons to delineate fields.
+ *
+ * Use a printable character, but one that would never be
+ * found in a presentation address or domain name
+ */
+#define IPV6_COLON	';'
+
+#define LINELEN		(2048)
+
 static FILE	*rmfp = NULL;
 
 int
@@ -56,7 +68,8 @@ struct rmtabent *
 fgetrmtabent(FILE *fp, int log, long *pos)
 {
 	static struct rmtabent	re;
-	char	buf[2048], *count, *host, *path;
+	char		*count, *host, *path, *c;
+	static char	buf[LINELEN];
 
 	errno = 0;
 	if (!fp)
@@ -84,10 +97,16 @@ fgetrmtabent(FILE *fp, int log, long *pos)
 		else
 			re.r_count = 1;
 	} while (0);
+
 	strncpy(re.r_client, host, sizeof (re.r_client) - 1);
 	re.r_client[sizeof (re.r_client) - 1] = '\0';
+	for (c = re.r_client; *c != '\0'; c++)
+		if (*c == IPV6_COLON)
+			*c = ':';
+
 	strncpy(re.r_path, path, sizeof (re.r_path) - 1);
 	re.r_path[sizeof (re.r_path) - 1] = '\0';
+
 	return &re;
 }
 
@@ -100,10 +119,27 @@ putrmtabent(struct rmtabent *rep, long *pos)
 void
 fputrmtabent(FILE *fp, struct rmtabent *rep, long *pos)
 {
+	static char	buf[LINELEN];
+	char		*c;
+
 	if (!fp || (pos && fseek (fp, *pos, SEEK_SET) != 0))
 		return;
-	fprintf(fp, "%s:%s:0x%.8x\n", rep->r_client, rep->r_path,
-		rep->r_count);
+
+	/*
+	 * To avoid confusing the token parser in fgetrmtabent(),
+	 * convert colons in incoming IPv6 presentation addresses
+	 * to semicolons.
+	 */
+	if (strlen(rep->r_client) > sizeof(buf)) {
+		xlog(L_ERROR, "client name too large");
+		return;
+	}
+	strncpy(buf, rep->r_client, sizeof(buf));
+	for (c = buf; *c != '\0'; c++)
+		if (*c == ':')
+			*c = IPV6_COLON;
+
+	(void)fprintf(fp, "%s:%s:0x%.8x\n", buf, rep->r_path, rep->r_count);
 }
 
 void

