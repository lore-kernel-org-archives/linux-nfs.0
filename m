Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f178.google.com ([209.85.213.178]:51383 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab3BGP3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 10:29:12 -0500
Received: by mail-ye0-f178.google.com with SMTP id j12so31577yeg.23
        for <linux-nfs@vger.kernel.org>; Thu, 07 Feb 2013 07:29:12 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: silence build warning in gss_fill_context
Date: Thu,  7 Feb 2013 10:29:06 -0500
Message-Id: <1360250946-26745-1-git-send-email-jlayton@redhat.com>
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
with an uninitialized timeout value. Reasonably harmless, but fairly
simple to fix by setting the timeout to 0 if it does.

Cc: Andy Adamson <andros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6e5c824..b706b4c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -201,8 +201,10 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	 * the -t value passed to GSSD.
 	 */
 	p = simple_get_bytes(p, end, &timeout, sizeof(timeout));
-	if (IS_ERR(p))
+	if (IS_ERR(p)) {
+		timeout = 0;
 		goto err;
+	}
 	if (timeout == 0)
 		timeout = GSSD_MIN_TIMEOUT;
 	ctx->gc_expiry = now + ((unsigned long)timeout * HZ);
-- 
1.7.11.7

