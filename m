Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:50026 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932128AbdJ0QoM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 12:44:12 -0400
Subject: [PATCH 3/4] xprtrdma: Remove include for linux/prefetch.h
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Oct 2017 12:44:10 -0400
Message-ID: <20171027164410.10826.94955.stgit@manet.1015granger.net>
In-Reply-To: <20171027164014.10826.10151.stgit@manet.1015granger.net>
References: <20171027164014.10826.10151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. This include should have been removed by
commit 23826c7aeac7 ("xprtrdma: Serialize credit accounting again").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4cfa893..be61c29 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -49,7 +49,6 @@
 
 #include <linux/interrupt.h>
 #include <linux/slab.h>
-#include <linux/prefetch.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/svc_rdma.h>
 

