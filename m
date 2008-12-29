From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NLM: Add helper to handle IPv4 addresses
Date: Mon, 29 Dec 2008 17:20:31 -0500
Message-ID: <20081229222030.28005.61245.stgit@ingres.1015granger.net>
References: <20081229221603.28005.42498.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54724 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbYL2WVS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Dec 2008 17:21:18 -0500
In-Reply-To: <20081229221603.28005.42498.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: introduce a helper function to generate IPv4 addresses using
the same style as the IPv6 helper function we just added.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 012e49a..780918a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -105,6 +105,13 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
+static void nlm_display_ipv4_address(const struct sockaddr *sap, char *buf,
+				     const size_t len)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	snprintf(buf, len, "%pI4", &sin->sin_addr.s_addr);
+}
+
 static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
 				     const size_t len)
 {
@@ -122,11 +129,9 @@ static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
 static void nlm_display_address(const struct sockaddr *sap,
 				char *buf, const size_t len)
 {
-	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-
 	switch (sap->sa_family) {
 	case AF_INET:
-		snprintf(buf, len, "%pI4", &sin->sin_addr.s_addr);
+		nlm_display_ipv4_address(sap, buf, len);
 		break;
 	case AF_INET6:
 		nlm_display_ipv6_address(sap, buf, len);

