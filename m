From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH] text-based mounts should check statd if "lock" is specified
Date: Mon, 12 May 2008 14:25:19 -0700
Message-ID: <20080512211329.7250.98590.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:38626 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbYELVZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2008 17:25:23 -0400
Received: by py-out-1112.google.com with SMTP id u52so2660072pyb.10
        for <linux-nfs@vger.kernel.org>; Mon, 12 May 2008 14:25:23 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Neil Brown <neilb@suse.de>

Make the text-based mount path check whether statd is running if the "lock"
option is in effect.  This echoes similar logic in the legacy mount path.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

I tried out your patch today, and it caused mounts to fail silently.

As part of the fix, I reversed the return codes for verify_lock_option to
match the other helpers, and added a documenting comment.

Does this look OK?

 utils/mount/stropts.c |   30 ++++++++++++++++++++++++++----
 1 files changed, 26 insertions(+), 4 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cdd610e..fd4be40 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -219,13 +219,33 @@ static int fix_mounthost_option(struct mount_options *options)
 }
 
 /*
+ * Returns zero if the "lock" option is in effect, but statd
+ * can't be started.  Otherwise, returns 1.
+ */
+static int verify_lock_option(struct mount_options *options)
+{
+	if (po_rightmost(options, "nolock", "lock") == PO_KEY1_RIGHTMOST)
+		return 1;
+
+	if (!start_statd()) {
+		nfs_error(_("%s: rpc.statd is not running but is "
+			    "required for remote locking."), progname);
+		nfs_error(_("%s: Either use '-o nolock' to keep "
+			    "locks local, or start statd."), progname);
+		return 0;
+	}
+	return 1;
+}
+
+/*
  * Set up mandatory mount options.
  *
  * Returns 1 if successful; otherwise zero.
  */
-static int set_mandatory_options(const char *type,
-				 struct sockaddr_in *saddr,
-				 struct mount_options *options)
+static int validate_options(const char *type,
+			    struct sockaddr_in *saddr,
+			    struct mount_options *options,
+			    int fake)
 {
 	if (!append_addr_option(saddr, options))
 		return 0;
@@ -236,6 +256,8 @@ static int set_mandatory_options(const char *type,
 	} else {
 		if (!fix_mounthost_option(options))
 			return 0;
+		if (!fake && !verify_lock_option(options))
+			return 0;
 	}
 
 	return 1;
@@ -691,7 +713,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		goto fail;
 	}
 
-	if (!set_mandatory_options(type, &saddr, options))
+	if (!validate_options(type, &saddr, options, fake))
 		goto out;
 
 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)

