Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.stealer.net ([88.198.224.204]:60051 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724Ab2LLXOm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2012 18:14:42 -0500
Date: Thu, 13 Dec 2012 00:14:37 +0100 (CET)
From: Sven Wegener <sven.wegener@stealer.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFSv4: Check for buffer length in __nfs4_get_acl_uncached
Message-ID: <alpine.LNX.2.02.1212130009400.10324@titan.int.lan.stealer.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1f1ea6c "NFSv4: Fix buffer overflow checking in
__nfs4_get_acl_uncached" accidently dropped the checking for too small
result buffer length.

If someone uses getxattr on "system.nfs4_acl" on an NFSv4 mount
supporting ACLs, the ACL has not been cached and the buffer suplied is
too short, we still copy the complete ACL, resulting in kernel and user
space memory corruption.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
Cc: stable@kernel.org
---
 fs/nfs/nfs4proc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Resending, because it did not get any response.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7bff871..f15be6b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3831,8 +3831,13 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		goto out_free;
 	}
 	nfs4_write_cached_acl(inode, pages, res.acl_data_offset, res.acl_len);
-	if (buf)
+	if (buf) {
+		if (res.acl_len > buflen) {
+			ret = -ERANGE;
+			goto out_free;
+		}
 		_copy_from_pages(buf, pages, res.acl_data_offset, res.acl_len);
+	}
 out_ok:
 	ret = res.acl_len;
 out_free:
