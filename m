Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4164 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2EYWDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 18:03:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFSv4.1: Exchange ID must use GFP_NOFS allocation mode
Date: Fri, 25 May 2012 18:03:15 -0400
Message-Id: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Exchange ID can be called in a lease reclaim situation, so it
will deadlock if it then tries to write out dirty NFS pages.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e8988c0..f8817e8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5192,20 +5192,20 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
 	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
-					GFP_KERNEL);
+					GFP_NOFS);
 	if (unlikely(res.server_owner == NULL)) {
 		status = -ENOMEM;
 		goto out;
 	}
 
 	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
-					GFP_KERNEL);
+					GFP_NOFS);
 	if (unlikely(res.server_scope == NULL)) {
 		status = -ENOMEM;
 		goto out_server_owner;
 	}
 
-	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_KERNEL);
+	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_NOFS);
 	if (unlikely(res.impl_id == NULL)) {
 		status = -ENOMEM;
 		goto out_server_scope;
-- 
1.7.7.6

