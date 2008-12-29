From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NLM: Remove AF_UNSPEC arm in nlm_display_address()
Date: Mon, 29 Dec 2008 17:20:16 -0500
Message-ID: <20081229222015.28005.48684.stgit@ingres.1015granger.net>
References: <20081229221603.28005.42498.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54764 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbYL2WVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Dec 2008 17:21:24 -0500
In-Reply-To: <20081229221603.28005.42498.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AF_UNSPEC support is no longer needed in nlm_display_address() now
that a presentation address is no longer generated for the h_srcaddr
field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 33bf67a..beb5da8 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -112,9 +112,6 @@ static void nlm_display_address(const struct sockaddr *sap,
 	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
 	switch (sap->sa_family) {
-	case AF_UNSPEC:
-		snprintf(buf, len, "unspecified");
-		break;
 	case AF_INET:
 		snprintf(buf, len, "%pI4", &sin->sin_addr.s_addr);
 		break;

