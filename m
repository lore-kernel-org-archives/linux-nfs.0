Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:43675 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754923Ab2BCBmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 20:42:43 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 2 Feb 2012 18:42:43 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E52433E40049
	for <linux-nfs@vger.kernel.org>; Thu,  2 Feb 2012 18:42:16 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q131gGVN131298
	for <linux-nfs@vger.kernel.org>; Thu, 2 Feb 2012 18:42:16 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q131gGS7010867
	for <linux-nfs@vger.kernel.org>; Thu, 2 Feb 2012 18:42:16 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q131gGkd010859
	for <linux-nfs@vger.kernel.org>; Thu, 2 Feb 2012 18:42:16 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Check for beginning '/' in the mount path
Date: Thu,  2 Feb 2012 19:42:12 -0600
Message-Id: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 gladly accepts and mounts "hostname:path" instead of
"hostname:/path". This causes mount entry mistmatch between /etc/mtab
and /proc/mounts files. The former will have "hostname:path" but the
latter will have "hostname:/path". This causes umount not work at all.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 utils/mount/stropts.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d52e21a..559114d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -571,6 +571,7 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
 {
 	char *options = NULL;
 	int result;
+	char *dirname;
 
 	if (mi->fake)
 		return 1;
@@ -580,6 +581,27 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
 		return 0;
 	}
 
+	/*
+	 * Make sure that dirname in the spec starts with '/'. The mount
+	 * works fine in NFSv4 without the '/', but then /etc/mtab and
+	 * /proc/mounts disagree on the actual mount entry causing later
+	 * umount to fail! There is no reason to allow any dirname not
+	 * starting with '/', so fail it here.
+	 *
+	 * Note that for NFSv2 and NFSv3, the mount call itself fails if
+	 * dirname doesn't start with '/'. So this check is only useful
+	 * for NFSv4.
+	 */
+	dirname = strchr(mi->spec, ']');	/* IPv6 address check */
+	if (dirname)
+		dirname = strchr(dirname+1, ':');
+	else
+		dirname = strchr(mi->spec, ':');
+	if (!dirname || *(dirname+1) != '/') {
+		errno = EINVAL;
+		return 0;
+	}
+
 	result = mount(mi->spec, mi->node, mi->type,
 			mi->flags & ~(MS_USER|MS_USERS), options);
 	free(options);
-- 
1.7.8.3

