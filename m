Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbbFYORd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2015 10:17:33 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id B78E0C131B
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 14:17:33 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-56-13.rdu2.redhat.com [10.10.56.13])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5PEHWdE027266
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 10:17:33 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfs manpage: Add nfsmount.conf
Date: Thu, 25 Jun 2015 10:17:30 -0400
Message-Id: <1435241851-24530-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add nfsmount.conf to both the FILES and SEE ALSO
sections

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfs.man | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index fe4f9b1..e541cdc 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1706,6 +1706,9 @@ with the mount options already saved on disk for the NFS server mounted at /mnt.
 .TP 1.5i
 .I /etc/fstab
 file system table
+.TP 1.5i
+.I /etc/nfsmount.conf
+Configuration file for NFS mounts
 .SH BUGS
 Before 2.4.7, the Linux NFS client did not support NFS over TCP.
 .P
@@ -1735,6 +1738,7 @@ such as security negotiation, server referrals, and named attributes.
 .BR mount.nfs (5),
 .BR umount.nfs (5),
 .BR exports (5),
+.BR nfsmount.conf (5),
 .BR netconfig (5),
 .BR ipv6 (7),
 .BR nfsd (8),
-- 
2.4.3

