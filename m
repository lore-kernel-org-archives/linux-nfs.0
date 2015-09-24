Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35322 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbIXM4k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:56:40 -0400
Received: by pacfv12 with SMTP id fv12so73893746pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:56:40 -0700 (PDT)
Subject: [PATCH 3/8] NFS: Remove the left function defines in callback.h
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F2FD.1010601@gmail.com>
Date: Thu, 24 Sep 2015 20:56:29 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 778be232a207 "NFS do not find client in NFSv4 pg_authenticate" has remove
the define and using of nfs4_set_callback_sessionid(), and
commit 36281caa839f "NFSv4: Further clean-ups of delegation stateid validation"
has update the checking of stateid, and move the code to nfs4proc.c.

This patch remove those function defines left in callback.h

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index cbcc903..ff8195b 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -117,9 +117,6 @@ extern __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 				       struct cb_sequenceres *res,
 				       struct cb_process_state *cps);
 
-extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
-					     const nfs4_stateid *stateid);
-
 #define RCA4_TYPE_MASK_RDATA_DLG	0
 #define RCA4_TYPE_MASK_WDATA_DLG	1
 #define RCA4_TYPE_MASK_DIR_DLG         2
@@ -191,9 +188,6 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 #if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion, struct net *net);
-extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
-					    const nfs4_stateid *stateid);
-extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4 */
 /*
  * nfs41: Callbacks are expected to not cause substantial latency,
-- 
2.5.0

