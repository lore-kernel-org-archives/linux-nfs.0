Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35483 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab2ADT5A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 14:57:00 -0500
Received: by mail-vx0-f174.google.com with SMTP id fk14so13490667vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2012 11:57:00 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] mountd: Plug v4root memory leak
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 14:56:58 -0500
Message-ID: <20120104195658.21904.84311.stgit@degas.1015granger.net>
In-Reply-To: <20120104194136.21904.36616.stgit@degas.1015granger.net>
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Valgrind reports that the memory allocated for eep's e_hostname field
was not being freed.  eep is not visible outside of v4root_create(),
so we don't need to strdup() that string.

Introduced by commit 3b777b0 "exports: NFSv4 pseudoroot support
routines" (Dec 1, 2009).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/v4root.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index c33a5a9..81f813b 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -83,7 +83,7 @@ v4root_create(char *path, nfs_export *export)
 	struct exportent *curexp = &export->m_export;
 
 	dupexportent(&eep, &pseudo_root.m_export);
-	eep.e_hostname = strdup(curexp->e_hostname);
+	eep.e_hostname = curexp->e_hostname;
 	strncpy(eep.e_path, path, sizeof(eep.e_path));
 	if (strcmp(path, "/") != 0)
 		eep.e_flags &= ~NFSEXP_FSID;

