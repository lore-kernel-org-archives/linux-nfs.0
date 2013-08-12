Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46570 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756357Ab3HLQlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 12:41:47 -0400
Date: Mon, 12 Aug 2013 12:41:44 -0400
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] idmapd: silence pointless EOF warning
Message-ID: <20130812164144.GC2395@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

RH bz 831455 has a report that repeatedly mounting and unmounting over
lo can hit this warning in the EOF case.  I suspect that's just
normal--I'm not sure of the details, but probably idmapd gets woken up
to check for an upcall and then the upcall gets yanked away before
idmapd gets a chance to read it.

So just skip the warning in that case.  I also can't see a reason to
reopen.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/idmapd/idmapd.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index beba9c4..cc4ba9a 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -511,10 +511,14 @@ nfsdcb(int UNUSED(fd), short which, void *data)
 	if (which != EV_READ)
 		goto out;
 
-	if ((len = read(ic->ic_fd, buf, sizeof(buf))) <= 0) {
+	len = read(ic->ic_fd, buf, sizeof(buf));
+	if (len == 0)
+		/* No upcall to read; not necessarily a problem: */
+		return;
+	if (len < 0) {
 		xlog_warn("nfsdcb: read(%s) failed: errno %d (%s)",
-			     ic->ic_path, len?errno:0, 
-			     len?strerror(errno):"End of File");
+			     ic->ic_path, errno,
+			     strerror(errno));
 		nfsdreopen_one(ic);
 		return;
 	}
-- 
1.8.3.1

