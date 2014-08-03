Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44424 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbaHCOu4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 10:50:56 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so8160602pdj.15
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 07:50:56 -0700 (PDT)
Message-ID: <53DE4C33.1040509@gmail.com>
Date: Sun, 03 Aug 2014 22:50:27 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: NFS: Don't restart release lockowner RPC if getting expired error
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix Commit 60ea681299 (NFS: Migration support for RELEASE_LOCKOWNER)
If getting expired error, client will enter a infinite loop as,

client                            server
   RELEASE_LOCKOWNER(old clid) ----->
                <--- expired error
   RENEW(old clid)             ----->
                <--- expired error
   SETCLIENTID                 ----->
                <--- a new clid
   SETCLIENTID_CONFIRM (new clid) -->
                <--- ok
   RELEASE_LOCKOWNER(old clid) ----->
                <--- expired error
   RENEW(new clid)             ----->
                <-- ok
   RELEASE_LOCKOWNER(old clid) ----->
                <--- expired error
   RENEW(new clid)             ----->
                <-- ok
                ... ...

This patch just handle the expired error to register clientid,
but not restart a release lockowner RPC.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 285ad53..902aadf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5852,6 +5852,8 @@ static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
 		break;
 	case -NFS4ERR_STALE_CLIENTID:
 	case -NFS4ERR_EXPIRED:
+		nfs4_async_handle_error(task, server, NULL);
+		break;
 	case -NFS4ERR_LEASE_MOVED:
 	case -NFS4ERR_DELAY:
 		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
-- 
1.9.3

