From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] mount.nfs: Fix "statd not running" error message
Date: Tue, 15 Jan 2008 12:48:11 -0500
Message-ID: <20080115174811.30730.74325.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57041 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbYAORsy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:48:54 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When mount.nfs reports that statd isn't running, it suggests using the "-o
nolocks" option, which doesn't exist.  It should say "-o nolock".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsmount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 23dd2f6..3d2ebb1 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -848,7 +848,7 @@ noauth_flavors:
 		if (!start_statd()) {
 			nfs_error(_("%s: rpc.statd is not running but is "
 				"required for remote locking.\n"
-				"   Either use '-o nolocks' to keep "
+				"   Either use '-o nolock' to keep "
 				"locks local, or start statd."),
 					progname);
 			goto fail;

