Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54871 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbcDFNli (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2016 09:41:38 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 21825B5A4
	for <linux-nfs@vger.kernel.org>; Wed,  6 Apr 2016 13:41:37 +0000 (UTC)
From: Benjamin Coddington <bcodding@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [RFC PATCH] mount.nfs: skip option validation on remount
Date: Wed,  6 Apr 2016 09:41:36 -0400
Message-Id: <712798c489f69e39f235077f6ca85a7c133eeb58.1459949813.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not exactly sure this is the safest thing to do since you can pass
-oremount on the first mount and skip option validation.  Maybe someone with
better insight into the mount paths could comment.  Does mount need some
refactoring?  Its logic seems arcane.. and I think there is a lot of dead
code.

This is very quick attempt to fix
https://bugzilla.redhat.com/show_bug.cgi?id=1313550

8<-------------------------------------------------------------------------

A remount might fail if name resolution returns a different server address
for the mount.  Since we've already validated the options the first time,
skip validation if remounting.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/stropts.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 86829a9..9383bb4 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -1090,15 +1090,15 @@ static const char *nfs_background_opttbl[] = {
 
 static int nfsmount_start(struct nfsmount_info *mi)
 {
-	if (!nfs_validate_options(mi))
-		return EX_FAIL;
-
 	/*
 	 * Avoid retry and negotiation logic when remounting
 	 */
 	if (mi->flags & MS_REMOUNT)
 		return nfs_remount(mi);
 
+	if (!nfs_validate_options(mi))
+		return EX_FAIL;
+
 	if (po_rightmost(mi->options, nfs_background_opttbl) == 0)
 		return nfsmount_bg(mi);
 	else
-- 
1.7.1

