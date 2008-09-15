From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
Date: Mon, 15 Sep 2008 16:27:30 -0500
Message-ID: <20080915212730.3939.35770.stgit@ellison.1015granger.net>
References: <20080915212437.3939.82594.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: okir@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:50649 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbYIOV2J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2008 17:28:09 -0400
In-Reply-To: <20080915212437.3939.82594.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: When doing an RPCB_SET, make the kernel's rpcb client use the
shorthand "::" for the universal form of the IPv6 ANY address.

Without this patch, rpcbind will advertise:

  0000:0000:0000:0000:0000:0000:0000:0000.x.y

This is cosmetic only.  It cleans up the display of information from
/sbin/rpcinfo.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index cc7250d..02164d4 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -20,6 +20,7 @@
 #include <linux/in6.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <net/ipv6.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
@@ -304,10 +305,13 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
 	char buf[64];
 
 	/* Construct AF_INET6 universal address */
-	snprintf(buf, sizeof(buf),
-			NIP6_FMT".%u.%u",
-			NIP6(address_to_register->sin6_addr),
-			port >> 8, port & 0xff);
+ 	if (ipv6_addr_any(&address_to_register->sin6_addr))
+		snprintf(buf, sizeof(buf), "::.%u.%u",
+				port >> 8, port & 0xff);
+	else
+		snprintf(buf, sizeof(buf), NIP6_FMT".%u.%u",
+				NIP6(address_to_register->sin6_addr),
+				port >> 8, port & 0xff);
 	map->r_addr = buf;
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "

