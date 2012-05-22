Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57358 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082Ab2EVCpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:45:09 -0400
Received: by yhmm54 with SMTP id m54so5053606yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:45:09 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/14] NFS: Remove nfs_unique_id
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:45:08 -0400
Message-ID: <20120522024507.1787.53843.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
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
index b14bcc3..1526fdf 100644
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
 	ktime_t create_time;

