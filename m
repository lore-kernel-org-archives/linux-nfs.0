From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] text-based mount command: check if statd is running if
	"lock" is in effect.
Date: Thu, 22 May 2008 12:10:56 -0400
Message-ID: <20080522161056.3044.17828.stgit@ellison.1015granger.net>
References: <20080522160457.3044.16441.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41249 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224AbYEVQMd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2008 12:12:33 -0400
In-Reply-To: <20080522160457.3044.16441.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Neil Brown <neilb@suse.de>

Make the text-based mount path check whether statd is running if the "lock"
option is in effect.  This echoes similar logic in the legacy mount path.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   31 +++++++++++++++++++++++++++----
 1 files changed, 27 insertions(+), 4 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cdd610e..b2b56be 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -219,13 +219,34 @@ static int fix_mounthost_option(struct mount_options *options)
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
+
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
@@ -236,6 +257,8 @@ static int set_mandatory_options(const char *type,
 	} else {
 		if (!fix_mounthost_option(options))
 			return 0;
+		if (!fake && !verify_lock_option(options))
+			return 0;
 	}
 
 	return 1;
@@ -691,7 +714,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		goto fail;
 	}
 
-	if (!set_mandatory_options(type, &saddr, options))
+	if (!validate_options(type, &saddr, options, fake))
 		goto out;
 
 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)

