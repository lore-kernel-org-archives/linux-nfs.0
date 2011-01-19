Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59142 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207Ab1ASA5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 19:57:44 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] NFS construct consistent co_ownerid for v4.1
Date: Tue, 18 Jan 2011 19:53:53 -0500
Message-Id: <1295398433-2759-4-git-send-email-andros@netapp.com>
In-Reply-To: <1295398433-2759-3-git-send-email-andros@netapp.com>
References: <1295398433-2759-1-git-send-email-andros@netapp.com>
 <1295398433-2759-2-git-send-email-andros@netapp.com>
 <1295398433-2759-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

As stated in section 2.4 of RFC 5661, subsequent instances of the client need
to present the same co_ownerid. Concatenate the clients IP dot address and
host name to form the co_ownerid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   29 +++++++++--------------------
 1 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9d992b0..33fc801 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -50,6 +50,7 @@
 #include <linux/module.h>
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/xattr.h>
+#include <linux/utsname.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -4572,27 +4573,15 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 	args.verifier = &verifier;
 
-	while (1) {
-		args.id_len = scnprintf(args.id, sizeof(args.id),
-					"%s/%s %u",
-					clp->cl_ipaddr,
-					rpc_peeraddr2str(clp->cl_rpcclient,
-							 RPC_DISPLAY_ADDR),
-					clp->cl_id_uniquifier);
-
-		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
-
-		if (status != -NFS4ERR_CLID_INUSE)
-			break;
-
-		if (signalled())
-			break;
-
-		if (++clp->cl_id_uniquifier == 0)
-			break;
-	}
+	args.id_len = scnprintf(args.id, sizeof(args.id),
+				"%s/%s.%s",
+				clp->cl_ipaddr,
+				init_utsname()->nodename,
+				init_utsname()->domainname);
 
-	status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+	if (!status)
+		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
-- 
1.6.6

