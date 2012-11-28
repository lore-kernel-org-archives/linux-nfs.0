Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47475 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452Ab2K1BMq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 20:12:46 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Wed, 28 Nov 2012 12:11:23 +1100
Subject: [PATCH 3/3] gssd: base the size of the fd array on the
 RLIMIT_NOFILE limit.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20121128011123.2475.13691.stgit@notabene.brown>
In-Reply-To: <20121128010939.2475.13123.stgit@notabene.brown>
References: <20121128010939.2475.13123.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have previously raised the size of the 'pollarray' once (32 -> 256)
and I have had another request to make it bigger.
Rather than changing the hard-coded value, make it depend on
RLIMIT_NOFILE.  This is an upper limit on the size of the array
that can be passed to poll() anyway.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/gssd/gssd_proc.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 425b582..e32b2f0 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -52,6 +52,7 @@
 #include <sys/socket.h>
 #include <arpa/inet.h>
 #include <sys/fsuid.h>
+#include <sys/resource.h>
 
 #include <stdio.h>
 #include <stdlib.h>
@@ -483,9 +484,13 @@ fail_keep_client:
 void
 init_client_list(void)
 {
+	struct rlimit rlim;
 	TAILQ_INIT(&clnt_list);
 	/* Eventually plan to grow/shrink poll array: */
 	pollsize = FD_ALLOC_BLOCK;
+	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0 &&
+	    rlim.rlim_cur != RLIM_INFINITY)
+		pollsize = rlim.rlim_cur;
 	pollarray = calloc(pollsize, sizeof(struct pollfd));
 }
 


