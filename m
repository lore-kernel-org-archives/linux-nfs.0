Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758236Ab2DIUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:52:55 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/26] NFS: put open context on error in nfs_flush_multi
Date: Mon,  9 Apr 2012 16:52:09 -0400
Message-Id: <1334004744-31842-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2ed93b8..76735dd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1018,7 +1018,7 @@ out_bad:
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

