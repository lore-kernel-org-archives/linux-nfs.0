Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:21516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab3AOHmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 02:42:08 -0500
From: Mika Westerberg <mika.westerberg@linux.intel.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] svcrpc: fix compile warning about unused variable 'buf'
Date: Tue, 15 Jan 2013 09:43:06 +0200
Message-Id: <1358235787-17292-1-git-send-email-mika.westerberg@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 7032a3dd923 (svcrpc: demote some printks to a dprintk) changed the
printk to a dprintk() macro. Since the macro is not always available we get
following compile warning:

net/sunrpc/svc.c: In function ‘svc_printk’:
net/sunrpc/svc.c:1050:8: warning: unused variable ‘buf’ [-Wunused-variable]

Fix this by marking the 'buf' with __maybe_unused.

In addition make checkpatch.pl happy by removing space before tab after
'char'.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
---
 net/sunrpc/svc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dbf12ac..2387ec8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1047,7 +1047,7 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	char 	buf[RPC_MAX_ADDRBUFLEN];
+	char	buf[RPC_MAX_ADDRBUFLEN] __maybe_unused;
 
 	va_start(args, fmt);
 
-- 
1.7.10.4

