Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8386 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1FBPSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2011 11:18:12 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 fs_locations compound request fileid
Date: Thu,  2 Jun 2011 11:17:20 -0400
Message-Id: <1307027840-3137-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Commit 28331a46d88459788c8fca72dbb0415cd7f514c9 "Ensure we request the
ordinary fileid when doing readdirplus"
changed the meaning of NFS_ATTR_FATTR_FILEID which used to be set when
FATTR4_WORD1_MOUNTED_ON_FILED was requested. Request FATTR4_WORD0_FILEID
in the nfs4_proc_fs_locations GETATTR so that nfs_fhget succeeds and
the referral is mounted.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2c4b59..d99c5f8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4685,7 +4685,8 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	u32 bitmask[2] = {
-		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
+		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS |
+		      FATTR4_WORD0_FILEID,
 		[1] = FATTR4_WORD1_MOUNTED_ON_FILEID,
 	};
 	struct nfs4_fs_locations_arg args = {
-- 
1.7.3.1

