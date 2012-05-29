Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:46042 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750980Ab2E2NcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 09:32:06 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1SZM6A-0007Yw-DF
	for linux-nfs@vger.kernel.org; Tue, 29 May 2012 09:04:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] Honor the no_root_squash flag on pseudo roots.
Date: Tue, 29 May 2012 09:07:16 -0400
Message-Id: <1338296836-28243-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If root squashing is turned off on a export that
has multiple directories, the parent directories
of the pseudo exports that's built, also needs to
have root squashing turned off.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/v4root.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 708eb61..ad8a3e7 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -92,7 +92,14 @@ v4root_create(char *path, nfs_export *export)
 	exp = export_create(&eep, 0);
 	if (exp == NULL)
 		return NULL;
-	xlog(D_CALL, "v4root_create: path '%s'", exp->m_export.e_path);
+	/*
+	 * Honor the no_root_squash flag 
+	 */
+	if ((curexp->e_flags & NFSEXP_ROOTSQUASH) == 0)
+		exp->m_export.e_flags &= ~NFSEXP_ROOTSQUASH;
+	xlog(D_CALL, "v4root_create: path '%s' flags 0x%x", 
+		exp->m_export.e_path, exp->m_export.e_flags);
+
 	return &exp->m_export;
 }
 
-- 
1.7.7.6

