Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f51.google.com ([209.85.213.51]:33526 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab3FGTwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 15:52:12 -0400
Received: by mail-yh0-f51.google.com with SMTP id l109so1112615yhq.10
        for <linux-nfs@vger.kernel.org>; Fri, 07 Jun 2013 12:52:11 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id f30sm310508yhi.21.2013.06.07.12.45.02
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 12:45:02 -0700 (PDT)
Subject: [PATCH 2/3] NFS: Partially revert commit 845cbceb
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 07 Jun 2013 15:45:00 -0400
Message-ID: <20130607194500.1296.15925.stgit@seurat.1015granger.net>
In-Reply-To: <20130607194140.1296.54746.stgit@seurat.1015granger.net>
References: <20130607194140.1296.54746.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm about to add logic that invokes nfs4_clear_machine_cred(), but
we removed it in 3.10.  This is a separate commit to make it easier
to backport the next patch to a kernel that may still have
nfs4_clear_machine_cred().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1fab140..4949ce5 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -154,6 +154,18 @@ struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 	return cred;
 }
 
+static void nfs4_clear_machine_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+
+	spin_lock(&clp->cl_lock);
+	cred = clp->cl_machine_cred;
+	clp->cl_machine_cred = NULL;
+	spin_unlock(&clp->cl_lock);
+	if (cred != NULL)
+		put_rpccred(cred);
+}
+
 static struct rpc_cred *
 nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 {

