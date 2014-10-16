Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:62106 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaJPMtp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 08:49:45 -0400
Received: by mail-qa0-f48.google.com with SMTP id dc16so2307728qab.35
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 05:49:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: clean up comments over nfs4_file definition
Date: Thu, 16 Oct 2014 08:49:37 -0400
Message-Id: <1413463777-5195-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They're a bit outdated wrt to some recent changes.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/state.h | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0a47c6a6b301..e3aa37147ea2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -463,15 +463,19 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
 /*
  * nfs4_file: a file opened by some number of (open) nfs4_stateowners.
  *
- * These objects are global. nfsd only keeps one instance of a nfs4_file per
- * inode (though it may keep multiple file descriptors open per inode). These
- * are tracked in the file_hashtbl which is protected by the state_lock
- * spinlock.
+ * These objects are global. nfsd keeps one instance of a nfs4_file per
+ * filehandle (though it may keep multiple file descriptors for each). Each
+ * inode can have multiple filehandles associated with it, so there is
+ * (potentially) a many to one relationship between this struct and struct
+ * inode.
+ *
+ * These are hashed by filehandle in the file_hashtbl, which is protected by
+ * the global state_lock spinlock.
  */
 struct nfs4_file {
 	atomic_t		fi_ref;
 	spinlock_t		fi_lock;
-	struct hlist_node       fi_hash;    /* hash by "struct inode *" */
+	struct hlist_node       fi_hash;	/* hash on fi_fhandle */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;
 	/* One each for O_RDONLY, O_WRONLY, O_RDWR: */
-- 
1.9.3

