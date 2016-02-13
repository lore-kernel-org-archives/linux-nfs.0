Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050AbcBMMmM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Feb 2016 07:42:12 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id E30DB804FE
	for <linux-nfs@vger.kernel.org>; Sat, 13 Feb 2016 12:42:11 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-56-162.rdu2.redhat.com [10.10.56.162])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1DCgBwo021234
	for <linux-nfs@vger.kernel.org>; Sat, 13 Feb 2016 07:42:11 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsidmapd: Let verbose determent whether stderr logging should be done
Date: Sat, 13 Feb 2016 07:42:10 -0500
Message-Id: <1455367330-14781-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the verbose command flag to turn on or off
logging to stderr.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 15b4a51..d980c68 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -428,7 +428,7 @@ int main(int argc, char **argv)
 		return keyring_clear(DEFAULT_KEYRING);
 	}
 
-	xlog_stderr(0);
+	xlog_stderr(verbose);
 	if ((argc - optind) != 2) {
 		xlog_err("Bad arg count. Check /etc/request-key.conf");
 		xlog_warn(usage, progname);
-- 
2.5.0

