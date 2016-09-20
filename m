Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35036 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcITQ4o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:44 -0400
Received: by mail-qt0-f194.google.com with SMTP id 38so723239qte.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 20/29] NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
Date: Tue, 20 Sep 2016 12:56:02 -0400
Message-Id: <1474390571-17106-21-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-20-git-send-email-trond.myklebust@primarydata.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-14-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-15-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-16-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-17-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-18-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-19-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-20-git-send-email-trond.myklebust@primarydata.com>
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

