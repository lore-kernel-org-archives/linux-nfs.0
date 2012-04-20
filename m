Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757419Ab2DTSsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:07 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 02/25] NFS: put open context on error in nfs_pagein_multi
Date: Fri, 20 Apr 2012 14:47:34 -0400
Message-Id: <1334947677-28864-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: <stable@vger.kernel.org>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/read.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 9a0e8ef..0a4be28 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -322,7 +322,7 @@ out_bad:
 	while (!list_empty(res)) {
 		data = list_entry(res->next, struct nfs_read_data, list);
 		list_del(&data->list);
-		nfs_readdata_free(data);
+		nfs_readdata_release(data);
 	}
 	nfs_readpage_release(req);
 	return -ENOMEM;
-- 
1.7.2.1

