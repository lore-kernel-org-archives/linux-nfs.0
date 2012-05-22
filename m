Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478Ab2EVIDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 04:03:49 -0400
Subject: [PATCH v3] NFS: put net on idr allocation failure
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 22 May 2012 12:03:45 +0400
Message-ID: <20120522080307.21303.60025.stgit@localhost.localdomain>
In-Reply-To: <20120522073709.20602.33027.stgit@localhost.localdomain>
References: <20120522073709.20602.33027.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/client.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 44cd70f..ae29d4f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -176,8 +176,10 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 #ifdef CONFIG_NFS_V4
 	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
-	if (err)
+	if (err) {
+		put_net(clp->net);
 		goto error_cleanup;
+	}
 
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);

