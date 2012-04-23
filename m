Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab2DWUxQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:53:16 -0400
Received: by iadi9 with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:53:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/20] NFS: Fix comment misspelling in struct nfs_client
 definition
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:53:13 -0400
Message-ID: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/nfs_fs_sb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7073fc7..5498e9d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -79,7 +79,7 @@ struct nfs_client {
 	u32			cl_seqid;
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
-	struct nfs4_session	*cl_session; 	/* sharred session */
+	struct nfs4_session	*cl_session;	/* shared session */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE

