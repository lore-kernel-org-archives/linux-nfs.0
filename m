Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44256 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755011Ab2D3QN7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 12:13:59 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] NFSv4.1: Use the correct hostname in the client identifier string
Date: Mon, 30 Apr 2012 12:13:48 -0400
Message-Id: <1335802428-8132-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335802428-8132-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335802428-8132-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to use the hostname of the process that created the nfs_client.
That hostname is now stored in the rpc_client->cl_nodename.

Also remove the utsname()->domainname component. There is no reason
to include the NIS/YP domainname in a client identifier string.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75eb883..99650aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5122,10 +5122,9 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	nfs4_construct_boot_verifier(clp, &verifier);
 
 	args.id_len = scnprintf(args.id, sizeof(args.id),
-				"%s/%s.%s/%u",
+				"%s/%s/%u",
 				clp->cl_ipaddr,
-				init_utsname()->nodename,
-				init_utsname()->domainname,
+				clp->cl_rpcclient->cl_nodename,
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
 	res.server_scope = kzalloc(sizeof(struct server_scope), GFP_KERNEL);
-- 
1.7.7.6

