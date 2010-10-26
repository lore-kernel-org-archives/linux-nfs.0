Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53668 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab0JZP6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:58:19 -0400
Received: by mail-iw0-f174.google.com with SMTP id 10so2336058iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:58:19 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] mount.nfs: Fix memory leak in nfs_sys_mount()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:58:15 -0400
Message-ID: <20101026155815.19184.4156.stgit@matisse.1015granger.net>
In-Reply-To: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This appears to have been left behind by last year's adjustments to
how the extra_opts string is constructed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 29b1aaa..ac81616 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -568,16 +568,18 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
 	char *options = NULL;
 	int result;
 
+	if (mi->fake)
+		return 1;
+
 	if (po_join(opts, &options) == PO_FAILED) {
 		errno = EIO;
 		return 0;
 	}
 
-	if (mi->fake)
-		return 1;
-
 	result = mount(mi->spec, mi->node, mi->type,
 			mi->flags & ~(MS_USER|MS_USERS), options);
+	free(options);
+
 	if (verbose && result) {
 		int save = errno;
 		nfs_error(_("%s: mount(2): %s"), progname, strerror(save));

