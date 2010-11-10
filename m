Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4853 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab0KJAfd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Nov 2010 19:35:33 -0500
From: Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH 9/9] net/sunrpc/svc.c: Use printf extension %pV
Date: Tue,  9 Nov 2010 16:35:23 -0800
Message-Id: <b604853e1e9ceb978763d7d798e45f234226feaa.1289348758.git.joe@perches.com>
In-Reply-To: <cover.1289348757.git.joe@perches.com>
References: <cover.1289348757.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Using %pV reduces the number of printk calls and
eliminates any possible message interleaving from
other printk calls.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/svc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6359c42..e28ddb3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -962,6 +962,7 @@ static int
 __attribute__ ((format (printf, 2, 3)))
 svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 	int 	r;
 	char 	buf[RPC_MAX_ADDRBUFLEN];
@@ -969,11 +970,14 @@ svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 	if (!net_ratelimit())
 		return 0;
 
-	printk(KERN_WARNING "svc: %s: ",
-		svc_print_addr(rqstp, buf, sizeof(buf)));
-
 	va_start(args, fmt);
-	r = vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	r = printk(KERN_WARNING "svc: %s: %pV",
+		   svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
+
 	va_end(args);
 
 	return r;
-- 
1.7.3.1.g432b3.dirty

