Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34768 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbaDMNMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 09:12:46 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so7098181pdi.2
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 06:12:45 -0700 (PDT)
Message-ID: <534A8D29.5070101@gmail.com>
Date: Sun, 13 Apr 2014 21:12:09 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: Cleanup unused comments and codes in summarize_posix_acl
References: <534A897E.10303@gmail.com>
In-Reply-To: <534A897E.10303@gmail.com>
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

