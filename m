From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] libexport.a: Refactor rmtab_read()
Date: Fri, 07 May 2010 13:45:29 -0400
Message-ID: <20100507174529.4221.80221.stgit@localhost.localdomain>
References: <20100507174128.4221.36914.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:44423 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756347Ab0EGRpd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 May 2010 13:45:33 -0400
Received: by mail-qy0-f183.google.com with SMTP id 13so1957785qyk.1
        for <linux-nfs@vger.kernel.org>; Fri, 07 May 2010 10:45:33 -0700 (PDT)
In-Reply-To: <20100507174128.4221.36914.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Make it easier to add IPv6 support by refactoring part of
rmtab_read() into a helper function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/rmtab.c |   64 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/support/export/rmtab.c b/support/export/rmtab.c
index b49e1aa..0ec495c 100644
--- a/support/export/rmtab.c
+++ b/support/export/rmtab.c
@@ -19,39 +19,57 @@
 #include "xio.h"
 #include "xlog.h"
 
+/*
+ * See if the entry already exists.  If not,
+ * this was an instantiated wild card, and we
+ * must add it.
+ */
+static void
+rmtab_read_wildcard(struct rmtabent *rep)
+{
+	nfs_export *exp, *exp2;
+	struct hostent *hp;
+
+	hp = gethostbyname(rep->r_client);
+	if (hp == NULL)
+		return;
+	hp = hostent_dup(hp);
+	if (hp == NULL)
+		return;
+
+	exp = export_allowed(hp, rep->r_path);
+	free(hp);
+	if (exp == NULL)
+		return;
+
+	exp2 = export_lookup(rep->r_client, exp->m_export.e_path, 0);
+	if (exp2 == NULL) {
+		struct exportent ee;
+
+		memset(&ee, 0, sizeof(ee));
+		dupexportent(&ee, &exp->m_export);
+
+		ee.e_hostname = rep->r_client;
+		exp2 = export_create(&ee, 0);
+		exp2->m_changed = exp->m_changed;
+	}
+	exp2->m_mayexport = 1;
+}
+
 int
 rmtab_read(void)
 {
 	struct rmtabent		*rep;
-	nfs_export		*exp = NULL;
 
 	setrmtabent("r");
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
-		struct hostent		*hp = NULL;
 		int			htype;
-		
+
 		htype = client_gettype(rep->r_client);
-		if ((htype == MCL_FQDN || htype == MCL_SUBNETWORK)
-		    && (hp = gethostbyname (rep->r_client))
-		    && (hp = hostent_dup (hp),
-			exp = export_allowed (hp, rep->r_path))) {
-			/* see if the entry already exists, otherwise this was an instantiated
-			 * wild card, and we must add it
-			 */
-			nfs_export *exp2 = export_lookup(rep->r_client,
-							exp->m_export.e_path, 0);
-			if (!exp2) {
-				struct exportent ee;
-				dupexportent(&ee, &exp->m_export);
-				ee.e_hostname = rep->r_client;
-				exp2 = export_create(&ee, 0);
-				exp2->m_changed = exp->m_changed;
-			}
-			free (hp);
-			exp2->m_mayexport = 1;
-		} else if (hp) /* export_allowed failed */
-			free(hp);
+		if (htype == MCL_FQDN || htype == MCL_SUBNETWORK)
+			rmtab_read_wildcard(rep);
 	}
+
 	if (errno == EINVAL) {
 		/* Something goes wrong. We need to fix the rmtab
 		   file. */

