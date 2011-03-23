Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755641Ab1CWMak (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 08:30:40 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/11] NFSv4.1 remove temp code that prevented ds commits
Date: Wed, 23 Mar 2011 08:30:12 -0400
Message-Id: <1300883412-32296-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
References: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Now that all the infrastructure is in place, we will do the
right thing if we remove this special casing.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fc1a0e9..ffb54a0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -385,10 +385,6 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 		data->inode->i_ino, sync, (size_t) data->args.count, offset,
 		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
 
-	/* We can't handle commit to ds yet */
-	if (!FILELAYOUT_LSEG(lseg)->commit_through_mds)
-		data->args.stable = NFS_FILE_SYNC;
-
 	data->write_done_cb = filelayout_write_done_cb;
 	data->ds_clp = ds->ds_clp;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
-- 
1.7.2.1

