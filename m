Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54242 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751495AbcKRI6w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 03:58:52 -0500
From: "Jianhong.Yin" <yin-jianhong@163.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] nfs-utils: exportfs remove redundant exports options output
Date: Fri, 18 Nov 2016 16:58:43 +0800
Message-Id: <1479459523-7649-1-git-send-email-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

before this commit, run 'exportfs -s' will output some
 options more than one time. for example:
 /path *(rw,no_root_squash,rw,secure,no_root_squash,no_all_squash)
 the options rw,no_root_squash,etc will be print twice.
the reason is secinfo_show() will show these security options again
this patch remove these redundant outputs.

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 utils/exportfs/exportfs.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 98368a5..b11f06b 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -747,26 +747,20 @@ dump(int verbose, int export_format)
 				continue;
 			}
 			c = '(';
-			if (ep->e_flags & NFSEXP_READONLY)
-				c = dumpopt(c, "ro");
-			else
-				c = dumpopt(c, "rw");
 			if (ep->e_flags & NFSEXP_ASYNC)
 				c = dumpopt(c, "async");
+			else
+				c = dumpopt(c, "sync");
 			if (ep->e_flags & NFSEXP_GATHERED_WRITES)
 				c = dumpopt(c, "wdelay");
+			else
+				c = dumpopt(c, "no_wdelay");
 			if (ep->e_flags & NFSEXP_NOHIDE)
 				c = dumpopt(c, "nohide");
+			else
+				c = dumpopt(c, "hide");
 			if (ep->e_flags & NFSEXP_CROSSMOUNT)
 				c = dumpopt(c, "crossmnt");
-			if (ep->e_flags & NFSEXP_INSECURE_PORT)
-				c = dumpopt(c, "insecure");
-			if (ep->e_flags & NFSEXP_ROOTSQUASH)
-				c = dumpopt(c, "root_squash");
-			else
-				c = dumpopt(c, "no_root_squash");
-			if (ep->e_flags & NFSEXP_ALLSQUASH)
-				c = dumpopt(c, "all_squash");
 			if (ep->e_flags & NFSEXP_NOSUBTREECHECK)
 				c = dumpopt(c, "no_subtree_check");
 			if (ep->e_flags & NFSEXP_NOAUTHNLM)
-- 
2.5.5

