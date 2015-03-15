Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33828 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbbCOPfU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2015 11:35:20 -0400
Received: by pdbni2 with SMTP id ni2so33508932pdb.1
        for <linux-nfs@vger.kernel.org>; Sun, 15 Mar 2015 08:35:19 -0700 (PDT)
Message-ID: <5505A6AF.7040608@gmail.com>
Date: Sun, 15 Mar 2015 23:35:11 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Anna.Schumaker@netapp.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Use correct reply size calculating function
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ALLOCATE/DEALLOCATE only reply one status value to client,
so, using nfsd4_only_status_rsize for reply size calculating.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 92b9d97..4449359 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2282,13 +2282,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_allocate,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_ALLOCATE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_DEALLOCATE] = {
 		.op_func = (nfsd4op_func)nfsd4_deallocate,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_DEALLOCATE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
-- 
2.3.1

