Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23265 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415Ab3GWEFW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 00:05:22 -0400
Message-ID: <1374552314.5454.89.camel@serendib>
Subject: [PATCH] nfsd: nfs4_file_get_access: need to be more careful with
 O_RDWR
From: Harshula Jayasuriya <harshula@redhat.com>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Date: Tue, 23 Jul 2013 14:05:14 +1000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If fi_fds = {non-NULL, NULL, non-NULL} and oflag = O_WRONLY
the WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]))
doesn't trigger when it should.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
---
 fs/nfsd/nfs4state.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 280acef..1cb6211 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -282,19 +282,14 @@ static unsigned int file_hashval(struct inode *ino)
 
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 
-static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
-{
-	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
-	atomic_inc(&fp->fi_access[oflag]);
-}
-
 static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 {
+	WARN_ON_ONCE(!fp->fi_fds[oflag]);
 	if (oflag == O_RDWR) {
-		__nfs4_file_get_access(fp, O_RDONLY);
-		__nfs4_file_get_access(fp, O_WRONLY);
+		atomic_inc(&fp->fi_access[O_RDONLY]);
+		atomic_inc(&fp->fi_access[O_WRONLY]);
 	} else
-		__nfs4_file_get_access(fp, oflag);
+		atomic_inc(&fp->fi_access[oflag]);
 }
 
 static void nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
-- 
1.8.1.4

