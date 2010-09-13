Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61313 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab0IMRWP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:22:15 -0400
Received: by gwj17 with SMTP id 17so2101212gwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:22:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/12] mountd: Support IPv6 in mountlist_list()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:22:12 -0400
Message-ID: <20100913172211.19017.47360.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Replace inet_aton(3) and gethostbyaddr(3) calls in mountlist_list()
with calls to the new host_foo() DNS helpers.

The new functions will support IPv6 without additional changes, once
IPv6 is enabled in the generic hostname helpers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/rmtab.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index cd6abc8..d339296 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -194,8 +194,6 @@ mountlist_list(void)
 	struct rmtabent		*rep;
 	struct stat		stb;
 	int			lockid;
-	struct in_addr		addr;
-	struct hostent		*he;
 
 	if ((lockid = xflock(_PATH_RMTABLCK, "r")) < 0)
 		return NULL;
@@ -220,11 +218,15 @@ mountlist_list(void)
 				break;
 			}
 
-			if (reverse_resolve &&
-			   inet_aton((const char *) rep->r_client, &addr) &&
-			   (he = gethostbyaddr(&addr, sizeof(addr), AF_INET)))
-				m->ml_hostname = strdup(he->h_name);
-			else
+			if (reverse_resolve) {
+				struct addrinfo *ai;
+				ai = host_pton(rep->r_client);
+				if (ai != NULL) {
+					m->ml_hostname = host_canonname(ai->ai_addr);
+					freeaddrinfo(ai);
+				}
+			}
+			if (m->ml_hostname == NULL)
 				m->ml_hostname = strdup(rep->r_client);
 
 			m->ml_directory = strdup(rep->r_path);

