Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754550AbdGUQiL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:11 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C24F23B729
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:11 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 762ED60C14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:11 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/11] nfsmount: remove a warning
Date: Fri, 21 Jul 2017 12:38:04 -0400
Message-Id: <20170721163806.15803-10-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsmount.c:684:8: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfsmount.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 930622d..ae4a3da 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -683,6 +683,7 @@ nfsmount(const char *spec, const char *node, int flags,
 			case RPC_SYSTEMERROR:
 				if (errno == ETIMEDOUT)
 					break;
+				/* FALLTHRU */
 			default:
 				rpc_mount_errors(*nfs_server.hostname, 0, bg);
 		        goto fail;
-- 
2.13.3

