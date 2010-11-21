Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713Ab0KUTVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFS: Fix a page leak in uncached_readdir()
Date: Sun, 21 Nov 2010 14:21:18 -0500
Message-Id: <1290367282-5445-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290367282-5445-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 42e66e9..353f47c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -763,13 +763,14 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		goto out;
 	}
 
+	desc->page_index = 0;
+	desc->page = page;
+
 	if (nfs_readdir_xdr_to_array(desc, page, inode) == -1) {
 		status = -EIO;
 		goto out_release;
 	}
 
-	desc->page_index = 0;
-	desc->page = page;
 	status = nfs_do_filldir(desc, dirent, filldir);
 
  out:
-- 
1.7.3.2

