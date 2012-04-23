Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab2DWUyC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:54:02 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:54:02 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/20] NFS: Remove nfs_unique_id
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:54:00 -0400
Message-ID: <20120423205400.11446.36865.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  this structure is unused.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c294c41..c87e846 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -52,11 +52,6 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
 };
 
-struct nfs_unique_id {
-	struct rb_node rb_node;
-	__u64 id;
-};
-
 #define NFS_SEQID_CONFIRMED 1
 struct nfs_seqid_counter {
 	int owner_id;

