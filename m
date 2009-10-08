From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] mount.nfs: Assume v2/v3 if mount-related options are
	present
Date: Thu, 08 Oct 2009 13:37:12 -0400
Message-ID: <20091008173712.12619.45807.stgit@matisse.1015granger.net>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:36184 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858AbZJHRjP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2009 13:39:15 -0400
In-Reply-To: <20091008173520.12619.10662.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't try NFSv4 if any MNT protocol related options were presented by
the user.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0685caa..3401f63 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -564,6 +564,13 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 	}
 
 	if (mi->version == 0) {
+		if (po_contains(options, "mounthost") ||
+		    po_contains(options, "mountaddr") ||
+		    po_contains(options, "mountvers") ||
+		    po_contains(options, "mountproto")) {
+			errno = EPROTONOSUPPORT;
+			goto out_fail;
+		}
 		if (po_append(options, "vers=4") == PO_FAILED) {
 			errno = EINVAL;
 			goto out_fail;

