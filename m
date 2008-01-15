From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] text-based mount.nfs: Remove support for mountprog= option
Date: Tue, 15 Jan 2008 12:48:32 -0500
Message-ID: <20080115174832.30730.6466.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57437 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbYAORtJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:49:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel doesn't support the underlying parts needed for changing the
MNT program number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 31df51b..0c8d3e1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -304,9 +304,6 @@ static struct mount_options *rewrite_mount_options(char *str)
 	if (option)
 		mnt_server.pmap.pm_port = atoi(option);
 	mnt_server.pmap.pm_prog = MOUNTPROG;
-	option = po_get(options, "mountprog");
-	if (option)
-		mnt_server.pmap.pm_prog = atoi(option);
 	option = po_get(options, "mountvers");
 	if (option)
 		mnt_server.pmap.pm_vers = atoi(option);

