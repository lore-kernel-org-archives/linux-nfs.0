Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55573 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab0IMRXG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:23:06 -0400
Received: by mail-iw0-f174.google.com with SMTP id 5so5308245iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:23:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/12] libexport.a: Enable IPv6 support in hostname.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:23:02 -0400
Message-ID: <20100913172302.19017.47401.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If --enable-ipv6 is specified when building nfs-utils, libexport's
host_foo() helpers can now return both IPv4 and IPv6 addresses.

This means IPv6 presentation addresses and IPv6 DNS resolution
results are handled properly in the mountd cache and /etc/exports,
but does not yet enable IPv6 mountd listeners.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/hostname.c |   31 +++++++++++++++----------------
 1 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 232e040..3c55ce7 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -34,16 +34,6 @@
 #define AI_ADDRCONFIG	0
 #endif
 
-#ifdef HAVE_GETNAMEINFO
-static socklen_t
-sockaddr_size(const struct sockaddr *sap)
-{
-	if (sap->sa_family != AF_INET)
-		return 0;
-	return (socklen_t)sizeof(struct sockaddr_in);
-}
-#endif	/* HAVE_GETNAMEINFO */
-
 /**
  * host_ntop - generate presentation address given a sockaddr
  * @sap: pointer to socket address
@@ -56,7 +46,7 @@ sockaddr_size(const struct sockaddr *sap)
 char *
 host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
 {
-	socklen_t salen = sockaddr_size(sap);
+	socklen_t salen = nfs_sockaddr_length(sap);
 	int error;
 
 	memset(buf, 0, buflen);
@@ -117,7 +107,7 @@ host_pton(const char *paddr)
 		.ai_family	= AF_UNSPEC,
 	};
 	struct sockaddr_in sin;
-	int error;
+	int error, inet4;
 
 	/*
 	 * Although getaddrinfo(3) is easier to use and supports
@@ -129,12 +119,17 @@ host_pton(const char *paddr)
 	 * have a real AF_INET presentation address, before invoking
 	 * getaddrinfo(3) to generate the full addrinfo list.
 	 */
+	inet4 = 1;
 	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0)
-		return NULL;
+		inet4 = 0;
 
 	error = getaddrinfo(paddr, NULL, &hint, &ai);
 	switch (error) {
 	case 0:
+		if (!inet4 && ai->ai_addr->sa_family == AF_INET) {
+			freeaddrinfo(ai);
+			break;
+		}
 		return ai;
 	case EAI_NONAME:
 		if (paddr == NULL)
@@ -168,7 +163,11 @@ host_addrinfo(const char *hostname)
 {
 	struct addrinfo *ai = NULL;
 	struct addrinfo hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+#else
 		.ai_family	= AF_INET,
+#endif
 		/* don't return duplicates */
 		.ai_protocol	= (int)IPPROTO_UDP,
 		.ai_flags	= AI_ADDRCONFIG | AI_CANONNAME,
@@ -208,7 +207,7 @@ __attribute_malloc__
 char *
 host_canonname(const struct sockaddr *sap)
 {
-	socklen_t salen = sockaddr_size(sap);
+	socklen_t salen = nfs_sockaddr_length(sap);
 	char buf[NI_MAXHOST];
 	int error;
 
@@ -298,8 +297,8 @@ __attribute_malloc__
 struct addrinfo *
 host_numeric_addrinfo(const struct sockaddr *sap)
 {
-	socklen_t salen = sockaddr_size(sap);
-	char buf[INET_ADDRSTRLEN];
+	socklen_t salen = nfs_sockaddr_length(sap);
+	char buf[INET6_ADDRSTRLEN];
 	struct addrinfo *ai;
 	int error;
 

