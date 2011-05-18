Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932995Ab1ERQsR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 12:48:17 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p4IGmGZ4002787
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 18 May 2011 12:48:16 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p4IGmGVd016388
	for <linux-nfs@vger.kernel.org>; Wed, 18 May 2011 12:48:16 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Removed compilation warnings from mountd/cache.c (take 2)
Date: Wed, 18 May 2011 12:48:15 -0400
Message-Id: <1305737295-19559-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Jim Rees <rees@umich.edu>

Commit 5604b35a6 introduced a number of missing initializer
warnings that were missed. This patch removes those warnings.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index df6b38f..0c4a03d 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -827,11 +827,11 @@ struct {
 	FILE *f;
 	char vbuf[RPC_CHAN_BUF_SIZE];
 } cachelist[] = {
-	{ "auth.unix.ip", auth_unix_ip, NULL},
-	{ "auth.unix.gid", auth_unix_gid, NULL},
-	{ "nfsd.export", nfsd_export, NULL},
-	{ "nfsd.fh", nfsd_fh, NULL},
-	{ NULL, NULL, NULL }
+	{ "auth.unix.ip", auth_unix_ip, NULL, ""},
+	{ "auth.unix.gid", auth_unix_gid, NULL, ""},
+	{ "nfsd.export", nfsd_export, NULL, ""},
+	{ "nfsd.fh", nfsd_fh, NULL, ""},
+	{ NULL, NULL, NULL, ""}
 };
 
 extern int manage_gids;
-- 
1.7.5.1

