Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34371 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbbGAD7M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:59:12 -0400
Received: by pabvl15 with SMTP id vl15so15937441pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:59:11 -0700 (PDT)
Message-ID: <55936588.6090400@gmail.com>
Date: Wed, 01 Jul 2015 11:59:04 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 6/8] nfs: Drop bad comment in nfs41_walk_client_list()
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 7b1f1fd184 "NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list"
have change the logical of the list_for_each_entry().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4client.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e42be52..3aa6a9b 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -676,7 +676,6 @@ found:
 		break;
 	}
 
-	/* No matching nfs_client found. */
 	spin_unlock(&nn->nfs_client_lock);
 	dprintk("NFS: <-- %s status = %d\n", __func__, status);
 	nfs_put_client(prev);
-- 
2.4.3

