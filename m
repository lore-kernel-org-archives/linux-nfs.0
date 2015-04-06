Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807AbbDFOeb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Apr 2015 10:34:31 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t36EYUk8014509
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 6 Apr 2015 10:34:30 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-53-4.rdu2.redhat.com [10.10.53.4])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t36EYTZD029999
	for <linux-nfs@vger.kernel.org>; Mon, 6 Apr 2015 10:34:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] exportfs: Missing comma in pnfs options
Date: Mon,  6 Apr 2015 10:34:27 -0400
Message-Id: <1428330867-10655-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kelly Anderson <kelly@xilka.com>

Fix a missing comma in pnfs which get's written to etab,
and then nfs-mountd sees an invalid option.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/exports.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 9b325b9..761a046 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -275,7 +275,7 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
 		fprintf(fp, "nordirplus,");
-	fprintf(fp, "%spnfs", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
+	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
-- 
2.1.0

