Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:1384 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933153Ab3BLTtM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 14:49:12 -0500
From: Tim Gardner <tim.gardner@canonical.com>
To: linux-kernel@vger.kernel.org
Cc: Tim Gardner <tim.gardner@canonical.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH linux-next] lockd: nlmsvc_mark_resources(): avoid stack overflow
Date: Tue, 12 Feb 2013 12:48:58 -0700
Message-Id: <1360698538-63040-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dynamically allocate the NLM host structure in order to avoid stack overflow.
nlmsvc_mark_resources() is several call levels deep in a stack
that has a number of large variables. 512 bytes seems like a lot
on the stack at this point.

smatch analysis:

fs/lockd/svcsubs.c:366 nlmsvc_mark_resources() warn: 'hint' puts
 512 bytes on stack

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 fs/lockd/svcsubs.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index b904f41..f3abb7f 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -363,11 +363,15 @@ nlmsvc_is_client(void *data, struct nlm_host *dummy)
 void
 nlmsvc_mark_resources(struct net *net)
 {
-	struct nlm_host hint;
+	struct nlm_host *hint = kzalloc(sizeof(*hint), GFP_KERNEL);
 
-	dprintk("lockd: nlmsvc_mark_resources for net %p\n", net);
-	hint.net = net;
-	nlm_traverse_files(&hint, nlmsvc_mark_host, NULL);
+	if (hint) {
+		dprintk("lockd: nlmsvc_mark_resources for net %p\n", net);
+		hint->net = net;
+		nlm_traverse_files(hint, nlmsvc_mark_host, NULL);
+	}
+
+	kfree(hint);
 }
 
 /*
-- 
1.7.9.5

