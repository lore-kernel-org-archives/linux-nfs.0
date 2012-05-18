Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:62275 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968128Ab2ERWF0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 18:05:26 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so3328926ggl.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 15:05:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/14] NFS: Fix comment misspelling in struct nfs_client
 definition
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 May 2012 18:05:24 -0400
Message-ID: <20120518220524.774.42408.stgit@degas.1015granger.net>
In-Reply-To: <20120518220145.774.53741.stgit@degas.1015granger.net>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
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

