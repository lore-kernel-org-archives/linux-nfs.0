Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57088 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbcGNC14 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 22:27:56 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 14 Jul 2016 12:26:43 +1000
Subject: [PATCH 4/8] mountd: cause attempts to access unmounted exportpoints
 to return ESTALE
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <20160714022643.5874.15072.stgit@noble>
In-Reply-To: <20160714021310.5874.22953.stgit@noble>
References: <20160714021310.5874.22953.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a filehandle arrives for an export with the "mountpoint" option,
but which isn't mounted, then we should return ESTALE rather than
delaying in the hope the filesystem might get mounted.
It is safest to assume that if a filesystem didn't get mounted, then
there is a serious problem, and waiting isn't likely to fix it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/cache.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 346a8b3af8b5..f33f66640c6c 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -689,6 +689,7 @@ static void nfsd_fh(int f)
 	int i;
 	char buf[RPC_CHAN_BUF_SIZE], *bp;
 	int blen;
+	int short_timeout = 0;
 
 	blen = read(f, buf, sizeof(buf));
 	if (blen <= 0 || buf[blen-1] != '\n') return;
@@ -787,13 +788,12 @@ static void nfsd_fh(int f)
 	    !is_mountpoint(found->e_mountpoint[0]?
 			   found->e_mountpoint:
 			   found->e_path)) {
-		/* Cannot export this yet 
-		 * should log a warning, but need to rate limit
-		   xlog(L_WARNING, "%s not exported as %d not a mountpoint",
-		   found->e_path, found->e_mountpoint);
+		/* Cannot export this, as it isn't mounted.
+		 * Set a short timeout so we might try again
+		 * if the filesystem gets mounted.
 		 */
-		/* FIXME we need to make sure we re-visit this later */
-		goto out;
+		found = 0;
+		short_timeout = 1;
 	}
 
 	if (found)
@@ -812,7 +812,10 @@ static void nfsd_fh(int f)
 	 * timeout.  Maybe this should be configurable on the command
 	 * line.
 	 */
-	qword_addint(&bp, &blen, 0x7fffffff);
+	if (short_timeout)
+		qword_addint(&bp, &blen, DEFAULT_TTL);
+	else
+		qword_addint(&bp, &blen, 0x7fffffff);
 	if (found)
 		qword_add(&bp, &blen, found_path);
 	qword_addeol(&bp, &blen);


