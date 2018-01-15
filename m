Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nibbler.cm4all.net ([82.165.145.151]:53324 "EHLO
        nibbler.cm4all.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753248AbeAORj1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jan 2018 12:39:27 -0500
Received: from localhost (localhost [127.0.0.1])
        by nibbler.cm4all.net (Postfix) with ESMTP id 1906BC03D7
        for <linux-nfs@vger.kernel.org>; Mon, 15 Jan 2018 18:30:52 +0100 (CET)
Received: from nibbler.cm4all.net ([127.0.0.1])
        by localhost (nibbler.cm4all.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id bqEQARWS90_B for <linux-nfs@vger.kernel.org>;
        Mon, 15 Jan 2018 18:30:51 +0100 (CET)
Received: from zero.intern.cm-ag (zero.intern.cm-ag [172.30.16.10])
        by nibbler.cm4all.net (Postfix) with SMTP id E2725C03CB
        for <linux-nfs@vger.kernel.org>; Mon, 15 Jan 2018 18:30:51 +0100 (CET)
Subject: [PATCH 2/2] dFrom: Max Kellermann <mk@cm4all.com>
To: linux-fsdevel@vger.kernel.org, hch@infradead.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        gregkh@linuxfoundation.org
From: Max Kellermann <mk@cm4all.com>
Cc: max.kellermann@gmail.com, linux-kernel@vger.kernel.org
Date: Mon, 15 Jan 2018 18:30:51 +0100
Message-ID: <151603745169.29035.6866708909114015882.stgit@rabbit.intern.cm-ag>
In-Reply-To: <151603744662.29035.4910161264124875658.stgit@rabbit.intern.cm-ag>
References: <151603744662.29035.4910161264124875658.stgit@rabbit.intern.cm-ag>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs/super: set MS_POSIXACL only if ACL support is enabled

The code comment says "We will [apply the umask] ourselves", but that
happens in posix_acl_create() only if the kernel has POSIX ACL
support.  Without it, posix_acl_create() is a is an empty dummy
function.

So let's not pretend we will apply the umask if we can already know
that we will never.

This fixes a problem where the umask is always ignored in the NFS
client when compiled without CONFIG_FS_POSIX_ACL.  This is a 4 year
old regression caused by commit 013cdf1088d723 which itself was not
completely wrong, but failed to consider all the side effects by
misdesigned VFS code.

There are two compile-time checks and one runtime check:

- If CONFIG_FS_POSIX_ACL=n, then MS_POSIXACL is never set.

- If CONFIG_FS_POSIX_ACL=y and CONFIG_NFS_V3_ACL=n, then only NFSv4
  has ACL support (and cannot be disabled), and we need to check for
  "version==4".

- If CONFIG_FS_POSIX_ACL=y and CONFIG_NFS_V3_ACL=y, MS_POSIXACL is
  always set, as before.

Signed-off-by: Max Kellermann <mk@cm4all.com>
---
 fs/nfs/super.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 216f67d628b3..ec4e1f2775e0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2338,10 +2338,17 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
 
 	if (server->nfs_client->rpc_ops->version != 2) {
-		/* The VFS shouldn't apply the umask to mode bits. We will do
-		 * so ourselves when necessary.
-		 */
-		sb->s_flags |= MS_POSIXACL;
+#ifdef CONFIG_FS_POSIX_ACL
+#ifndef CONFIG_NFS_V3_ACL
+		if (nfss->nfs_client->rpc_ops->version == 4)
+#endif
+			/* The VFS shouldn't apply the umask to mode
+			 * bits. We will do so ourselves when
+			 * necessary.
+			 */
+			sb->s_flags |= MS_POSIXACL;
+#endif
+
 		sb->s_time_gran = 1;
 		sb->s_export_op = &nfs_export_ops;
 	}

