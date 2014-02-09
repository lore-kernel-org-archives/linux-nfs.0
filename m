Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:54845 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbaBIRDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Feb 2014 12:03:12 -0500
From: Rashika Kheria <rashika.kheria@gmail.com>
To: linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, josh@joshtriplett.org
Subject: =?UTF-8?q?=5BPATCH=20v2=2013/13=5D=20net=3A=20Mark=20functions=20as=20static=20in=20net/sunrpc/svc=5Fxprt=2Ec?=
Date: Sun,  9 Feb 2014 22:33:03 +0530
Message-Id: <6683a8aafa491f99b0ae6e5a23614f1dbcac6ec2.1391955925.git.rashika.kheria@gmail.com>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mark functions as static in net/sunrpc/svc_xprt.c because they are not
used outside this file.

This eliminates the following warning in net/sunrpc/svc_xprt.c:
net/sunrpc/svc_xprt.c:574:5: warning: no previous prototype for ‘svc_alloc_arg’ [-Wmissing-prototypes]
net/sunrpc/svc_xprt.c:615:18: warning: no previous prototype for ‘svc_get_next_xprt’ [-Wmissing-prototypes]
net/sunrpc/svc_xprt.c:694:6: warning: no previous prototype for ‘svc_add_new_temp_xprt’ [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 net/sunrpc/svc_xprt.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 80a6640..06c6ff0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -571,7 +571,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 	}
 }
 
-int svc_alloc_arg(struct svc_rqst *rqstp)
+static int svc_alloc_arg(struct svc_rqst *rqstp)
 {
 	struct svc_serv *serv = rqstp->rq_server;
 	struct xdr_buf *arg;
@@ -612,7 +612,7 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
 	return 0;
 }
 
-struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
+static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 {
 	struct svc_xprt *xprt;
 	struct svc_pool		*pool = rqstp->rq_pool;
@@ -691,7 +691,7 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 	return xprt;
 }
 
-void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
+static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
 {
 	spin_lock_bh(&serv->sv_lock);
 	set_bit(XPT_TEMP, &newxpt->xpt_flags);
-- 
1.7.9.5

