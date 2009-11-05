From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/11] SUNRPC: Display compressed (shorthand) IPv6
	presentation addresses
Date: Thu, 05 Nov 2009 13:22:35 -0500
Message-ID: <20091105182234.2796.35951.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:37605
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758141AbZKESW5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:22:57 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent changes to snprintf() introduced the %pI6c formatter, which can
display an IPv6 address with standard shorthanding.  Using a
shorthanded address can save us a few bytes of memory for each stored
presentation address, or a few bytes on the wire when sending these in
a universal address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/addr.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 22e8fd8..d972ce4 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -55,16 +55,8 @@ static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
 
 	/*
 	 * RFC 4291, Section 2.2.1
-	 *
-	 * To keep the result as short as possible, especially
-	 * since we don't shorthand, we don't want leading zeros
-	 * in each halfword, so avoid %pI6.
 	 */
-	return snprintf(buf, buflen, "%x:%x:%x:%x:%x:%x:%x:%x",
-		ntohs(addr->s6_addr16[0]), ntohs(addr->s6_addr16[1]),
-		ntohs(addr->s6_addr16[2]), ntohs(addr->s6_addr16[3]),
-		ntohs(addr->s6_addr16[4]), ntohs(addr->s6_addr16[5]),
-		ntohs(addr->s6_addr16[6]), ntohs(addr->s6_addr16[7]));
+	return snprintf(buf, buflen, "%pI6c", addr);
 }
 
 static size_t rpc_ntop6(const struct sockaddr *sap,

