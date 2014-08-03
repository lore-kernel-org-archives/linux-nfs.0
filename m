Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f173.google.com ([209.85.192.173]:64453 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbaHCPgN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 11:36:13 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so8203437pde.32
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 08:36:12 -0700 (PDT)
Message-ID: <53DE56C7.2080407@gmail.com>
Date: Sun, 03 Aug 2014 23:35:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] NFS: Update clientid in RELEASE_LOCKOWNER RPC after re-register
 clientid
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

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 285ad53..6c4e6c1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5834,8 +5834,11 @@ struct nfs_release_lockowner_data {
 static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_release_lockowner_data *data = calldata;
-	nfs40_setup_sequence(data->server,
-				&data->args.seq_args, &data->res.seq_res, task);
+	struct nfs_server *server = data->server;
+
+	nfs40_setup_sequence(server, &data->args.seq_args,
+				 &data->res.seq_res, task);
+	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
 	data->timestamp = jiffies;
 }
 
-- 
1.9.3

