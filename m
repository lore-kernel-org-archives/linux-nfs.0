From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/24] SUNRPC: Use unsigned index when looping over arrays
Date: Mon, 14 Apr 2008 12:27:45 -0400
Message-ID: <20080414162745.12741.37176.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40034 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbYDNRBC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:02 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Suppress a harmless compiler warning in the RPC server related
to array indices.

ARRAY_SIZE() returns a size_t, so use unsigned type for a loop index when
looping over arrays.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a290e15..c1e763b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -528,8 +528,9 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 static void
 svc_release_buffer(struct svc_rqst *rqstp)
 {
-	int i;
-	for (i=0; i<ARRAY_SIZE(rqstp->rq_pages); i++)
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(rqstp->rq_pages); i++)
 		if (rqstp->rq_pages[i])
 			put_page(rqstp->rq_pages[i]);
 }

