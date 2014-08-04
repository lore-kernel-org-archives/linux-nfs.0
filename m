Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:54468 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbaHDIS3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2014 04:18:29 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so9574231pab.16
        for <linux-nfs@vger.kernel.org>; Mon, 04 Aug 2014 01:18:29 -0700 (PDT)
Message-ID: <53DF41C8.70303@gmail.com>
Date: Mon, 04 Aug 2014 16:18:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFS: Avoid infinite loop when RELEASE_LOCKOWNER getting
 expired error
References: <53DE56C7.2080407@gmail.com> <CAHQdGtQRhmvWWizba58ApjrcWwPt-E8uUNNT4DYJNF2YXncSWw@mail.gmail.com>
In-Reply-To: <CAHQdGtQRhmvWWizba58ApjrcWwPt-E8uUNNT4DYJNF2YXncSWw@mail.gmail.com>
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
 fs/nfs/nfs4proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 285ad53..75dcce29c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5834,8 +5834,10 @@ struct nfs_release_lockowner_data {
 static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_release_lockowner_data *data = calldata;
-	nfs40_setup_sequence(data->server,
-				&data->args.seq_args, &data->res.seq_res, task);
+	struct nfs_server *server = data->server;
+	nfs40_setup_sequence(server, &data->args.seq_args,
+				&data->res.seq_res, task);
+	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
 	data->timestamp = jiffies;
 }
 
@@ -5852,6 +5854,8 @@ static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
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


