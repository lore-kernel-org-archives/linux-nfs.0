From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/24] sm-notify: Support IPv6 DNS lookups in smn_lookup
Date: Thu, 14 Jan 2010 12:30:01 -0500
Message-ID: <20100114173001.26079.50833.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:43273 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757387Ab0ANRbI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:08 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When IPV6_SUPPORTED is enabled and the local system has IPv6 support,
request AF_INET6 and AF_INET addresses from the DNS resolver.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 259db09..8d90d1f 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -33,6 +33,10 @@
 #include "nsm.h"
 #include "nfsrpc.h"
 
+#ifndef HAVE_DECL_AI_ADDRCONFIG
+#define AI_ADDRCONFIG	0
+#endif
+
 #define NSM_TIMEOUT	2
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
 
@@ -65,19 +69,20 @@ static int		record_pid(void);
 
 static struct nsm_host *	hosts = NULL;
 
-static struct addrinfo *smn_lookup(const char *name)
+__attribute_malloc__
+static struct addrinfo *
+smn_lookup(const char *name)
 {
-	struct addrinfo	*ai, hint = {
-#if HAVE_DECL_AI_ADDRCONFIG
+	struct addrinfo	*ai = NULL;
+	struct addrinfo hint = {
 		.ai_flags	= AI_ADDRCONFIG,
-#endif	/* HAVE_DECL_AI_ADDRCONFIG */
-		.ai_family	= AF_INET,
-		.ai_protocol	= IPPROTO_UDP,
+		.ai_family	= (nsm_family == AF_INET ? AF_INET: AF_UNSPEC),
+		.ai_protocol	= (int)IPPROTO_UDP,
 	};
 	int error;
 
 	error = getaddrinfo(name, NULL, &hint, &ai);
-	if (error) {
+	if (error != 0) {
 		xlog(D_GENERAL, "getaddrinfo(3): %s", gai_strerror(error));
 		return NULL;
 	}

