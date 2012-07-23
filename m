Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45230 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661Ab2GWTuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jul 2012 15:50:04 -0400
Received: by yenl2 with SMTP id l2so5885784yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jul 2012 12:50:04 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: viro@ZenIV.linux.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix fl_type tests in NFSv4 code
Date: Mon, 23 Jul 2012 15:49:56 -0400
Message-Id: <1343072996-29852-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fl_type is not a bitmap.

Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 fs/nfs/nfs4xdr.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15fc7e4..32b3048 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4824,7 +4824,7 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	 * Don't rely on the VFS having checked the file open mode,
 	 * since it won't do this for flock() locks.
 	 */
-	switch (request->fl_type & (F_RDLCK|F_WRLCK|F_UNLCK)) {
+	switch (request->fl_type) {
 	case F_RDLCK:
 		if (!(filp->f_mode & FMODE_READ))
 			return -EBADF;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 18fae29..b3199c7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1236,7 +1236,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 
 static inline int nfs4_lock_type(struct file_lock *fl, int block)
 {
-	if ((fl->fl_type & (F_RDLCK|F_WRLCK|F_UNLCK)) == F_RDLCK)
+	if (fl->fl_type == F_RDLCK)
 		return block ? NFS4_READW_LT : NFS4_READ_LT;
 	return block ? NFS4_WRITEW_LT : NFS4_WRITE_LT;
 }
-- 
1.7.10.4

