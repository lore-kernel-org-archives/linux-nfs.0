Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nibbler.cm4all.net ([82.165.145.151]:33707 "EHLO
        nibbler.cm4all.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751256AbeAPRP1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jan 2018 12:15:27 -0500
Received: from localhost (localhost [127.0.0.1])
        by nibbler.cm4all.net (Postfix) with ESMTP id 9BE38C01B9
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jan 2018 18:15:21 +0100 (CET)
Received: from nibbler.cm4all.net ([127.0.0.1])
        by localhost (nibbler.cm4all.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id 1XRKYdeWUJ2v for <linux-nfs@vger.kernel.org>;
        Tue, 16 Jan 2018 18:15:21 +0100 (CET)
Received: from zero.intern.cm-ag (zero.intern.cm-ag [172.30.16.10])
        by nibbler.cm4all.net (Postfix) with SMTP id 746ECC00CB
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jan 2018 18:15:21 +0100 (CET)
Subject: [PATCH] nfs/super: check NFS_CAP_ACLS instead of the NFS version
To: linux-fsdevel@vger.kernel.org, hch@infradead.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        gregkh@linuxfoundation.org
From: Max Kellermann <mk@cm4all.com>
Cc: max.kellermann@gmail.com, linux-kernel@vger.kernel.org
Date: Tue, 16 Jan 2018 18:15:21 +0100
Message-ID: <151612292122.19954.18037823660252329824.stgit@rabbit.intern.cm-ag>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This sets MS_POSIXACL only if ACL support is really enabled, instead
of always setting MS_POSIXACL if the NFS protocol version
theoretically supports ACL.

The code comment says "We will [apply the umask] ourselves", but that
happens in posix_acl_create() only if the kernel has POSIX ACL
support.  Without it, posix_acl_create() is an empty dummy function.

So let's not pretend we will apply the umask if we can already know
that we will never.

This fixes a problem where the umask is always ignored in the NFS
client when compiled without CONFIG_FS_POSIX_ACL.  This is a 4 year
old regression caused by commit 013cdf1088d723 which itself was not
completely wrong, but failed to consider all the side effects by
misdesigned VFS code.

Signed-off-by: Max Kellermann <mk@cm4all.com>
---
 fs/nfs/super.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 29bacdc56f6a..fa9929723bfe 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2345,11 +2345,14 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	if (data && data->bsize)
 		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
 
-	if (server->nfs_client->rpc_ops->version != 2) {
+	if (NFS_SB(sb)->caps & NFS_CAP_ACLS) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
 		 * so ourselves when necessary.
 		 */
 		sb->s_flags |= SB_POSIXACL;
+	}
+
+	if (server->nfs_client->rpc_ops->version != 2) {
 		sb->s_time_gran = 1;
 		sb->s_export_op = &nfs_export_ops;
 	}
@@ -2375,7 +2378,7 @@ static void nfs_clone_super(struct super_block *sb,
 	sb->s_time_gran = 1;
 	sb->s_export_op = old_sb->s_export_op;
 
-	if (server->nfs_client->rpc_ops->version != 2) {
+	if (NFS_SB(sb)->caps & NFS_CAP_ACLS) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
 		 * so ourselves when necessary.
 		 */

