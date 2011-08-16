Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:42489 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751489Ab1HPMCl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 08:02:41 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1QtIKv-0006Qu-Ca
	for linux-nfs@vger.kernel.org; Tue, 16 Aug 2011 08:01:37 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: submarvellous messages from mount.nfs
Date: Tue, 16 Aug 2011 08:02:39 -0400
Message-Id: <1313496159-4281-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Max Matveev <makc@redhat.com>

Consider a setup where mountd on the server is controlled via
tcp_wrappers (usual RHEL setup) and will not process calls from a
particular client because of something in /etc/hosts.deny.

When such client attempts to do v3 mount, the error message printed
by mount.nfs is misleading.

This patch changes that error message from:
    mount.nfs: Argument list too long
to
    mount.nfs: access denied by server while mounting server:/export

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f1aa503..4d023d6 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -538,6 +538,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 		errno = ESPIPE;
 		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
 			errno = EOPNOTSUPP;
+		else if (rpc_createerr.cf_stat == RPC_AUTHERROR)
+			errno = EACCES;
 		else if (rpc_createerr.cf_error.re_errno != 0)
 			errno = rpc_createerr.cf_error.re_errno;
 		return 0;
-- 
1.7.6

