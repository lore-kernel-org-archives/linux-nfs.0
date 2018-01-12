Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754273AbeALFsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Jan 2018 00:48:04 -0500
From: "Jianhong.Yin" <yin-jianhong@163.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] exportfs: move ro/rw option back to secinfo_flag_displaymap table
Date: Fri, 12 Jan 2018 13:47:57 +0800
Message-Id: <20180112054757.23927-1-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

according https://bugzilla.redhat.com/show_bug.cgi?id=1532688#c3
ro/rw options should be in secinfo_flag_displaymap[]

test pass:
'''
[yjh@test ~]$ cat /etc/exports
/export_test    127.0.0.1(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,root_squash,all_squash,sec=krb5,ro,root_squash,no_all_squash,sec=krb5i,rw,root_squash,no_all_squash,sec=krb5p,no_root_squash,no_all_squash)
[yjh@test ~]$ sudo service nfs restart
Redirecting to /bin/systemctl restart nfs.service
[yjh@test ~]$ sudo exportfs -v
/export_test    127.0.0.1(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,all_squash,sec=krb5,ro,secure,root_squash,no_all_squash,sec=krb5i,rw,secure,root_squash,no_all_squash,sec=krb5p,rw,secure,no_root_squash,no_all_squash)
'''

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 support/nfs/exports.c     | 1 +
 utils/exportfs/exportfs.c | 4 ----
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 92bd6e6..b59d187 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -197,6 +197,7 @@ static const struct secinfo_flag_displaymap {
 	const char *set;
 	const char *unset;
 } secinfo_flag_displaymap[] = {
+	{ NFSEXP_READONLY, "ro", "rw" },
 	{ NFSEXP_INSECURE_PORT, "insecure", "secure" },
 	{ NFSEXP_ROOTSQUASH, "root_squash", "no_root_squash" },
 	{ NFSEXP_ALLSQUASH, "all_squash", "no_all_squash" },
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 448f195..cd3c979 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -695,10 +695,6 @@ dump(int verbose, int export_format)
 				continue;
 			}
 			c = '(';
-			if (ep->e_flags & NFSEXP_READONLY)
-				c = dumpopt(c, "ro");
-			else
-				c = dumpopt(c, "rw");
 			if (ep->e_flags & NFSEXP_ASYNC)
 				c = dumpopt(c, "async");
 			else
-- 
2.14.3

