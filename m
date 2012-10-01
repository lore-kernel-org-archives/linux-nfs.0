Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40739 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407Ab2JAXtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 19:49:05 -0400
From: Jorge Mora <mora@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Jorge Mora <mora@netapp.com>
Subject: [PATCH] NFS: Fix compile error
Date: Mon,  1 Oct 2012 16:49:01 -0700
Message-Id: <1349135341-30170-1-git-send-email-mora@cyclsvl26.eng.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jorge Mora <mora@netapp.com>


Signed-off-by: Jorge Mora <mora@netapp.com>
---
Fixes bug on Trond's testing branch
 fs/nfs/nfs4state.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5c42866..2602290 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -123,10 +123,11 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 	};
 	unsigned short port;
 	int status;
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 
-	port = nfs_callback_tcpport;
+	port = nn->nfs_callback_tcpport;
 	if (clp->cl_addr.ss_family == AF_INET6)
-		port = nfs_callback_tcpport6;
+		port = nn->nfs_callback_tcpport6;
 
 	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
 	if (status != 0)
-- 
1.7.3.1

