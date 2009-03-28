From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 13/47] nfsd: remove nfsd4_ops array size
Date: Sat, 28 Mar 2009 11:32:05 +0300
Message-ID: <1238229125-10585-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15804 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755509AbZC1IcU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:32:20 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no need for it.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c8e1ad0..ded469f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -951,7 +951,7 @@ out:
 	return status;
 }
 
-static struct nfsd4_operation nfsd4_ops[OP_RELEASE_LOCKOWNER+1] = {
+static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
 		.op_name = "OP_ACCESS",
-- 
1.6.2.1

