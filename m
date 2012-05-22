Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46845 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751Ab2EVHhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 03:37:22 -0400
Subject: [PATCH v2 12/12] NFS: get module in idmap PipeFS notifier callback
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 22 May 2012 11:37:17 +0400
Message-ID: <20120522073717.20602.33269.stgit@localhost.localdomain>
In-Reply-To: <20120522073320.20602.87130.stgit@localhost.localdomain>
References: <20120522073320.20602.87130.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is bug fix.
Notifier callback is called from SUNRPC module. So before dereferencing NFS
module we have to make sure, that it's alive.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/idmap.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c9c3e1b..f55b80a 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -557,12 +557,16 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
 	struct nfs_client *clp;
 	int error = 0;
 
+	if (!try_module_get(THIS_MODULE))
+		return 0;
+
 	while ((clp = nfs_get_client_for_event(sb->s_fs_info, event))) {
 		error = __rpc_pipefs_event(clp, event, sb);
 		nfs_put_client(clp);
 		if (error)
 			break;
 	}
+	module_put(THIS_MODULE);
 	return error;
 }
 

