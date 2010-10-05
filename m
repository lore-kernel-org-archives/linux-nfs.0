Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33133 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354Ab0JEQsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 12:48:08 -0400
Message-ID: <4CAB56C2.3080801@parallels.com>
Date: Tue, 05 Oct 2010 20:48:02 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: Use helper to set v4 mapped addr in ip_map_parse
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/svcauth_unix.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 8b378f9..560677d 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -220,10 +220,9 @@ static int ip_map_parse(struct cache_detail *cd,
 	switch (address.sa.sa_family) {
 	case AF_INET:
 		/* Form a mapped IPv4 address in sin6 */
-		memset(&sin6, 0, sizeof(sin6));
 		sin6.sin6_family = AF_INET6;
-		sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
-		sin6.sin6_addr.s6_addr32[3] = address.s4.sin_addr.s_addr;
+		ipv6_addr_set_v4mapped(address.s4.sin_addr.s_addr,
+				&sin6.sin6_addr);
 		break;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
-- 
1.5.5.6

