From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] libexport.a: Allow malloc(3) failures in client_lookup()
	and friends
Date: Mon, 19 Apr 2010 16:21:42 -0400
Message-ID: <20100419202141.3567.87262.stgit@matisse.1015granger.net>
References: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64741 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab0DSUVp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 16:21:45 -0400
Received: by mail-vw0-f46.google.com with SMTP id 5so2418494vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2010 13:21:44 -0700 (PDT)
In-Reply-To: <20100419201855.3567.9644.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use malloc(3) instead of xmalloc() in client_lookup() and
client_dup(), ensuring that a failed memory allocation here doesn't
cause our process to exit suddenly.

Allocation of nfs_client records and the m_hostname string are now
consistently handled with malloc(3), calloc(3), strdup(3), and
free(3).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index fc1ade9..3b3a898 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -17,7 +17,7 @@
 #include <string.h>
 #include <ctype.h>
 #include <netdb.h>
-#include "xmalloc.h"
+
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -56,7 +56,7 @@ static void
 client_free(nfs_client *clp)
 {
 	free(clp->m_hostname);
-	xfree(clp);
+	free(clp);
 }
 
 /* if canonical is set, then we *know* this is already a canonical name
@@ -111,9 +111,10 @@ client_lookup(char *hname, int canonical)
 		}
 	}
 
-	if (!clp) {
-		clp = (nfs_client *) xmalloc(sizeof(*clp));
-		memset(clp, 0, sizeof(*clp));
+	if (clp == NULL) {
+		clp = calloc(1, sizeof(*clp));
+		if (clp == NULL)
+			goto out;
 		clp->m_type = htype;
 		if (!client_init(clp, hname, NULL)) {
 			client_free(clp);
@@ -138,7 +139,9 @@ client_dup(nfs_client *clp, struct hostent *hp)
 {
 	nfs_client		*new;
 
-	new = (nfs_client *) xmalloc(sizeof(*new));
+	new = (nfs_client *)malloc(sizeof(*new));
+	if (new == NULL)
+		return NULL;
 	memcpy(new, clp, sizeof(*new));
 	new->m_type = MCL_FQDN;
 	new->m_hostname = NULL;

