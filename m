Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:50146 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab2IUE1m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Sep 2012 00:27:42 -0400
Received: by qaas11 with SMTP id s11so971335qaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2012 21:27:41 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 21 Sep 2012 12:27:41 +0800
Message-ID: <CAPgLHd8trgEhEOedSt5AKtBUhpcZSF2_JWeVPHPMUzT1zTFeUA@mail.gmail.com>
Subject: [PATCH] NFS: fix the return value check by using IS_ERR
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function rpcauth_create() returns ERR_PTR()
and never returns NULL pointer. The NULL test in the return value
check should be replaced with IS_ERR().

dpatch engine is used to auto generated this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfs/nfs4proc.c      | 2 +-
 fs/nfs/nfs4namespace.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e50326..ddfebb1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2399,7 +2399,7 @@ static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandl
 	int ret;
 
 	auth = rpcauth_create(flavor, server->client);
-	if (!auth) {
+	if (IS_ERR(auth)) {
 		ret = -EIO;
 		goto out;
 	}

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 017b4b0..398d5fd 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -205,7 +205,7 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
 		return clone;
 
 	auth = rpcauth_create(flavor, clone);
-	if (!auth) {
+	if (IS_ERR(auth)) {
 		rpc_shutdown_client(clone);
 		clone = ERR_PTR(-EIO);
 	}


