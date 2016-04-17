Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:57720 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbcDQJKy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:10:54 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 031CB20AA8
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:10:52 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:10:13 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] clnt_bcast: Remove dependency on <sys/queue.h>
Message-ID: <20160417091013.GB2737@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlike glibc, musl libc does not ship with the <sys/queue.h> header
and suggests for distros or upstream projects to supply the header.

<sys/queue.h> is used only in clnt_bcast.c and only very few TAILQ_*
macros are used there. Therefore, just expand these macros, simplify
the structure names (e.g. tqh_first -> first) and inline struct link
in struct broadif.

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/clnt_bcast.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/src/clnt_bcast.c b/src/clnt_bcast.c
index 98cf061..cb6510e 100644
--- a/src/clnt_bcast.c
+++ b/src/clnt_bcast.c
@@ -40,8 +40,6 @@
  */
 #include <sys/socket.h>
 #include <sys/types.h>
-#include <sys/queue.h>
-
 #include <net/if.h>
 #include <netinet/in.h>
 #include <ifaddrs.h>
@@ -97,18 +95,17 @@
  * also here it will get two responses ... inefficient and clumsy.
  */
 
-#define	TAILQ_NEXT(elm, field)	((elm)->field.tqe_next)
-
-#define	TAILQ_FIRST(head)	((head)->tqh_first)
-
-
 struct broadif {
 	int index;
 	struct sockaddr_storage broadaddr;
-	TAILQ_ENTRY(broadif) link;
+	struct broadif *next;
+	struct broadif **prev;
 };
 
-typedef TAILQ_HEAD(, broadif) broadlist_t;
+typedef struct {
+	struct broadif *first;
+	struct broadif **last;
+} broadlist_t;
 
 int __rpc_getbroadifs(int, int, int, broadlist_t *);
 void __rpc_freebroadifs(broadlist_t *);
@@ -179,7 +176,10 @@ __rpc_getbroadifs(int af, int proto, int socktype, broadlist_t *list)
 			free(bip);
 			continue;
 		}
-		TAILQ_INSERT_TAIL(list, bip, link);
+		bip->next = NULL;
+		bip->prev = list->last;
+		*list->last = bip;
+		list->last = &bip->next;
 		count++;
 	}
 	freeifaddrs(ifp);
@@ -193,10 +193,10 @@ __rpc_freebroadifs(broadlist_t *list)
 {
 	struct broadif *bip, *next;
 
-	bip = TAILQ_FIRST(list);
+	bip = list->first;
 
 	while (bip != NULL) {
-		next = TAILQ_NEXT(bip, link);
+		next = bip->next;
 		free(bip);
 		bip = next;
 	}
@@ -343,7 +343,8 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 		if (!__rpc_nconf2sockinfo(nconf, &si))
 			continue;
 
-		TAILQ_INIT(&fdlist[fdlistno].nal);
+		fdlist[fdlistno].nal.first = NULL;
+		fdlist[fdlistno].nal.last = &fdlist[fdlistno].nal.first;
 		if (__rpc_getbroadifs(si.si_af, si.si_proto, si.si_socktype, 
 		    &fdlist[fdlistno].nal) == 0)
 			continue;
@@ -468,8 +469,8 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 				stat = RPC_CANTSEND;
 				continue;
 			}
-			for (bip = TAILQ_FIRST(&fdlist[i].nal); bip != NULL;
-			     bip = TAILQ_NEXT(bip, link)) {
+			for (bip = fdlist[i].nal.first; bip != NULL;
+			     bip = bip->next) {
 				void *addr;
 
 				addr = &bip->broadaddr;
-- 
2.7.3

