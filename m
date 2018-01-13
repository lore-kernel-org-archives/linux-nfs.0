Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:55626 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751335AbeAMODd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 13 Jan 2018 09:03:33 -0500
Subject: [PATCH 1/2] nfsd: Use seq_putc() in four functions
From: SF Markus Elfring <elfring@users.sourceforge.net>
To: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
References: <43df7d8b-f37e-91ca-9c8c-96e318adeb4f@users.sourceforge.net>
Message-ID: <3afb88f1-2934-f1be-067b-db43df675bd4@users.sourceforge.net>
Date: Sat, 13 Jan 2018 15:03:27 +0100
MIME-Version: 1.0
In-Reply-To: <43df7d8b-f37e-91ca-9c8c-96e318adeb4f@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 13 Jan 2018 14:20:27 +0100

Five single characters should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 fs/nfsd/export.c    | 6 +++---
 fs/nfsd/nfs4idmap.c | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8ceb25a10ea0..3b035a87e4c4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -181,10 +181,10 @@ static int expkey_show(struct seq_file *m,
 		seq_printf(m, "%08x", ek->ek_fsid[i]);
 	if (test_bit(CACHE_VALID, &h->flags) && 
 	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
-		seq_printf(m, " ");
+		seq_putc(m, ' ');
 		seq_path(m, &ek->ek_path, "\\ \t\n");
 	}
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 
@@ -1123,7 +1123,7 @@ static void show_expflags(struct seq_file *m, int flags, int mask)
 
 static void show_secinfo_flags(struct seq_file *m, int flags)
 {
-	seq_printf(m, ",");
+	seq_putc(m, ',');
 	show_expflags(m, flags, NFSEXP_SECINFO_FLAGS);
 }
 
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index a5bb76593ce7..8917b5f09896 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -161,7 +161,7 @@ idtoname_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
 			ent->id);
 	if (test_bit(CACHE_VALID, &h->flags))
 		seq_printf(m, " %s", ent->name);
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 
@@ -332,7 +332,7 @@ nametoid_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
 			ent->name);
 	if (test_bit(CACHE_VALID, &h->flags))
 		seq_printf(m, " %u", ent->id);
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 
-- 
2.15.1

