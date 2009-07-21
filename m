From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Fix hang on access to NFSv4 subexports with sec=
Date: Tue, 21 Jul 2009 18:49:38 -0400
Message-ID: <20090721224938.GA20694@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45854 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529AbZGUWti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 18:49:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since

	2d77e3a27b7b211f303f.. "Fix bug when both crossmnt and fsid are set"

Subexports automatically created by "crossmnt" get the NFSEXP_FSID flag
cleared.  That flag should also be cleared in the
security-flavor-specific flag fields.  Otherwise the kernel detects the
inconsistent flags and rejects the export.

The symptoms are clients hanging the first time they export a filesystem
mounted under a filesystem that was exported with something like:

	/exports *(crossmnt,fsid=0,sec=krb5)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9bbbfb3..e4e2f22 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -564,7 +564,7 @@ static void write_fsloc(FILE *f, struct exportent *ep, char *path)
 	release_replicas(servers);
 }
 
-static void write_secinfo(FILE *f, struct exportent *ep)
+static void write_secinfo(FILE *f, struct exportent *ep, int flag_mask)
 {
 	struct sec_entry *p;
 
@@ -578,7 +578,7 @@ static void write_secinfo(FILE *f, struct exportent *ep)
 	qword_printint(f, p - ep->e_secinfo);
 	for (p = ep->e_secinfo; p->flav; p++) {
 		qword_printint(f, p->flav->fnum);
-		qword_printint(f, p->flags);
+		qword_printint(f, p->flags & flag_mask);
 	}
 
 }
@@ -590,16 +590,14 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 	qword_printint(f, time(0)+30*60);
 	if (exp) {
 		int different_fs = strcmp(path, exp->e_path) != 0;
-		
-		if (different_fs)
-			qword_printint(f, exp->e_flags & ~NFSEXP_FSID);
-		else
-			qword_printint(f, exp->e_flags);
+		int flag_mask = different_fs ? ~NFSEXP_FSID : ~0;
+
+		qword_printint(f, exp->e_flags & flag_mask);
 		qword_printint(f, exp->e_anonuid);
 		qword_printint(f, exp->e_anongid);
 		qword_printint(f, exp->e_fsid);
 		write_fsloc(f, exp, path);
-		write_secinfo(f, exp);
+		write_secinfo(f, exp, flag_mask);
  		if (exp->e_uuid == NULL || different_fs) {
  			char u[16];
  			if (get_uuid(path, NULL, 16, u)) {
