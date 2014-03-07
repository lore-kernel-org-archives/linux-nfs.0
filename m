Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880AbaCGPEq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 10:04:46 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s27F4kEf028620
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 7 Mar 2014 10:04:46 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-54-164.rdu2.redhat.com [10.10.54.164])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s27F4j6e030724
	for <linux-nfs@vger.kernel.org>; Fri, 7 Mar 2014 10:04:45 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Ensure parent mount of background mounts timeout
Date: Fri,  7 Mar 2014 10:04:44 -0500
Message-Id: <1394204684-1283-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With a proposed kernel fixed, the parent mounts of
background mounts do not time out for over 5 mins.

This patch will append "retrans=1,timeo=100" to
the mount options (when they don't exist) causing
the parent mount to time out in ~25secs

The options are then removed (if they were added)
before the child mount, in background, is done

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a642394..417d022 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -921,6 +921,14 @@ static int nfsmount_fg(struct nfsmount_info *mi)
  */
 static int nfsmount_parent(struct nfsmount_info *mi)
 {
+	po_return_t retrans, timeo;
+
+	if (po_contains(mi->options, "retrans") == PO_NOT_FOUND)
+		retrans = po_append(mi->options, "retrans=1");
+
+	if (po_contains(mi->options, "timeo") == PO_NOT_FOUND)
+		timeo = po_append(mi->options, "timeo=100"); /* ~25 secs */
+
 	if (nfs_try_mount(mi))
 		return EX_SUCCESS;
 
@@ -929,6 +937,10 @@ static int nfsmount_parent(struct nfsmount_info *mi)
 		mount_error(mi->spec, mi->node, errno);
 		return EX_FAIL;
 	}
+	if (retrans == PO_SUCCEEDED)
+		po_remove_all(mi->options, "retrans");
+	if (timeo == PO_SUCCEEDED)
+		po_remove_all(mi->options, "timeo");
 
 	sys_mount_errors(mi->hostname, errno, 1, 1);
 	return EX_BG;
-- 
1.7.1

