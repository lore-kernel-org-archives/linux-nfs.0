Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:32945 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752086AbeDWUZx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2018 16:25:53 -0400
MIME-Version: 1.0
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Apr 2018 13:25:52 -0700
Message-ID: <CAOQ4uxg+qSLP0KwdW+h1tcPqOCQd+_pGZVXiePQB1TXCMBMctQ@mail.gmail.com>
Subject: [RESEND PATCH v2] tmpfs: allow decoding a file handle of an unlinked file
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Neil Brown <neilb@suse.de>, Hugh Dickins <hughd@google.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tmpfs uses the helper d_find_alias() to find a dentry from a decoded
inode, but d_find_alias() skips unhashed dentries, so unlinked files
cannot be decoded from a file handle.

This can be reproduced using xfstests test program open_by_handle:
$ open_by handle -c /tmp/testdir
$ open_by_handle -dk /tmp/testdir
open_by_handle(/tmp/testdir/file000000) returned 116 incorrectly on an
unlinked open file!

To fix this, if d_find_alias() can't find a hashed alias, call
d_find_any_alias() to return an unhashed one.

Cc: Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Amir Goldstein <amir73il@gmail.com>
---

Hi Andrew,

I was nudging Hugh over at LSF/MM about this patch and he has
suggested that I send it to you, because he has no idea about the
exportfs parts.

The test for decoding a file handle of an unlinked file has already
been merged to xfstest generic/467 and the test is failing on tmpfs
without this change.

Can you please take this patch.

Thanks,
Amir.

 mm/shmem.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22807be..5d3fa4099f54 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3404,6 +3404,15 @@ static int shmem_match(struct inode *ino, void *vfh)
        return ino->i_ino == inum && fh[0] == ino->i_generation;
 }

+/* Find any alias of inode, but prefer a hashed alias */
+static struct dentry *shmem_find_alias(struct inode *inode)
+{
+       struct dentry *alias = d_find_alias(inode);
+
+       return alias ?: d_find_any_alias(inode);
+}
+
+
 static struct dentry *shmem_fh_to_dentry(struct super_block *sb,
                struct fid *fid, int fh_len, int fh_type)
 {
@@ -3420,7 +3429,7 @@ static struct dentry *shmem_fh_to_dentry(struct
super_block *sb,
        inode = ilookup5(sb, (unsigned long)(inum + fid->raw[0]),
                        shmem_match, fid->raw);
        if (inode) {
-               dentry = d_find_alias(inode);
+               dentry = shmem_find_alias(inode);
                iput(inode);
        }

--
2.7.4
