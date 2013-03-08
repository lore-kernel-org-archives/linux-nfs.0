Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39797 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab3CHTqP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:15 -0500
Received: by mail-ie0-f174.google.com with SMTP id k10so2503181iea.5
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:14 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/11] mountd: remove unused variable
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:46:12 -0500
Message-ID: <20130308194612.5656.52628.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:

Making all in mountd
cache.c: In function ‘subexport’:
cache.c:374:9: warning: unused variable ‘l2’ [-Wunused-variable]

Commit 8e2fb3fc removed the last use of "l2" in the subexport()
function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 45012be..c8aa46f 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -371,8 +371,6 @@ export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
 static bool subexport(struct exportent *e1, struct exportent *e2)
 {
 	char *p1 = e1->e_path, *p2 = e2->e_path;
-	size_t l2 = strlen(p2);
-
 	return e2->e_flags & NFSEXP_CROSSMOUNT
 		&& is_subdirectory(p1, p2);
 }

