Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083Ab2DTSsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:07 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 03/25] NFS: put open context on error in nfs_flush_multi
Date: Fri, 20 Apr 2012 14:47:35 -0400
Message-Id: <1334947677-28864-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: <stable@vger.kernel.org>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9b8d4d4..c074623 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1019,7 +1019,7 @@ out_bad:
 	while (!list_empty(res)) {
 		data = list_entry(res->next, struct nfs_write_data, list);
 		list_del(&data->list);
-		nfs_writedata_free(data);
+		nfs_writedata_release(data);
 	}
 	nfs_redirty_request(req);
 	return -ENOMEM;
-- 
1.7.2.1

