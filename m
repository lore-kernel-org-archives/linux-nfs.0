Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f42.google.com ([209.85.160.42]:43970 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbaDMM44 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 08:56:56 -0400
Received: by mail-pb0-f42.google.com with SMTP id rr13so7245270pbb.15
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 05:56:55 -0700 (PDT)
Message-ID: <534A897E.10303@gmail.com>
Date: Sun, 13 Apr 2014 20:56:30 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSD: Cleanup unused comments and codes in summarize_posix_acl
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4acl.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 6f3f392..de5d66b 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -193,16 +193,9 @@ summarize_posix_acl(struct posix_acl *acl, struct
posix_acl_summary *pas)
 {
 	struct posix_acl_entry *pa, *pe;

-	/*
-	 * Only pas.users and pas.groups need initialization; previous
-	 * posix_acl_valid() calls ensure that the other fields will be
-	 * initialized in the following loop.  But, just to placate gcc:
-	 */
 	memset(pas, 0, sizeof(*pas));
 	pas->mask = 07;

-	pe = acl->a_entries + acl->a_count;
-
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch (pa->e_tag) {
 			case ACL_USER_OBJ:
-- 
1.9.0

