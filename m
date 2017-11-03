Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:45389 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933502AbdKCRrA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 13:47:00 -0400
Received: by mail-io0-f196.google.com with SMTP id i38so7974948iod.2
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 10:47:00 -0700 (PDT)
Subject: [PATCH] nfs: Fix ugly referral attributes
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 03 Nov 2017 13:46:59 -0400
Message-ID: <20171103174658.31159.24496.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before traversing a referral and performing a mount, the mounted-on
directory looks strange:

dr-xr-xr-x. 2 4294967294 4294967294 0 Dec 31  1969 dir.0

nfs4_get_referral is wiping out any cached attributes with what was
returned via GETATTR(fs_locations), but the bit mask for that
operation does not request any file attributes.

Set the default bits in the GETATTR bitmask to retrieve the usual
set of object attributes so that the memcpy in nfs4_get_referral can
fill the attributes in properly.

Fixes: 6b97fd3da1ea ("NFSv4: Follow a referral")
Suggested-by: Pradeep Thomas <pradeepthomas@gmail.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6c61e2b..ec3c525 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6763,9 +6763,7 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 				   struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	u32 bitmask[3] = {
-		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
-	};
+	u32 bitmask[3];
 	struct nfs4_fs_locations_arg args = {
 		.dir_fh = NFS_FH(dir),
 		.name = name,
@@ -6784,6 +6782,10 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 
 	dprintk("%s: start\n", __func__);
 
+	bitmask[0] = nfs4_fattr_bitmap[0] | FATTR4_WORD0_FS_LOCATIONS;
+	bitmask[1] = nfs4_fattr_bitmap[1];
+	bitmask[2] = nfs4_fattr_bitmap[2] & ~FATTR4_WORD2_SECURITY_LABEL;
+
 	/* Ask for the fileid of the absent filesystem if mounted_on_fileid
 	 * is not supported */
 	if (NFS_SERVER(dir)->attr_bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)

