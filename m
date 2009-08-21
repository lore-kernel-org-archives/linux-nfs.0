From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Handle a zero-length auth flavor list
Date: Fri, 21 Aug 2009 17:50:30 -0400
Message-ID: <20090821215006.28834.73753.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:37197
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932716AbZHUXiq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 19:38:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some releases of Linux rpc.mountd (nfs-utils 1.1.4 and later) return an
empty auth flavor list if no sec= was specified for the export.  This is
notably broken server behavior.

The new auth flavor list checking added in a recent commit rejects this
case.  The OpenSolaris client does too.

The broken mountd implementation is already widely deployed.  To avoid
a behavioral regression, the kernel's mount client skips flavor checking
(ie reverts to the pre-2.6.32 behavior) if mountd returns an empty
flavor list.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Trond-

First proposal to address the empty flavor list regression.

 fs/nfs/super.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9c85cdb..f3a95df 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1338,6 +1338,16 @@ static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
 	unsigned int i, j, server_authlist_len = *(request->auth_flav_len);
 
 	/*
+	 * Certain releases of Linux's mountd return an empty
+	 * flavor list.  To prevent behavioral regression with
+	 * these servers (ie. rejecting mounts that used to
+	 * succeed), revert to pre-2.6.32 behavior (no checking)
+	 * if the returned flavor list is empty.
+	 */
+	if (server_authlist_len == 0)
+		return 0;
+
+	/*
 	 * We avoid sophisticated negotiating here, as there are
 	 * plenty of cases where we can get it wrong, providing
 	 * either too little or too much security.

