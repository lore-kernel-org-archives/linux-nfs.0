Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:25988 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930AbcHOSww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2016 14:52:52 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 10/12] NFS add xprt switch addrs test to match client
Date: Mon, 15 Aug 2016 14:50:46 -0400
Message-ID: <1471287048-27007-11-git-send-email-andros@netapp.com>
In-Reply-To: <1471287048-27007-1-git-send-email-andros@netapp.com>
References: <1471287048-27007-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4849d0f..0958a6a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -313,7 +313,10 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 		/* Match the full socket address */
 		if (!rpc_cmp_addr_port(sap, clap))
-			continue;
+			/* Match all xprt_switch full socket addresses */
+			if (!rpc_clnt_xprt_switch_has_addr(clp->cl_rpcclient,
+							   sap))
+				continue;
 
 		atomic_inc(&clp->cl_count);
 		return clp;
-- 
1.8.3.1

