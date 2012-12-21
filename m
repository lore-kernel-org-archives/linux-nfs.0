Return-Path: linux-nfs-owner@vger.kernel.org
Received: from devils.ext.ti.com ([198.47.26.153]:36546 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab2LUL5j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2012 06:57:39 -0500
From: Vaibhav Bedia <vaibhav.bedia@ti.com>
To: <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@netapp.com>
CC: Vaibhav Bedia <vaibhav.bedia@ti.com>
Subject: [PATCH 1/1] NFS: Fix build breakge when CONFIG_NFS_FSCACHE is not defined
Date: Fri, 21 Dec 2012 17:27:30 +0530
Message-ID: <1356091050-17201-1-git-send-email-vaibhav.bedia@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit de242c0b (NFS: Use FS-Cache invalidation) introduced
a build breakge for the case where CONFIG_NFS_FSCACHE is not
defined.

...
fs/nfs/inode.c: In function 'nfs_invalidate_mapping':
fs/nfs/inode.c: error: implicit declaration of function 'nfs_fscache_wait_on_invalidate'
make[2]: *** [fs/nfs/inode.o] Error 1

Add an empty function similar to fix this.

Signed-off-by: Vaibhav Bedia <vaibhav.bedia@ti.com>
---
 fs/nfs/fscache.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index 277b027..e06d4f4 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -223,6 +223,8 @@ static inline void nfs_readpage_to_fscache(struct inode *inode,
 
 static inline void nfs_fscache_invalidate(struct inode *inode) {}
 
+static inline void nfs_fscache_wait_on_invalidate(struct inode *inode) {}
+
 static inline const char *nfs_server_fscache_state(struct nfs_server *server)
 {
 	return "no ";
-- 
1.7.0.4

