Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58358 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764Ab2FETAa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 15:00:30 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Jorge.Mora@netapp.com, iisaman@netapp.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS4: Set parsed mount data version to 4
Date: Tue,  5 Jun 2012 14:59:54 -0400
Message-Id: <1338922794-26715-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch only affects mounting through "-t nfs4" since it doesn't set
up an nfs version to use in the mount data.  The nfs client was trying
to mount using NFS v0, causing either a BUG() or a protocol not
supported message.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ff656c0..bdd6731 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2637,6 +2637,8 @@ static int nfs4_validate_mount_data(void *options,
 	if (data == NULL)
 		goto out_no_data;
 
+	args->version = 4;
+
 	switch (data->version) {
 	case 1:
 		if (data->host_addrlen > sizeof(args->nfs_server.address))
-- 
1.7.10.3

