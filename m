Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f177.google.com ([209.85.192.177]:48580 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046AbaHGDKv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 23:10:51 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so4330083pdj.8
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 20:10:50 -0700 (PDT)
Message-ID: <53E2EE2E.9040007@gmail.com>
Date: Thu, 07 Aug 2014 11:10:38 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 2/2] NFSD: Revert setting op_encode_lockowner_maxsz
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8c7424cff6 (nfsd4: don't try to encode conflicting owner if low on space)
set op_encode_lockowner_maxsz to zero.

If setting op_encode_lockowner_maxsz to zero, nfsd will not encode
the owner of conflock forever.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 084e46e..55635a8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1417,8 +1417,7 @@ out:
 #define op_encode_change_info_maxsz	(5)
 #define nfs4_fattr_bitmap_maxsz		(4)
 
-/* We'll fall back on returning no lockowner if run out of space: */
-#define op_encode_lockowner_maxsz	(0)
+#define op_encode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define op_encode_lock_denied_maxsz	(8 + op_encode_lockowner_maxsz)
 
 #define nfs4_owner_maxsz		(1 + XDR_QUADLEN(IDMAP_NAMESZ))
-- 
1.9.3

