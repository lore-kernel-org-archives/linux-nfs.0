Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35032 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcITQ4m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:42 -0400
Received: by mail-qt0-f196.google.com with SMTP id 38so723220qte.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 19/29] NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
Date: Tue, 20 Sep 2016 12:56:01 -0400
Message-Id: <1474390571-17106-20-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-19-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server tells us our stateid has expired, then handle that as if
it was revoked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75dc389c9719..f0c5442401d7 100644
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

