From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] sm-notify: Don't orphan addrinfo structs
Date: Tue, 28 Apr 2009 17:36:51 -0400
Message-ID: <20090428213650.16098.67875.stgit@ingres.1015granger.net>
References: <20090428213453.16098.33168.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41205 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756456AbZD1Vio (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 17:38:44 -0400
In-Reply-To: <20090428213453.16098.33168.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sm-notify orphans an addrinfo struct in its address list rotation
logic if only a single result was returned from getaddrinfo(3).

For each host, the first time through notify_host(), we want to
send a PMAP_GETPORT request.  ->ai is NULL, and retries is set to 100,
forcing a DNS lookup and an address rotation.  If only a single
addrinfo struct is returned, the rotation logic causes a NULL to be
planted in ->ai, copied from the ai_next field of the returned result.

This means that the second time through notify_host() (to perform the
actual SM_NOTIFY call) we do a second DNS lookup, since ->ai is NULL.
The result of the first lookup has been orphaned, and extra network
traffic is generated.

This scenario is actually fairly common.  Since we pass

  .ai_protocol = IPPROTO_UDP,

to getaddrinfo(3), for most hosts, which have a single forward and
reverse pointer in the DNS database, we get back a single addrinfo
struct as a result.

To address this problem, only perform the address list rotation if
there is more than one element on the list returned by getaddrinfo(3).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   34 +++++++++++++++++++++-------------
 1 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index f1fc619..78d0a59 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -424,19 +424,27 @@ notify_host(int sock, struct nsm_host *host)
 	 * point.
 	 */
 	if (host->retries >= 4) {
-		struct addrinfo *first = host->ai;
-		struct addrinfo **next = &host->ai;
-
-		/* remove the first entry from the list */
-		host->ai = first->ai_next;
-		first->ai_next = NULL;
-		/* find the end of the list */
-		next = &first->ai_next;
-		while ( *next )
-			next = & (*next)->ai_next;
-		/* put first entry at end */
-		*next = first;
-		memcpy(&host->addr, first->ai_addr, first->ai_addrlen);
+		/* don't rotate if there is only one addrinfo */
+		if (host->ai->ai_next == NULL)
+			memcpy(&host->addr, host->ai->ai_addr,
+						host->ai->ai_addrlen);
+		else {
+			struct addrinfo *first = host->ai;
+			struct addrinfo **next = &host->ai;
+
+			/* remove the first entry from the list */
+			host->ai = first->ai_next;
+			first->ai_next = NULL;
+			/* find the end of the list */
+			next = &first->ai_next;
+			while ( *next )
+				next = & (*next)->ai_next;
+			/* put first entry at end */
+			*next = first;
+			memcpy(&host->addr, first->ai_addr,
+						first->ai_addrlen);
+		}
+
 		smn_set_port((struct sockaddr *)&host->addr, 0);
 		host->retries = 0;
 	}

