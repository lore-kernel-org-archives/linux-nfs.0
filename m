Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1267 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932988Ab0KODGD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Nov 2010 22:06:03 -0500
From: Joe Perches <joe@perches.com>
To: Jiri Kosina <trivial@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 42/44] net/sunrpc/addr.c: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:05:01 -0800
Message-Id: <aca92092a705e0d21176b5ac7d3581c4f9140dbc.1289789605.git.joe@perches.com>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/addr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 1419d0c..4195233 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -151,7 +151,7 @@ static size_t rpc_pton4(const char *buf, const size_t buflen,
 		return 0;
 
 	sin->sin_family = AF_INET;
-	return sizeof(struct sockaddr_in);;
+	return sizeof(struct sockaddr_in);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-- 
1.7.3.1.g432b3.dirty

