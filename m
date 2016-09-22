Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35685 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964779AbcIVRj4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:56 -0400
Received: by mail-it0-f66.google.com with SMTP id e20so5326425itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 20/31] NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
Date: Thu, 22 Sep 2016 13:39:10 -0400
Message-Id: <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle revoked open/lock/delegation stateids when LAYOUTGET tells us
the state was revoked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f0c5442401d7..e5b35e57a8ff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8069,6 +8069,8 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	case -NFS4ERR_RECALLCONFLICT:
 		status = -ERECALLCONFLICT;
 		break;
+	case -NFS4ERR_DELEG_REVOKED:
+	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
 		exception->timeout = 0;
@@ -8080,6 +8082,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 					&lgp->args.ctx->state->stateid)) {
 			spin_unlock(&inode->i_lock);
 			exception->state = lgp->args.ctx->state;
+			exception->stateid = &lgp->args.stateid;
 			break;
 		}
 
-- 
2.7.4

