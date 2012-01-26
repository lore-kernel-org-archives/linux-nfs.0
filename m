Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:3691 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716Ab2AZLM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:12:27 -0500
Subject: [PATCH 5/5] NFS: pass transport net to rpc_pton() while parse server
 name
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 26 Jan 2012 15:12:05 +0400
Message-ID: <20120126111205.8386.64056.stgit@localhost6.localdomain6>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/nfs4namespace.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 48a9acd..667ea74 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -97,11 +97,11 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 		struct sockaddr *sa, size_t salen, struct nfs_server *server)
 {
 	ssize_t ret;
+	struct net *net = server->client->cl_xprt->xprt_net;
 
-	ret = rpc_pton(&init_net, string, len, sa, salen);
+	ret = rpc_pton(net, string, len, sa, salen);
 	if (ret == 0) {
-		ret = nfs_dns_resolve_name(server->client->cl_xprt->xprt_net,
-					   string, len, sa, salen);
+		ret = nfs_dns_resolve_name(net, string, len, sa, salen);
 		if (ret < 0)
 			ret = 0;
 	}

