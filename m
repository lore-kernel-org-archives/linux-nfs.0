Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48458 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178Ab0IZSsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Sep 2010 14:48:13 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1OzwF7-0000kt-0q
	for linux-nfs@vger.kernel.org; Sun, 26 Sep 2010 14:46:33 -0400
Date: Sun, 26 Sep 2010 14:46:32 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix /proc/net/rpc/nfsd.export/content display
Message-ID: <20100926184632.GG25106@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Note with "first" always 0, and "lastflags" initially 0, we always dump
a spurious set of 0 flags at the start, among other problems.

Fix.  And attempt to make the code a little more obvious.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/export.c |   40 +++++++++++++++++++++++++++++-----------
 1 files changed, 29 insertions(+), 11 deletions(-)

For 2.6.37.--b.

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a3c7d0c..067e2e6 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1470,25 +1470,43 @@ static void show_secinfo_flags(struct seq_file *m, int flags)
 	show_expflags(m, flags, NFSEXP_SECINFO_FLAGS);
 }
 
+static bool secinfo_flags_equal(int f, int g)
+{
+	f &= NFSEXP_SECINFO_FLAGS;
+	g &= NFSEXP_SECINFO_FLAGS;
+	return f == g;
+}
+
+static int show_secinfo_run(struct seq_file *m, struct exp_flavor_info **fp, struct exp_flavor_info *end)
+{
+	int flags;
+
+	flags = (*fp)->flags;
+	seq_printf(m, ",sec=%d", (*fp)->pseudoflavor);
+	(*fp)++;
+	while (*fp != end && secinfo_flags_equal(flags, (*fp)->flags)) {
+		seq_printf(m, ":%d", (*fp)->pseudoflavor);
+		(*fp)++;
+	}
+	return flags;
+}
+
 static void show_secinfo(struct seq_file *m, struct svc_export *exp)
 {
 	struct exp_flavor_info *f;
 	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
-	int lastflags = 0, first = 0;
+	int flags;
 
 	if (exp->ex_nflavors == 0)
 		return;
-	for (f = exp->ex_flavors; f < end; f++) {
-		if (first || f->flags != lastflags) {
-			if (!first)
-				show_secinfo_flags(m, lastflags);
-			seq_printf(m, ",sec=%d", f->pseudoflavor);
-			lastflags = f->flags;
-		} else {
-			seq_printf(m, ":%d", f->pseudoflavor);
-		}
+	f = exp->ex_flavors;
+	flags = show_secinfo_run(m, &f, end);
+	if (!secinfo_flags_equal(flags, exp->ex_flags))
+		show_secinfo_flags(m, flags);
+	while (f != end) {
+		flags = show_secinfo_run(m, &f, end);
+		show_secinfo_flags(m, flags);
 	}
-	show_secinfo_flags(m, lastflags);
 }
 
 static void exp_flags(struct seq_file *m, int flag, int fsid,
-- 
1.7.0.4

