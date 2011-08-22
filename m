Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530Ab1HVVMr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 17:12:47 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/4] NFSv4: nfs4_proc_renew should be declared static
Date: Mon, 22 Aug 2011 17:12:38 -0400
Message-Id: <1314047560-24534-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1314047560-24534-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1314047560-24534-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h  |    2 --
 fs/nfs/nfs4proc.c |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1ec1a85..58adfb6 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -237,8 +237,6 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
-extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 776b41a..b358ec1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3386,7 +3386,7 @@ static const struct rpc_call_ops nfs4_renew_ops = {
 	.rpc_release = nfs4_renew_release,
 };
 
-int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
+static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
@@ -3406,7 +3406,7 @@ int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 			&nfs4_renew_ops, data);
 }
 
-int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
+static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
-- 
1.7.6

