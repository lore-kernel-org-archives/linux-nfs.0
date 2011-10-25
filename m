Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62181 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1JYQRq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 12:17:46 -0400
Received: by ywm3 with SMTP id 3so650637ywm.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 Oct 2011 09:17:46 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFS: Fix documenting comment for nfs_create_request()
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Oct 2011 12:17:43 -0400
Message-ID: <20111025161742.5996.66102.stgit@seurat.1015granger.net>
In-Reply-To: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
References: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: the first parameter of nfs_create_request() has been
incorrectly documented since time immemorial (OK, since before
2.6.12).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/pagelist.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b60970c..0a5ff5c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -41,7 +41,7 @@ nfs_page_free(struct nfs_page *p)
 
 /**
  * nfs_create_request - Create an NFS read/write request.
- * @file: file descriptor to use
+ * @ctx: open context to use
  * @inode: inode to which the request is attached
  * @page: page to write
  * @offset: starting offset within the page for the write

