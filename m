From: Jindrich Makovicka <makovick@gmail.com>
Subject: [PATCH] nfsmount segfault fix
Date: Sat, 23 Feb 2008 16:33:43 +0100
Message-ID: <20080223163343.43f8197d@holly>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/ohKrmqAQThk9mTpQTHuqUoT"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:51640 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbYBWPkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Feb 2008 10:40:06 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JSwTq-0004Ng-TM
	for linux-nfs@vger.kernel.org; Sat, 23 Feb 2008 15:40:02 +0000
Received: from 82.208.33.94 ([82.208.33.94])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 23 Feb 2008 15:40:02 +0000
Received: from makovick by 82.208.33.94 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 23 Feb 2008 15:40:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/ohKrmqAQThk9mTpQTHuqUoT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In current nfsmount, two tests of the mount result version are out of
sync. The test in nfs_call_mount() tests the mnt_server->pmap.pm_vers to
decide what mount function (v2 or v3) to call, but later in nfsmount(),
(nfs_pmap->pm_vers == 2) condition is used to decide about the result
format, which is wrong. The result then can be misinterpreted, causing
a segfault, when mnt_pmap->pm_vers==2 and nfs_pmap->pm_vers>2, and
nfsmount tries to read the auth flavors.

Trivial fix is attached.

Regards,
-- 
Jindrich Makovicka

--MP_/ohKrmqAQThk9mTpQTHuqUoT
Content-Type: text/x-patch; name=nfsmount.c.diff
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=nfsmount.c.diff

--- nfsmount.c.orig	2007-10-19 05:07:28.000000000 +0200
+++ nfsmount.c	2008-02-15 23:43:32.000000000 +0100
@@ -714,7 +714,7 @@
 			rpc_mount_errors(*nfs_server.hostname, 1, bg);
 	}
 
-	if (nfs_pmap->pm_vers == 2) {
+	if (mnt_pmap->pm_vers <= 2) {
 		if (mntres.nfsv2.fhs_status != 0) {
 			nfs_error(_("%s: %s:%s failed, reason given by server: %s"),
 					progname, hostname, dirname,

--MP_/ohKrmqAQThk9mTpQTHuqUoT--


