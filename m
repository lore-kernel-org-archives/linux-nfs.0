Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35135 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbcG2FFU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 01:05:20 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 29 Jul 2016 15:03:36 +1000
Subject: [PATCH 7/7] mountd: fail nfsd.export lookup for path to unmounted
 exportpoint
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <146976861683.20186.1810009593325251793.stgit@noble>
In-Reply-To: <146976807524.20186.8871903418718212567.stgit@noble>
References: <146976807524.20186.8871903418718212567.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an export point should be mounted ("mountpoint" option set) but
isn't, then an attempt to mount using the MOUNT protocol for NFSv3
will fail and an attempt to access the filesystem using a pre-existing
filehandle will block because nfsd_fh wont tell the kernel about it.

However a lookup from the parent, as happens with an NFSv4 mount
request, will pass the name to nfsd_export(), and it doesn't check the
mointpoint option, and so exports the underlying (typically "/")
filesystem.

So change nfsd_export() to refused to export that exportpoint, but
instead to explictly say that it isn't exported.
This will cause an 'ls' in the parent pseudo-root directory to not show
the name and will cause a "mount" attempt which walks down through the
pseudo root to fail in the same way that it does with NFSv3.

An access from a pre-existing NFSv4 mount will still hang until the
filesystem is mounted, just like it does with NFSv3.

In order to be a bit more responsive to the filesystem getting mounted,
just a short timeout (1 minutes) on exports of missing "mountpoint"
exportpoints.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/cache.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9cc270690d90..ca6c84f4d93d 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1334,7 +1334,23 @@ static void nfsd_export(int f)
 	found = lookup_export(dom, path, ai);
 
 	if (found) {
-		if (dump_to_cache(f, buf, sizeof(buf), dom, path, &found->m_export, 0) < 0) {
+		char *mp = found->m_export.e_mountpoint;
+
+		if (mp && !*mp)
+			mp = found->m_export.e_path;
+		if (mp && !is_mountpoint(mp))
+			/* Exportpoint is not mounted, so tell kernel it is
+			 * not available.
+			 * This will cause it not to appear in the V4 Pseudo-root
+			 * and so a "mount" of this path will fail, just like with
+			 * V3.
+			 * And filehandle for this mountpoint from an earlier
+			 * mount will block in nfsd.fh lookup.
+			 */
+			dump_to_cache(f, buf, sizeof(buf), dom, path,
+				      NULL, 60);
+		else if (dump_to_cache(f, buf, sizeof(buf), dom, path,
+					 &found->m_export, 0) < 0) {
 			xlog(L_WARNING,
 			     "Cannot export %s, possibly unsupported filesystem"
 			     " or fsid= required", path);


