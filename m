Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbbFYORe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2015 10:17:34 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 6E23E319815
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 14:17:34 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-56-13.rdu2.redhat.com [10.10.56.13])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5PEHWdF027266
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 10:17:33 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] mount.nfs manpage: Add nfsmount.conf
Date: Thu, 25 Jun 2015 10:17:31 -0400
Message-Id: <1435241851-24530-2-git-send-email-steved@redhat.com>
In-Reply-To: <1435241851-24530-1-git-send-email-steved@redhat.com>
References: <1435241851-24530-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add nfsmount.conf to both the FILES and SEE ALSO
sections

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/mount.nfs.man | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
index 15a82d5..0409c96 100644
--- a/utils/mount/mount.nfs.man
+++ b/utils/mount/mount.nfs.man
@@ -80,10 +80,13 @@ file system table
 .TP
 .I /etc/mtab
 table of mounted file systems
-
+.TP
+.I /etc/nfsmount.conf
+Configuration file for NFS mounts
 .PD
 .SH "SEE ALSO"
 .BR nfs (5),
+.BR nfsmount.conf (5),
 .BR mount (8),
 
 .SH "AUTHOR"
-- 
2.4.3

