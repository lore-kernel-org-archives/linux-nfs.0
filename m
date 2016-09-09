Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:62438 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753592AbcIINYb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:31 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 10/12] NFS add xprt switch addrs test to match client
Date: Fri, 9 Sep 2016 09:22:27 -0400
Message-ID: <1473427349-13265-11-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
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
index ef9e70b..b4a8eb0c 100644
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

