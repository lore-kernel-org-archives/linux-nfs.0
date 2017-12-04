Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:37372 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752524AbdLDTNs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 14:13:48 -0500
Subject: [PATCH v1 3/4] nfs: Update server port after referral or migration
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 Dec 2017 14:13:46 -0500
Message-ID: <20171204191346.18629.677.stgit@manet.1015granger.net>
In-Reply-To: <20171204190904.18629.70341.stgit@manet.1015granger.net>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After traversing a referral or recovering from a migration event,
ensure that the server port reported in /proc/mounts is updated
to the correct port setting for the new submount.

Reported-by: Helen Chao <helen.chao@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4client.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index a3d5592..5bc722e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -852,6 +852,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
 	if (test_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status))
 		set_bit(NFS_CS_TSM_POSSIBLE, &cl_init.init_flags);
+	server->port = rpc_get_port(addr);
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);

