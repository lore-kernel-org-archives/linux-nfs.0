Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f173.google.com ([209.85.160.173]:65435 "EHLO
	mail-gh0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab3FYQXt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:23:49 -0400
Received: by mail-gh0-f173.google.com with SMTP id g16so4041414ghb.4
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 09:23:48 -0700 (PDT)
Subject: [PATCH 3/5] NFS: Never use user credentials for lease renewal
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Jun 2013 12:23:46 -0400
Message-ID: <20130625162346.36416.25389.stgit@seurat.1015granger.net>
In-Reply-To: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't try to use a non-UID-0 user credential for lease management,
as that credential can change out from under us.  The server will
block NFSv4 lease recovery with NFS4ERR_CLID_INUSE.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d7ba561..5ba38b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6919,7 +6919,7 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_init_clientid,
-	.get_clid_cred	= nfs4_get_setclientid_cred,
+	.get_clid_cred	= nfs4_get_exchange_id_cred,
 	.detect_trunking = nfs40_discover_server_trunking,
 };
 
@@ -6942,7 +6942,7 @@ static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.establish_clid = nfs4_init_clientid,
-	.get_clid_cred	= nfs4_get_setclientid_cred,
+	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 
 #if defined(CONFIG_NFS_V4_1)

