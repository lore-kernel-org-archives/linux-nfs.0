Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:48818 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab3KHHXt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 02:23:49 -0500
Message-ID: <527C9160.3070808@huawei.com>
Date: Fri, 8 Nov 2013 15:23:12 +0800
From: Weng Meiling <wengmeiling.weng@huawei.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
CC: <Trond.Myklebust@netapp.com>, <bfields@fieldses.org>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
Subject: [PATCH] svcrpc: remove the unnecessary evaluation
References: <52786417.6090707@huawei.com>
In-Reply-To: <52786417.6090707@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


From: Weng Meiling <wengmeiling.weng@huawei.com>

Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 net/sunrpc/svc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b974571..e7fbe36 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1104,8 +1104,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
 	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */

-	progp = serv->sv_program;
-
 	for (progp = serv->sv_program; progp; progp = progp->pg_next)
 		if (prog == progp->pg_prog)
 			break;
-- 
1.8.3.1




