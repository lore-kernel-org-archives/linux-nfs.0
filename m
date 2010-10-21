Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47414 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab0JUPDz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 11:03:55 -0400
Received: by mail-yw0-f46.google.com with SMTP id 6so2799132ywi.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 08:03:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] mount.nfs: Fix memory leak in nfs_sys_mount()
To: linux-nfs@vger.kernel.org
Cc: kzak@redhat.com
Date: Thu, 21 Oct 2010 11:03:51 -0400
Message-ID: <20101021150351.2866.208.stgit@ellison.1015granger.net>
In-Reply-To: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
References: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
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
index bcc36f3..e3a25be 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -565,16 +565,18 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
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

