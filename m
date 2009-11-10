From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/29] statd: Support IPv6 DNS lookups in smn_lookup
Date: Tue, 10 Nov 2009 16:58:52 -0500
Message-ID: <20091110215851.23822.53602.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:27852 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758464AbZKJV7J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:59:09 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When IPV6_SUPPORTED is enabled and the local system has IPv6 support,
request AF_INET6 and AF_INET addresses from the DNS resolver.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 9639e92..4fda046 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -32,6 +32,10 @@
 #include "nsm.h"
 #include "nfsrpc.h"
 
+#ifndef HAVE_DECL_AI_ADDRCONFIG
+#define AI_ADDRCONFIG	0
+#endif
+
 #define NSM_PROG	100024
 #define NSM_PROGRAM	100024
 #define NSM_VERSION	1
@@ -73,10 +77,12 @@ static struct nsm_host *	hosts = NULL;
 static struct addrinfo *smn_lookup(const char *name)
 {
 	struct addrinfo	*ai, hint = {
-#if HAVE_DECL_AI_ADDRCONFIG
 		.ai_flags	= AI_ADDRCONFIG,
-#endif	/* HAVE_DECL_AI_ADDRCONFIG */
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+#else	/* !IPV6_SUPPORTED */
 		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
 		.ai_protocol	= IPPROTO_UDP,
 	};
 	int error;

