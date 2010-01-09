From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/sunrpc/addr.c: Remove unnecessary semicolons
Date: Fri, 08 Jan 2010 22:36:23 -0800
Message-ID: <1263018983.20926.9.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1027 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896Ab0AIGgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Jan 2010 01:36:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 6dcdd25..2ef893e 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -149,7 +149,7 @@ static size_t rpc_pton4(const char *buf, const size_t buflen,
 		return 0;
 
 	sin->sin_family = AF_INET;
-	return sizeof(struct sockaddr_in);;
+	return sizeof(struct sockaddr_in);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)


