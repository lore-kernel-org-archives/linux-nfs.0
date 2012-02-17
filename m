Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755Ab2BQOxB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 09:53:01 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q1HEr07j001648
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2012 09:53:00 -0500
Message-ID: <1329490378.3976.31.camel@serendib>
Subject: [PATCH] nfs-utils: exports man page: no_acl is not supported
From: Harshula Jayasuriya <harshula@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: Bruce Fields <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Sat, 18 Feb 2012 01:52:58 +1100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The inclusion of no_acl in the exports man page is confusing since it is
not actually supported (v3.3-rc3):

1090 static struct flags {
1091         int flag;
1092         char *name[2];
1093 } expflags[] = {
1094         { NFSEXP_READONLY, {"ro", "rw"}},
1095         { NFSEXP_INSECURE_PORT, {"insecure", ""}},
1096         { NFSEXP_ROOTSQUASH, {"root_squash", "no_root_squash"}},
1097         { NFSEXP_ALLSQUASH, {"all_squash", ""}},
1098         { NFSEXP_ASYNC, {"async", "sync"}},
1099         { NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
1100         { NFSEXP_NOHIDE, {"nohide", ""}},
1101         { NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
1102         { NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
1103         { NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
1104         { NFSEXP_V4ROOT, {"v4root", ""}},
1105         { 0, {"", ""}}
1106 };

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Acked-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/exportfs/exports.man |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 54adfeb..bc1de73 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -293,24 +293,6 @@ be explicitly requested with either of the synonymous
 .IR auth_nlm ,
 or
 .IR secure_locks .
-.TP
-.IR no_acl
-On some specially patched kernels, and when exporting filesystems that
-support ACLs, this option tells
-.B nfsd
-not to reveal ACLs to clients, so
-they will see only a subset of actual permissions on the given file
-system.  This option is safe for filesystems used by NFSv2 clients and
-old NFSv3 clients that perform access decisions locally.  Current
-NFSv3 clients use the ACCESS RPC to perform all access decisions on
-the server.  Note that the
-.I no_acl
-option only has effect on kernels specially patched to support it, and
-when exporting filesystems with ACL support.  The default is to export
-with ACL support (i.e. by default,
-.I no_acl
-is off).
-
 .\".TP
 .\".I noaccess
 .\"This makes everything below the directory inaccessible for the named
-- 
1.7.7.6

