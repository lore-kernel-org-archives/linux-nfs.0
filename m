Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751903AbeDSNbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:31:11 -0400
Subject: [PATCH 01/24] vfs: Undo an overly zealous MS_RDONLY -> SB_RDONLY
 conversion [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:31:08 +0100
Message-ID: <152414466871.23902.14667248706795552315.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In do_mount() when the MS_* flags are being converted to MNT_* flags,
MS_RDONLY got accidentally convered to SB_RDONLY.

Undo this change.

Fixes: e462ec50cb5f ("VFS: Differentiate mount flags (MS_*) from internal superblock flags")
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index e398f32d7541..6f720ebca133 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2814,7 +2814,7 @@ long do_mount(const char *dev_name, const char __user *dir_name,
 		mnt_flags |= MNT_NODIRATIME;
 	if (flags & MS_STRICTATIME)
 		mnt_flags &= ~(MNT_RELATIME | MNT_NOATIME);
-	if (flags & SB_RDONLY)
+	if (flags & MS_RDONLY)
 		mnt_flags |= MNT_READONLY;
 
 	/* The default atime for remount is preservation */

