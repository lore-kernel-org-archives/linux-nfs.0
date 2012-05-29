Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129Ab2E2QEj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 12:04:39 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4TG4dgH009932
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 12:04:39 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q4TG4cBr008653
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 12:04:38 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] Honor the no_root_squash flag on pseudo roots.
Date: Tue, 29 May 2012 12:02:58 -0400
Message-Id: <1338307378-17753-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If root squashing is turned off on a export that
has multiple directories, the parent directories
of the pseudo exports that's built, also needs to
have root squashing turned off.

Signed-off-by: Steve Dickson <steved@redhat.com>
Tested-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/v4root.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 708eb61..726b50d 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -62,6 +62,8 @@ void set_pseudofs_security(struct exportent *pseudo, struct exportent *source)
 
 	if (source->e_flags & NFSEXP_INSECURE_PORT)
 		pseudo->e_flags |= NFSEXP_INSECURE_PORT;
+	if ((source->e_flags & NFSEXP_ROOTSQUASH) == 0)
+		pseudo->e_flags &= ~NFSEXP_ROOTSQUASH;
 	for (se = source->e_secinfo; se->flav; se++) {
 		struct sec_entry *new;
 
@@ -92,7 +94,8 @@ v4root_create(char *path, nfs_export *export)
 	exp = export_create(&eep, 0);
 	if (exp == NULL)
 		return NULL;
-	xlog(D_CALL, "v4root_create: path '%s'", exp->m_export.e_path);
+	xlog(D_CALL, "v4root_create: path '%s' flags 0x%x", 
+		exp->m_export.e_path, exp->m_export.e_flags);
 	return &exp->m_export;
 }
 
-- 
1.7.7.6

