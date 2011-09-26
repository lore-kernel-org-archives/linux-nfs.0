Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:60616 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1IZP35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 11:29:57 -0400
Received: by ywb5 with SMTP id 5so4377130ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 08:29:57 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFS: Fix documenting comment for nfs_create_request()
To: linux-nfs@vger.kernel.org
Cc: bjschuma@netapp.com, andros@netapp.com
Date: Mon, 26 Sep 2011 11:29:55 -0400
Message-ID: <20110926152955.8595.18319.stgit@degas.1015granger.net>
In-Reply-To: <20110926152657.8595.6375.stgit@degas.1015granger.net>
References: <20110926152657.8595.6375.stgit@degas.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

