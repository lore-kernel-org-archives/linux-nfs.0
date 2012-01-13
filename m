Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:39190 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755323Ab2AMJJe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 04:09:34 -0500
Subject: [PATCH v2 2/4] SUNRPC: parametrize rpc_pton6() by network context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 13:09:11 +0400
Message-ID: <20120113090911.1598.7934.stgit@localhost6.localdomain6>
In-Reply-To: <20120113090520.1598.73772.stgit@localhost6.localdomain6>
References: <20120113090520.1598.73772.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Parametrize rpc_pton6() by network context and thus force it's caller
to pass in network context instead of using hard-coded "init_net".

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/addr.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index cc83de1..18c40a2 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -198,7 +198,7 @@ static int rpc_parse_scope_id(struct net *net, const char *buf,
 	return 0;
 }
 
-static size_t rpc_pton6(const char *buf, const size_t buflen,
+static size_t rpc_pton6(struct net *net, const char *buf, const size_t buflen,
 			struct sockaddr *sap, const size_t salen)
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
@@ -214,14 +214,14 @@ static size_t rpc_pton6(const char *buf, const size_t buflen,
 	if (in6_pton(buf, buflen, addr, IPV6_SCOPE_DELIMITER, &delim) == 0)
 		return 0;
 
-	if (!rpc_parse_scope_id(&init_net, buf, buflen, delim, sin6))
+	if (!rpc_parse_scope_id(net, buf, buflen, delim, sin6))
 		return 0;
 
 	sin6->sin6_family = AF_INET6;
 	return sizeof(struct sockaddr_in6);
 }
 #else
-static size_t rpc_pton6(const char *buf, const size_t buflen,
+static size_t rpc_pton6(struct net *net, const char *buf, const size_t buflen,
 			struct sockaddr *sap, const size_t salen)
 {
 	return 0;
@@ -249,7 +249,7 @@ size_t rpc_pton(const char *buf, const size_t buflen,
 
 	for (i = 0; i < buflen; i++)
 		if (buf[i] == ':')
-			return rpc_pton6(buf, buflen, sap, salen);
+			return rpc_pton6(&init_net, buf, buflen, sap, salen);
 	return rpc_pton4(buf, buflen, sap, salen);
 }
 EXPORT_SYMBOL_GPL(rpc_pton);

