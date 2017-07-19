Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754164AbdGSUyB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 16:54:01 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 315CE5BECD
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:54:01 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-174.rdu2.redhat.com [10.10.122.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DCFEB5D9C7
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:54:00 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/11] nfs4mount: removed a warning
Date: Wed, 19 Jul 2017 16:53:53 -0400
Message-Id: <20170719205354.10006-11-steved@redhat.com>
In-Reply-To: <20170719205354.10006-1-steved@redhat.com>
References: <20170719205354.10006-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4mount.c:445:8: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfs4mount.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 028e7cd..89629ed 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -444,6 +444,7 @@ int nfs4mount(const char *spec, const char *node, int flags,
 			case RPC_SYSTEMERROR:
 				if (errno == ETIMEDOUT)
 					break;
+				/* FALLTHRU */
 			default:
 				rpc_mount_errors(hostname, 0, bg);
 				goto fail;
-- 
2.13.3

