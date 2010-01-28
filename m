From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 2/3] nfs-utils: dont leak fd in mountlist_list
Date: Thu, 28 Jan 2010 15:26:34 -0600
Message-ID: <20100128212634.29681.43239.stgit@case.americas.sgi.com>
References: <20100128211454.29681.24752.stgit@case.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: SteveD@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:33332 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753456Ab0A1V0f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 16:26:35 -0500
In-Reply-To: <20100128211454.29681.24752.stgit-PhfrMOq4MEUPybYDWDrblq0bRtRcJeJQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't leak this file descriptor if stat should fail.
---
 utils/mountd/rmtab.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index b028529..19b22ee 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -24,6 +24,7 @@
 #include "ha-callout.h"
 
 #include <limits.h> /* PATH_MAX */
+#include <errno.h>
 
 extern int reverse_resolve;
 
@@ -187,7 +188,9 @@ mountlist_list(void)
 	if ((lockid = xflock(_PATH_RMTABLCK, "r")) < 0)
 		return NULL;
 	if (stat(_PATH_RMTAB, &stb) < 0) {
-		xlog(L_ERROR, "can't stat %s", _PATH_RMTAB);
+		xlog(L_ERROR, "can't stat %s: %s",
+				_PATH_RMTAB, strerror(errno));
+		xfunlock(lockid);
 		return NULL;
 	}
 	if (stb.st_mtime != last_mtime) {

