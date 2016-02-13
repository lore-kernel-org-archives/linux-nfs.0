Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbcBMMyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Feb 2016 07:54:33 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 6164014A81
	for <linux-nfs@vger.kernel.org>; Sat, 13 Feb 2016 12:54:33 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-56-162.rdu2.redhat.com [10.10.56.162])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1DCsWPb014005
	for <linux-nfs@vger.kernel.org>; Sat, 13 Feb 2016 07:54:32 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsidmapd: allow the usage message to be displayed
Date: Sat, 13 Feb 2016 07:54:31 -0500
Message-Id: <1455368071-15198-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xlog_err() never returns. Change the xlog_err(),
when invalid arguments are use, to xlog_warn()
so the second xlog_warn, displaying the usage,
will be called.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index d980c68..2abefe9 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -430,7 +430,7 @@ int main(int argc, char **argv)
 
 	xlog_stderr(verbose);
 	if ((argc - optind) != 2) {
-		xlog_err("Bad arg count. Check /etc/request-key.conf");
+		xlog_warn("Bad arg count. Check /etc/request-key.conf");
 		xlog_warn(usage, progname);
 		return EXIT_FAILURE;
 	}
-- 
2.5.0

