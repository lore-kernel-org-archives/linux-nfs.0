Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510AbcECTQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2016 15:16:06 -0400
Date: Tue, 3 May 2016 15:16:02 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, "Eric W. Biederman" <ebiederm@redhat.com>
Subject: [PATCH] nfs: don't share mounts between network namespaces
Message-ID: <20160503191602.GA17518@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's no guarantee that an IP address in a different network namespace
actually represents the same endpoint.

Also, if we allow unprivileged nfs mounts some day then this might allow
an unprivileged user in another network namespace to misdirect somebody
else's nfs mounts.

If sharing between containers is really what's wanted then that could
still be arranged explicitly, for example with bind mounts.

Reported-by: "Eric W. Biederman" <ebiederm@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/super.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f1268280244e..ff537a205188 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2408,6 +2408,11 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
 {
 	struct sockaddr *sap1, *sap2;
+	struct rpc_xprt *xprt1 = server1->client->cl_xprt;
+	struct rpc_xprt *xprt2 = server2->client->cl_xprt;
+
+	if (!net_eq(xprt1->xprt_net, xprt2->xprt_net))
+		return 0;
 
 	sap1 = (struct sockaddr *)&server1->nfs_client->cl_addr;
 	sap2 = (struct sockaddr *)&server2->nfs_client->cl_addr;
-- 
2.5.5

