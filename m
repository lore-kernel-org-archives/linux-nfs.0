Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57110 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbcGNC2B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 22:28:01 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 14 Jul 2016 12:26:43 +1000
Subject: [PATCH 5/8] mountd: Don't export unmounted exports to NFSv4
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <20160714022643.5874.38987.stgit@noble>
In-Reply-To: <20160714021310.5874.22953.stgit@noble>
References: <20160714021310.5874.22953.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An export point with the "mountpoint" option should not be exported
if it isn't a mount point.
For NFSv3, this is handled primarily by failing the MOUNT request.
For NFSv4, we must ensure a lookup from the pseduo-root fails too.

This means nfsd_export must check for the 'mountpoint' option and handle
it correctly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/cache.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index f33f66640c6c..19e7607e4fb1 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1321,7 +1321,12 @@ static void nfsd_export(int f)
 	found = lookup_export(dom, path, ai);
 
 	if (found) {
-		if (dump_to_cache(f, buf, sizeof(buf), dom, path, &found->m_export) < 0) {
+		if (found->m_export.e_mountpoint &&
+		    !is_mountpoint(found->m_export.e_mountpoint[0]?
+				   found->m_export.e_mountpoint:
+				   found->m_export.e_path))
+			dump_to_cache(f, buf, sizeof(buf), dom, path, NULL);
+		else if (dump_to_cache(f, buf, sizeof(buf), dom, path, &found->m_export) < 0) {
 			xlog(L_WARNING,
 			     "Cannot export %s, possibly unsupported filesystem"
 			     " or fsid= required", path);


