Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zep00a03.dent.med.uni-muenchen.de ([138.246.161.8]:55094 "HELO
	md.dent.med.uni-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759578Ab2JLMHN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 08:07:13 -0400
Date: 12 Oct 2012 14:00:30 +0200
Message-ID: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de>
From: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
To: linux-nfs@vger.kernel.org
CC: wmglo@dent.med.uni-muenchen.de
Subject: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the NFS version isn't specified in the mount options, mount.nfs
attempts V4 first and appends 'vers=4' to the extra_options string in
the mount options.  If the server isn't immediately reachable, this
attempt fails.  However, if the background option is specified and the
server comes up later on, the extra_options are used again for all
further attempts and thus they fail if the server only supports
vers<4.

Fix this by only amending extra_options on a successful vers=4 mount.

This is now Debian bug #690181 and has apparently been around for
ages.

Signed-off-by: Wolfram Gloger <bugzilla1@malloc.de>

--- utils/mount/stropts.c.orig	2012-08-23 19:41:56.000000000 +0200
+++ utils/mount/stropts.c	2012-10-11 13:46:25.000000000 +0200
@@ -680,6 +680,7 @@
 {
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
+	char *extra_opts = NULL;
 
 	if (!options) {
 		errno = ENOMEM;
@@ -715,20 +716,26 @@
 		goto out_fail;
 	}
 
-	/*
-	 * Update option string to be recorded in /etc/mtab.
-	 */
-	if (po_join(options, mi->extra_opts) == PO_FAILED) {
+	if (po_join(options, &extra_opts) == PO_FAILED) {
 		errno = ENOMEM;
 		goto out_fail;
 	}
 
 	if (verbose)
 		printf(_("%s: trying text-based options '%s'\n"),
-			progname, *mi->extra_opts);
+			progname, extra_opts);
 
 	result = nfs_sys_mount(mi, options);
 
+	/*
+	 * If success, update option string to be recorded in /etc/mtab.
+	 */
+	if (result) {
+	    free(*mi->extra_opts);
+	    *mi->extra_opts = extra_opts;
+	} else
+	    free(extra_opts);
+
 out_fail:
 	po_destroy(options);
 	return result;
