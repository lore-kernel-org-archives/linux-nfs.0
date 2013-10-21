Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f49.google.com ([209.85.128.49]:51471 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab3JUNrP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 09:47:15 -0400
Received: by mail-qe0-f49.google.com with SMTP id a11so3773918qen.36
        for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 06:47:14 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, edoutreleau@genoscope.cns.fr
Subject: [PATCH] mount.nfs: print an error message when remount attempt fails
Date: Mon, 21 Oct 2013 09:47:09 -0400
Message-Id: <1382363229-6343-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, mount.nfs returns an error code, but doesn't print anything
when this occurs.

Reported-by: Eric Doutreleau <edoutreleau@genoscope.cns.fr>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/stropts.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 1dc38ef..a642394 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -1004,6 +1004,7 @@ static int nfs_remount(struct nfsmount_info *mi)
 {
 	if (nfs_sys_mount(mi, mi->options))
 		return EX_SUCCESS;
+	mount_error(mi->spec, mi->node, errno);
 	return EX_FAIL;
 }
 
-- 
1.8.3.1

