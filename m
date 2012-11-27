Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136Ab2K0RE6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 12:04:58 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qARH4wJK002988
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2012 12:04:58 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qARH4vVk031093
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2012 12:04:58 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2 V2] mount.nfs: error message clean up.
Date: Tue, 27 Nov 2012 12:01:24 -0500
Message-Id: <1354035684-15802-2-git-send-email-steved@redhat.com>
In-Reply-To: <1354035684-15802-1-git-send-email-steved@redhat.com>
References: <1354035684-15802-1-git-send-email-steved@redhat.com>
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

