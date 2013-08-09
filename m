Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f50.google.com ([209.85.213.50]:46855 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968210Ab3HIQuw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:50:52 -0400
Received: by mail-yh0-f50.google.com with SMTP id a41so1508772yho.23
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:50:51 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id u25sm20675423yhl.23.2013.08.09.09.50.51
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:50:51 -0700 (PDT)
Subject: [PATCH v2 21/33] NFS: Export _nfs_display_fhandle()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:50:50 -0400
Message-ID: <20130809165050.5362.655.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow code in nfsv4.ko to use _nfs_display_fhandle().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/inode.c      |    2 ++
 fs/nfs/nfs4client.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..7d52385 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1192,6 +1192,7 @@ u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh)
 	 * not on the result */
 	return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
 }
+EXPORT_SYMBOL_GPL(_nfs_display_fhandle_hash);
 
 /*
  * _nfs_display_fhandle - display an NFS file handle on the console
@@ -1236,6 +1237,7 @@ void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(_nfs_display_fhandle);
 #endif
 
 /**
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d462e40..55d4ff5 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -809,7 +809,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	dprintk("Server FSID: %llx:%llx\n",
 			(unsigned long long) server->fsid.major,
 			(unsigned long long) server->fsid.minor);
-	dprintk("Mount FH: %d\n", mntfh->size);
+	nfs_display_fhandle(mntfh, "Pseudo-fs root FH");
 
 	nfs4_session_set_rwsize(server);
 

