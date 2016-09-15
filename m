Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33879 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbcIOQqY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:24 -0400
Received: by mail-it0-f67.google.com with SMTP id 186so5035621itf.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 16/20] NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
Date: Thu, 15 Sep 2016 12:45:56 -0400
Message-Id: <1473957960-10001-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473957960-10001-16-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server tells us our stateid has expired, then handle that as if
it was revoked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75edf90455b4..0c050e932c7e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6086,6 +6086,7 @@ static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_
 {
 	switch (error) {
 	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
 		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
 		if (new_lock_owner != 0 ||
@@ -6094,7 +6095,6 @@ static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_
 		break;
 	case -NFS4ERR_STALE_STATEID:
 		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
-	case -NFS4ERR_EXPIRED:
 		nfs4_schedule_lease_recovery(server->nfs_client);
 	};
 }
-- 
2.7.4

