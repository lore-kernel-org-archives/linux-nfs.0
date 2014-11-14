Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy9-pub.mail.unifiedlayer.com ([69.89.20.122]:37816 "HELO
	gproxy9-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934097AbaKNSF2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 13:05:28 -0500
To: linux-nfs@vger.kernel.org
From: Henrique Martins <linux@martins.cc>
cc: Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/1] nfsd/exportfs: allow empty exports file
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 14 Nov 2014 10:05:13 -0800
Message-ID: <17903.1415988313@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attaching patch to nfs/exportfs to allow nfsd to start when
/etc/exports is empty, which broke with previous patch
(bugzilla 1115179).

Files changed:
- in export.c/export_read:
    counts the number of good (resolvable) and bad
    (unresolvable) volume entries and generates a (x)log
    L_ERROR if no resolvable entries are exported AND there
    are some unresolvable entries.

Built and tested on a Fedora 20 (fully updated) system.

(And yes, if I need to add the patch inline, my mailer may
screw up the indentation, blanks vs tabs.)

Signed-off-by: Henrique Martins <linux@xxxxxxxxxx>
---

diff -upN nfs-utils-1.3.0/support/export/export.c.orig
nfs-utils-1.3.0/support/export/export.c
--- nfs-utils-1.3.0/support/export/export.c.orig
    2014-11-14 08:46:58.284175535 -0800
+++ nfs-utils-1.3.0/support/export/export.c	2014-11-14
    08:47:52.079349910 -0800
@@ -76,7 +76,8 @@ export_read(char *fname)
 	struct exportent	*eep;
 	nfs_export		*exp;

-	int volumes = 0;
+	int good = 0;
+	int bad = 0;

 	setexportent(fname, "r");
 	while ((eep = getexportent(0,1)) != NULL) {
@@ -84,13 +85,15 @@ export_read(char *fname)
 		if (!exp) {
 			exp = export_create(eep, 0);
 			if (exp)
-				volumes++;
+				good++;
+			else
+				bad++;
 		}
 		else
 			warn_duplicated_exports(exp, eep);
 	}
 	endexportent();
-	if (volumes == 0)
+	if (good == 0 && bad > 0)
 		xlog(L_ERROR, "No file systems exported!");
 }
