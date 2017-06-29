Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48768 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753284AbdF2Ps3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Jun 2017 11:48:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount: copy the port field into the cloned nfs_server structure.
Date: Thu, 29 Jun 2017 11:48:26 -0400
Message-Id: <20170629154826.25617-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Doing this copy eliminates the "port=0" entry in
the /proc/mounts entries

Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=69241

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/client.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee5ddbd..efebe6c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -820,6 +820,7 @@ void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *sour
 	target->caps = source->caps;
 	target->options = source->options;
 	target->auth_info = source->auth_info;
+	target->port = source->port;
 }
 EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
 
-- 
2.9.4

