Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35811 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756486AbcIQFNy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:54 -0400
Received: by mail-it0-f68.google.com with SMTP id e20so1839521itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 19/25] NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
Date: Sat, 17 Sep 2016 01:13:27 -0400
Message-Id: <1474089213-104014-20-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-19-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-17-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-18-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-19-git-send-email-trond.myklebust@primarydata.com>
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

