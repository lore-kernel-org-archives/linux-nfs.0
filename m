Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53010 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968091Ab2ERWGJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 18:06:09 -0400
Received: by gglu4 with SMTP id u4so3329530ggl.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 15:06:08 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/14] NFS: Remove nfs_unique_id
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 May 2012 18:06:07 -0400
Message-ID: <20120518220607.774.76316.stgit@degas.1015granger.net>
In-Reply-To: <20120518220145.774.53741.stgit@degas.1015granger.net>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
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
index d05719e..03d3ff0 100644
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

