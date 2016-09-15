Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33383 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754086AbcIOQqZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:25 -0400
Received: by mail-it0-f67.google.com with SMTP id x192so5063995itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 17/20] NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
Date: Thu, 15 Sep 2016 12:45:57 -0400
Message-Id: <1473957960-10001-18-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473957960-10001-17-git-send-email-trond.myklebust@primarydata.com>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-2-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-3-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-4-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-5-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-6-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-7-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-8-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-9-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-10-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-11-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-12-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-13-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-14-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-15-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-16-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-17-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle revoked open/lock/delegation stateids when LAYOUTGET tells us
the state was revoked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0c050e932c7e..e2ab6f665dba 100644
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

