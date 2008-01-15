From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] text-based mount.nfs: Remove support for nfsprog= option
Date: Tue, 15 Jan 2008 12:48:27 -0500
Message-ID: <20080115174827.30730.77863.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57172 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbYAORs7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:48:59 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel hasn't supported the underlying parts needed for changing the
NFS program number for a very long time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cf40313..31df51b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -317,9 +317,6 @@ static struct mount_options *rewrite_mount_options(char *str)
 		po_remove_all(options, "port");
 	}
 	nfs_server.pmap.pm_prog = NFS_PROGRAM;
-	option = po_get(options, "nfsprog");
-	if (option)
-		nfs_server.pmap.pm_prog = atoi(option);
 
 	option = po_get(options, "nfsvers");
 	if (option) {

