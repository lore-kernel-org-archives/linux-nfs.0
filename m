Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab0KUTVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:45 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFS: Buffer overflow in ->decode_dirent() should not be fatal
Date: Sun, 21 Nov 2010 14:21:15 -0500
Message-Id: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Overflowing the buffer in the readdir ->decode_dirent() should not lead to
a fatal error, but rather to an attempt to reread the record in question.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs2xdr.c |    2 +-
 fs/nfs/nfs3xdr.c |    2 +-
 fs/nfs/nfs4xdr.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 2563f76..ab59377 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -495,7 +495,7 @@ nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_se
 
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
+	return ERR_PTR(-EAGAIN);
 }
 
 /*
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 748dc91..e79e4f5 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -656,7 +656,7 @@ nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_s
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 out_overflow_exit:
-	return ERR_PTR(-EIO);
+	return ERR_PTR(-EAGAIN);
 }
 
 /*
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b7a204f..a3b39cb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6221,7 +6221,7 @@ __be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
+	return ERR_PTR(-EAGAIN);
 }
 
 /*
-- 
1.7.3.2

