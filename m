Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f54.google.com ([209.85.213.54]:33357 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab3FYQX6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:23:58 -0400
Received: by mail-yh0-f54.google.com with SMTP id f73so5824039yha.41
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 09:23:57 -0700 (PDT)
Subject: [PATCH 4/5] NFS: Export _nfs_display_fhandle()
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Jun 2013 12:23:55 -0400
Message-ID: <20130625162355.36416.28299.stgit@seurat.1015granger.net>
In-Reply-To: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow code in nfsv4.ko to use _nfs_display_fhandle().  Useful for
debugging NFSv4 migration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/inode.c      |    2 ++
 fs/nfs/nfs4client.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c1c7a9d..319203d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1102,6 +1102,7 @@ u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh)
 	 * not on the result */
 	return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
 }
+EXPORT_SYMBOL_GPL(_nfs_display_fhandle_hash);
 
 /*
  * _nfs_display_fhandle - display an NFS file handle on the console
@@ -1146,6 +1147,7 @@ void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(_nfs_display_fhandle);
 #endif
 
 /**
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b7a9f76..3aec2de 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -757,7 +757,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	dprintk("Server FSID: %llx:%llx\n",
 			(unsigned long long) server->fsid.major,
 			(unsigned long long) server->fsid.minor);
-	dprintk("Mount FH: %d\n", mntfh->size);
+	nfs_display_fhandle(mntfh, "Mount FH");
 
 	nfs4_session_set_rwsize(server);
 

