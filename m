Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59624 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab0IMRWF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:22:05 -0400
Received: by mail-iw0-f174.google.com with SMTP id 5so5307707iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:22:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/12] mountd: Handle memory exhaustion in mountlist_list()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:22:01 -0400
Message-ID: <20100913172201.19017.97408.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm about to replace inet_aton(3)/gethostbyaddr(3) with
host_pton()/host_canonname() in mountlist_list().

Since host_canonname() returns a string allocated with strdup(3)
instead of xstrdup(), mountlist_list() must now deal with memory
exhaustion properly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/rmtab.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index 854d519..cd6abc8 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -16,7 +16,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <netdb.h>
-#include "xmalloc.h"
+
 #include "misc.h"
 #include "exportfs.h"
 #include "xio.h"
@@ -179,9 +179,9 @@ mountlist_freeall(mountlist list)
 	while (list != NULL) {
 		mountlist m = list;
 		list = m->ml_next;
-		xfree(m->ml_hostname);
-		xfree(m->ml_directory);
-		xfree(m);
+		free(m->ml_hostname);
+		free(m->ml_directory);
+		free(m);
 	}
 }
 
@@ -211,16 +211,32 @@ mountlist_list(void)
 
 		setrmtabent("r");
 		while ((rep = getrmtabent(1, NULL)) != NULL) {
-			m = (mountlist) xmalloc(sizeof(*m));
+			m = calloc(1, sizeof(*m));
+			if (m == NULL) {
+				mountlist_freeall(mlist);
+				mlist = NULL;
+				xlog(L_ERROR, "%s: memory allocation failed",
+						__func__);
+				break;
+			}
 
 			if (reverse_resolve &&
 			   inet_aton((const char *) rep->r_client, &addr) &&
 			   (he = gethostbyaddr(&addr, sizeof(addr), AF_INET)))
-				m->ml_hostname = xstrdup(he->h_name);
+				m->ml_hostname = strdup(he->h_name);
 			else
-				m->ml_hostname = xstrdup(rep->r_client);
+				m->ml_hostname = strdup(rep->r_client);
+
+			m->ml_directory = strdup(rep->r_path);
+
+			if (m->ml_hostname == NULL || m->ml_directory == NULL) {
+				mountlist_freeall(mlist);
+				mlist = NULL;
+				xlog(L_ERROR, "%s: memory allocation failed",
+						__func__);
+				break;
+			}
 
- 			m->ml_directory = xstrdup(rep->r_path);
 			m->ml_next = mlist;
 			mlist = m;
 		}

