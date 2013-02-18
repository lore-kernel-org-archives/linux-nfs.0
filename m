Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f51.google.com ([209.85.128.51]:35622 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab3BRNVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 08:21:52 -0500
Received: by mail-qe0-f51.google.com with SMTP id 6so2414367qea.38
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2013 05:21:50 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2] sunrpc: silence build warning in gss_fill_context
Date: Mon, 18 Feb 2013 08:21:45 -0500
Message-Id: <1361193705-14440-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3EA286@sacexcmbx05-prd.hq.netapp.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3EA286@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 620038f6d23, gcc is throwing the following warning:

  CC [M]  net/sunrpc/auth_gss/auth_gss.o
In file included from include/linux/sunrpc/types.h:14:0,
                 from include/linux/sunrpc/sched.h:14,
                 from include/linux/sunrpc/clnt.h:18,
                 from net/sunrpc/auth_gss/auth_gss.c:45:
net/sunrpc/auth_gss/auth_gss.c: In function ‘gss_pipe_downcall’:
include/linux/sunrpc/debug.h:45:10: warning: ‘timeout’ may be used
uninitialized in this function [-Wmaybe-uninitialized]
    printk(KERN_DEFAULT args); \
          ^
net/sunrpc/auth_gss/auth_gss.c:194:15: note: ‘timeout’ was declared here
  unsigned int timeout;
               ^
If simple_get_bytes returns an error, then we'll end up calling printk
with an uninitialized timeout value. Remove the timeout from the
dprintk in order to remove the warning.

Cc: Andy Adamson <andros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6e5c824..9f25403 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -247,8 +247,8 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 		__func__, ctx->gc_expiry, now, timeout);
 	return q;
 err:
-	dprintk("RPC:       %s returns %ld gc_expiry %lu now %lu timeout %u\n",
-		__func__, -PTR_ERR(p), ctx->gc_expiry, now, timeout);
+	dprintk("RPC:       %s returns %ld gc_expiry %lu now %lu\n",
+		__func__, -PTR_ERR(p), ctx->gc_expiry, now);
 	return p;
 }
 
-- 
1.7.11.7

