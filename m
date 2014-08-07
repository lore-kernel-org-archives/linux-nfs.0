Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:52350 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420AbaHGCPX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 22:15:23 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so4289074pdj.7
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 19:15:22 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/2] nfs/filelayout: set layoutcommit depending on write verifier
Date: Thu,  7 Aug 2014 10:15:03 +0800
Message-Id: <1407377703-6593-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1407377703-6593-1-git-send-email-tao.peng@primarydata.com>
References: <1407377703-6593-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following http://www.rfc-editor.org/errata_search.php?rfc=5661&eid=2751
Don't set layoutcommit for commit_through_mds case.
For FILE_SYNC writes, don't set layoutcommit.
For DATA_SYNC wirtes, set layout commit right after wirtes done.
For UNSTABLE writes, set layout commit when commit done.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 1359c4a..e8720ec 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -265,7 +265,7 @@ filelayout_set_layoutcommit(struct nfs_pgio_header *hdr)
 {
 
 	if (FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds ||
-	    hdr->res.verf->committed == NFS_FILE_SYNC)
+	    hdr->res.verf->committed != NFS_DATA_SYNC)
 		return;
 
 	pnfs_set_layoutcommit(hdr);
@@ -403,6 +403,9 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
+	if (data->verf.committed == NFS_UNSTABLE)
+		pnfs_commit_set_layoutcommit(data);
+
 	return 0;
 }
 
-- 
1.9.1

