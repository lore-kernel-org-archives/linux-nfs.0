Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59624 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab0IMRVz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:21:55 -0400
Received: by iwn5 with SMTP id 5so5307707iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:21:55 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/12] mountd: Add mountlist_freeall()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:21:40 -0400
Message-ID: <20100913172140.19017.17536.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm about to add a second bit of logic that needs to free all
mountlist records, so introduce a helper for freeing them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/rmtab.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index b2c04e7..854d519 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -173,6 +173,18 @@ out_unlock:
 	xfunlock(lockid);
 }
 
+static void
+mountlist_freeall(mountlist list)
+{
+	while (list != NULL) {
+		mountlist m = list;
+		list = m->ml_next;
+		xfree(m->ml_hostname);
+		xfree(m->ml_directory);
+		xfree(m);
+	}
+}
+
 mountlist
 mountlist_list(void)
 {
@@ -194,12 +206,7 @@ mountlist_list(void)
 		return NULL;
 	}
 	if (stb.st_mtime != last_mtime) {
-		while (mlist) {
-			mlist = (m = mlist)->ml_next;
-			xfree(m->ml_hostname);
-			xfree(m->ml_directory);
-			xfree(m);
-		}
+		mountlist_freeall(mlist);
 		last_mtime = stb.st_mtime;
 
 		setrmtabent("r");

