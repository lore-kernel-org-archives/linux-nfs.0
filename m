Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f42.google.com ([209.85.219.42]:53835 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaCZJMP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Mar 2014 05:12:15 -0400
Received: by mail-oa0-f42.google.com with SMTP id i4so2195155oah.29
        for <linux-nfs@vger.kernel.org>; Wed, 26 Mar 2014 02:12:15 -0700 (PDT)
Message-ID: <533299E9.6010806@gmail.com>
Date: Wed, 26 Mar 2014 17:12:09 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: bfields@fieldses.org
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSD: Re-initialize fh_post/pre_saved between two operations
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Testing NFS4.0 by pynfs, I got some messeages as,
"nfsd: inode locked twice during operation."

When one compound RPC contains two or more SETATTR operation
for one filehandle,the second SETATTR will cause the message.

Because after the first SETATTR, nfsd will not call fh_put()
to release current filehandle, it means filehandle have unlocked
with fh_post_saved = 1.
The second SETATTR find fh_post_saved = 1, and printk the message.

This patch re-initialize fh_post/pre_saved between two operations.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 550faf2..103d1ac 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1356,6 +1356,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			  !(opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
 			op->status = nfserr_moved;
 			goto encode_op;
+		} else {
+			current_fh->fh_post_saved = 0;
+			current_fh->fh_pre_saved = 0;
 		}

 		/* If op is non-idempotent */
-- 
1.8.5.3

