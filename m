Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4547 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757123Ab2AMJJ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 04:09:28 -0500
Subject: [PATCH v2 1/4] SUNRPC: parametrize rpc_parse_scope_id() by network
 context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 13:09:03 +0400
Message-ID: <20120113090903.1598.30645.stgit@localhost6.localdomain6>
In-Reply-To: <20120113090520.1598.73772.stgit@localhost6.localdomain6>
References: <20120113090520.1598.73772.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Parametrize rpc_parse_scope_id() by network context and thus force it's caller
to pass in network context instead of using hard-coded "init_net".

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/addr.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index ee77742..cc83de1 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -156,8 +156,9 @@ static size_t rpc_pton4(const char *buf, const size_t buflen,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static int rpc_parse_scope_id(const char *buf, const size_t buflen,
-			      const char *delim, struct sockaddr_in6 *sin6)
+static int rpc_parse_scope_id(struct net *net, const char *buf,
+			      const size_t buflen, const char *delim,
+			      struct sockaddr_in6 *sin6)
 {
 	char *p;
 	size_t len;
@@ -177,7 +178,7 @@ static int rpc_parse_scope_id(const char *buf, const size_t buflen,
 		unsigned long scope_id = 0;
 		struct net_device *dev;
 
-		dev = dev_get_by_name(&init_net, p);
+		dev = dev_get_by_name(net, p);
 		if (dev != NULL) {
 			scope_id = dev->ifindex;
 			dev_put(dev);
@@ -213,7 +214,7 @@ static size_t rpc_pton6(const char *buf, const size_t buflen,
 	if (in6_pton(buf, buflen, addr, IPV6_SCOPE_DELIMITER, &delim) == 0)
 		return 0;
 
-	if (!rpc_parse_scope_id(buf, buflen, delim, sin6))
+	if (!rpc_parse_scope_id(&init_net, buf, buflen, delim, sin6))
 		return 0;
 
 	sin6->sin6_family = AF_INET6;

