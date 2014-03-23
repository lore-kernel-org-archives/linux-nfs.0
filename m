Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47869 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131AbaCWBM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 16/50] nfsd4: READ, READDIR, etc., are idempotent
Date: Sat, 22 Mar 2014 21:11:47 -0400
Message-Id: <1395537141-10389-17-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

OP_MODIFIES_SOMETHING flags operations that we should be careful not to
initiate without being sure we have the buffer space to encode a reply.

None of these ops fall into that category.

We could probably remove a few more, but this isn't a very important
problem at least for ops whose reply size is easy to estimate.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index afa7ff7..a61f492 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1630,38 +1630,31 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
-				| OP_CLEAR_STATEID,
+				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTFH",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_PUTPUBFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
-				| OP_CLEAR_STATEID,
+				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTPUBFH",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
-				| OP_CLEAR_STATEID,
+				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTROOTFH",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_READ] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
-		.op_flags = OP_MODIFIES_SOMETHING,
-		.op_name = "OP_READ",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
-		.op_flags = OP_MODIFIES_SOMETHING,
-		.op_name = "OP_READDIR",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_readdir_rsize,
 	},
 	[OP_READLINK] = {
-- 
1.8.5.3

