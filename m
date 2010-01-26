Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab0AZRzs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 12:55:48 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] nfs41 do not allocate unused back channel pages
Date: Tue, 26 Jan 2010 12:55:28 -0500
Message-Id: <1264528528-4319-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/svc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 538ca43..984be52 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -506,6 +506,10 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
 	unsigned int pages, arghi;
 
+	/* bc_xprt uses fore channel allocated buffers */
+	if (rqstp->rq_server->bc_xprt)
+		return 1;
+
 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
 				       * We assume one is at most one page
 				       */
-- 
1.6.6

