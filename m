Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f52.google.com ([209.85.219.52]:34811 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746Ab3FGVgz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 17:36:55 -0400
Received: by mail-oa0-f52.google.com with SMTP id o13so3752186oag.39
        for <linux-nfs@vger.kernel.org>; Fri, 07 Jun 2013 14:36:55 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id z5sm791120obw.4.2013.06.07.14.36.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 14:36:54 -0700 (PDT)
Subject: [PATCH 2 1/2] NFS: Never use user credentials for lease renewal
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 07 Jun 2013 17:36:53 -0400
Message-ID: <20130607213653.1127.85022.stgit@seurat.1015granger.net>
In-Reply-To: <20130607213518.1127.72500.stgit@seurat.1015granger.net>
References: <20130607213518.1127.72500.stgit@seurat.1015granger.net>
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

