Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41047 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbbARMag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jan 2015 07:30:36 -0500
From: Junxiao Bi <junxiao.bi@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: [PATCH] nfsd: fix memory corruption due to uninitialized variable
Date: Sun, 18 Jan 2015 20:29:02 +0800
Message-Id: <1421584142-12505-1-git-send-email-junxiao.bi@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_decode_open() doesn't initialize variable open->op_file and
open->op_stp, they are initialized in nfsd4_process_open1(), but if
any error happens before initializing them, nfsd4_open() will call
into nfsd4_cleanup_open_state() and corrupt the memory.

Since nfsd4_process_open1() will initialize these two variables and
open->op_openowner, make them default to null at the beginning.

Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
---
 fs/nfsd/nfs4state.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c06a1ba..6e74a91 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3547,6 +3547,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *oo = NULL;
 	__be32 status;
 
+	open->op_file = NULL;
+	open->op_openowner = NULL;
+	open->op_stp = NULL;
+
 	if (STALE_CLIENTID(&open->op_clientid, nn))
 		return nfserr_stale_clientid;
 	/*
-- 
1.7.9.5

