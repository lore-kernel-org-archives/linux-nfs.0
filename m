Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:46059 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab0IMRRw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:17:52 -0400
Received: by pzk34 with SMTP id 34so2219981pzk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:17:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] mount.nfs: Don't do anything fancy if this is a remount
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:17:47 -0400
Message-ID: <20100913171747.18926.89540.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171100.18926.77712.stgit@seurat.1015granger.net>
References: <20100913171100.18926.77712.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We don't want to append "vers=4" or perform any negotiation if the
"remount" mount option was specified.  It will just end in tears.

This attempts to address

  https://qa.mandriva.com/show_bug.cgi?id=60311

and

  https://bugzilla.linux-nfs.org/show_bug.cgi?id=187

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c5c4ba1..50a1a2a 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -967,6 +967,26 @@ static int nfsmount_bg(struct nfsmount_info *mi)
 }
 
 /*
+ * Usually all that is needed for an NFS remount is to change
+ * generic mount options like "sync" or "ro".  These generic
+ * options are controlled by mi->flags, not by text-based
+ * options, and no contact with the server is needed.
+ *
+ * Take care with the /etc/mtab entry for this mount; just
+ * calling update_mtab() will change an "-t nfs -o vers=4"
+ * mount to an "-t nfs -o remount" mount, and that will
+ * confuse umount.nfs.
+ *
+ * Returns a valid mount command exit code.
+ */
+static int nfs_remount(struct nfsmount_info *mi)
+{
+	if (nfs_sys_mount(mi, mi->options))
+		return EX_SUCCESS;
+	return EX_FAIL;
+}
+
+/*
  * Process mount options and try a mount system call.
  *
  * Returns a valid mount command exit code.
@@ -982,6 +1002,12 @@ static int nfsmount_start(struct nfsmount_info *mi)
 	if (!nfs_validate_options(mi))
 		return EX_FAIL;
 
+	/*
+	 * Avoid retry and negotiation logic when remounting
+	 */
+	if (mi->flags & MS_REMOUNT)
+		return nfs_remount(mi);
+
 	if (po_rightmost(mi->options, nfs_background_opttbl) == 0)
 		return nfsmount_bg(mi);
 	else
@@ -998,6 +1024,8 @@ static int nfsmount_start(struct nfsmount_info *mi)
  *		(input and output argument)
  * @fake: flag indicating whether to carry out the whole operation
  * @child: one if this is a mount daemon (bg)
+ *
+ * Returns a valid mount command exit code.
  */
 int nfsmount_string(const char *spec, const char *node, const char *type,
 		    int flags, char **extra_opts, int fake, int child)

