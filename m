Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756000Ab2KZURN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:13 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qAQKHDC9009937
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 15:17:13 -0500
Received: from smallhat.bos.devel.redhat.com (vpn-9-97.rdu.redhat.com [10.11.9.97])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qAQKHBB2026413
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 15:17:12 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] mount.nfs: error message clean up.
Date: Mon, 26 Nov 2012 15:17:08 -0500
Message-Id: <1353961029-6317-2-git-send-email-steved@redhat.com>
In-Reply-To: <1353961029-6317-1-git-send-email-steved@redhat.com>
References: <1353961029-6317-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove a unnecessary newline in an error message.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/error.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 83ad1d2..f8fc13f 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -225,7 +225,7 @@ void mount_error(const char *spec, const char *mount_point, int error)
 	case ENOENT:
 		if (spec)
 			nfs_error(_("%s: mounting %s failed, "
-				"reason given by server:\n  %s"),
+				"reason given by server: %s"),
 				progname, spec, strerror(error));
 		else
 			nfs_error(_("%s: mount point %s does not exist"),
-- 
1.7.11.7

