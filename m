Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33326 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541AbbDUOui (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 10:50:38 -0400
Received: by paboj16 with SMTP id oj16so243264998pab.0
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 07:50:37 -0700 (PDT)
Message-ID: <553663B7.7030506@gmail.com>
Date: Tue, 21 Apr 2015 22:50:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are some mount points(not exported for nfs) under
a pseudo root, after client's operation of those entry under
the root, anyone can unmount those mount points until nfsd stop.

# cat /etc/exports
/nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
/nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
# ll /nfs/
total 0
drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
# mount /dev/sde /nfs/test
# df
Filesystem                      1K-blocks    Used Available Use% Mounted on
......
/dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
/dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
/dev/sde                           999320    1284    929224   1% /nfs/test
# mount -t nfs 127.0.0.1:/nfs/ /mnt
# ll /mnt/*/
/mnt/pnfs/:
total 0
-rw-r--r--. 1 root root 0 Apr 21 22:23 attr
drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp

/mnt/xfs/:
total 0
# umount /nfs/test/
umount: /nfs/test/: target is busy
        (In some cases useful info about processes that
         use the device is found by lsof(8) or fuser(1).)

I don't think that's user expect, they want umount /nfs/test/.

It's caused by exports cache of nfsd holds the reference of
the path (here is /nfs/test/), so, it can't umounted until nfsd stop.

There is one strange thing exist, the export cache status of
/nfs/test/ is CACHE_NEGATIVE, also hold the reference of the path.
I think nfsd should not hold the reference when CACHE_NEGATIVE.

I can't find a better way to put the reference, just path it after
svc_export_update().

Any comments are welcome, thanks.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c3e3b6e..5595cffc7 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -793,9 +793,15 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
 	int hash = svc_export_hash(old);
 
 	ch = sunrpc_cache_update(old->cd, &new->h, &old->h, hash);
-	if (ch)
-		return container_of(ch, struct svc_export, h);
-	else
+	if (ch) {
+		struct svc_export *exp = container_of(ch, struct svc_export, h);
+		if (test_bit(CACHE_NEGATIVE, &exp->h.flags)) {
+			path_put(&exp->ex_path);
+			exp->ex_path.mnt = NULL;
+			exp->ex_path.dentry = NULL;
+		}
+		return exp;
+	} else
 		return NULL;
 }
 
-- 
2.3.5

