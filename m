Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f53.google.com ([209.85.213.53]:32847 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab3FGToy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 15:44:54 -0400
Received: by mail-yh0-f53.google.com with SMTP id a41so1107115yho.12
        for <linux-nfs@vger.kernel.org>; Fri, 07 Jun 2013 12:44:53 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id v5sm271859yhn.27.2013.06.07.12.44.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 12:44:52 -0700 (PDT)
Subject: [PATCH 1/3] NFS: Never use user credentials for lease renewal
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 07 Jun 2013 15:44:51 -0400
Message-ID: <20130607194451.1296.18053.stgit@seurat.1015granger.net>
In-Reply-To: <20130607194140.1296.54746.stgit@seurat.1015granger.net>
References: <20130607194140.1296.54746.stgit@seurat.1015granger.net>
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

