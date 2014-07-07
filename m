Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:47637 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbaGGON6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 10:13:58 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so5359834pdb.25
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 07:13:57 -0700 (PDT)
Message-ID: <53BAAAFE.8090403@gmail.com>
Date: Mon, 07 Jul 2014 22:13:18 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 3/4 RFC] NFSD: Revert setting op_encode_lockowner_maxsz
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8c7424cff6 (nfsd4: don't try to encode conflicting owner if low on space)
set op_encode_lockowner_maxsz to zero.

When testing nfsd4_lock with conflict lock (has right owner), dmesg gets
  "[18668.241385] RPC request reserved 88 but used 108"
because xdr_reserve_space don't return NULL in nfsd4_encode_lock_denied.

Just revert op_encode_lockowner_maxsz.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 846fd55..6217190 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1422,8 +1422,7 @@ out:
 #define op_encode_change_info_maxsz	(5)
 #define nfs4_fattr_bitmap_maxsz		(4)
 
-/* We'll fall back on returning no lockowner if run out of space: */
-#define op_encode_lockowner_maxsz	(0)
+#define op_encode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define op_encode_lock_denied_maxsz	(8 + op_encode_lockowner_maxsz)
 
 #define nfs4_owner_maxsz		(1 + XDR_QUADLEN(IDMAP_NAMESZ))
-- 
1.9.3

