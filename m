Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbbCaUsk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 16:48:40 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2VKmeHh003800
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 16:48:40 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mountd: Enable all auth flavors on pseudofs exports
Date: Tue, 31 Mar 2015 16:48:39 -0400
Message-Id: <1427834919-46591-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the current mountd code it's possible to craft exports in such a
manner that clients will be unable to mount exports that they *should*
be able to mount.

Consider the following example:

/foo	*(rw,insecure,no_root_squash,sec=krb5p)
/bar	client.example.com(rw,insecure,no_root_squash)

Initially, client.example.com will be able to mount the /foo export
using sec=krb5p, but attempts to mount /bar using sec=sys will return
EPERM.  Once the nfsd.export cache entry expires, client.example.com
will then be able to mount /bar using sec=sys but attempts to mount /foo
using sec=krb5p will return EPERM.

The reason this happens is because the initial nfsd.export cache entry
is actually pre-populated by nfsd_fh(), which is the handler for the
nfsd.fh cache, while later cache requests (once the initial entry
expires) are handled by nfsd_export().  These functions have slightly
different logic in how they select a v4root export from the cache --
nfsd_fh() takes last matching v4root export it finds, while
nfsd_export() (actually lookup_export()) takes the first.  Either way
it's wrong because the client should be able to mount both exports.

Both rfc3503bis and rfc5661 say:

   A common and convenient practice, unless strong security requirements
   dictate otherwise, is to make the entire pseudo file system
   accessible by all of the valid security mechanisms.

...so lets do that.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/mountd/v4root.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 34d098a..0f60efc 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -26,6 +26,7 @@
 #include "nfslib.h"
 #include "misc.h"
 #include "v4root.h"
+#include "pseudoflavors.h"
 
 int v4root_needed;
 
@@ -56,22 +57,22 @@ static nfs_export pseudo_root = {
 };
 
 static void
-set_pseudofs_security(struct exportent *pseudo, struct exportent *source)
+set_pseudofs_security(struct exportent *pseudo, int flags)
 {
-	struct sec_entry *se;
+	struct flav_info *flav;
 	int i;
 
-	if (source->e_flags & NFSEXP_INSECURE_PORT)
+	if (flags & NFSEXP_INSECURE_PORT)
 		pseudo->e_flags |= NFSEXP_INSECURE_PORT;
-	if ((source->e_flags & NFSEXP_ROOTSQUASH) == 0)
+	if ((flags & NFSEXP_ROOTSQUASH) == 0)
 		pseudo->e_flags &= ~NFSEXP_ROOTSQUASH;
-	for (se = source->e_secinfo; se->flav; se++) {
+	for (flav = flav_map; flav < flav_map + flav_map_size; flav++) {
 		struct sec_entry *new;
 
-		i = secinfo_addflavor(se->flav, pseudo);
+		i = secinfo_addflavor(flav, pseudo);
 		new = &pseudo->e_secinfo[i];
 
-		if (se->flags & NFSEXP_INSECURE_PORT)
+		if (flags & NFSEXP_INSECURE_PORT)
 			new->flags |= NFSEXP_INSECURE_PORT;
 	}
 }
@@ -91,7 +92,7 @@ v4root_create(char *path, nfs_export *export)
 	strncpy(eep.e_path, path, sizeof(eep.e_path));
 	if (strcmp(path, "/") != 0)
 		eep.e_flags &= ~NFSEXP_FSID;
-	set_pseudofs_security(&eep, curexp);
+	set_pseudofs_security(&eep, curexp->e_flags);
 	exp = export_create(&eep, 0);
 	if (exp == NULL)
 		return NULL;
@@ -139,7 +140,7 @@ pseudofs_update(char *hostname, char *path, nfs_export *source)
 		return 0;
 	}
 	/* Update an existing V4ROOT export: */
-	set_pseudofs_security(&exp->m_export, &source->m_export);
+	set_pseudofs_security(&exp->m_export, &source->m_export.e_flags);
 	return 0;
 }
 
-- 
1.9.3

