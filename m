Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49978 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753681Ab1ASTTI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 14:19:08 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS: fix handling of malloc failure during nfs_flush_multi()
Date: Wed, 19 Jan 2011 14:18:50 -0500
Message-Id: <1295464730-29568-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Cleanup of the allocated list entries should not call
put_nfs_open_context() on each entry, as the context will
always be NULL, causing an oops.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 10d648e..c8278f4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -932,7 +932,7 @@ out_bad:
 	while (!list_empty(&list)) {
 		data = list_entry(list.next, struct nfs_write_data, pages);
 		list_del(&data->pages);
-		nfs_writedata_release(data);
+		nfs_writedata_free(data);
 	}
 	nfs_redirty_request(req);
 	return -ENOMEM;
-- 
1.7.2.1

