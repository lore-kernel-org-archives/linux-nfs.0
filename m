Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41947 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030Ab3AHMNK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 07:13:10 -0500
Date: Tue, 8 Jan 2013 12:13:00 +0000
From: Russell King <rmk@arm.linux.org.uk>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Commit 7032a3dd9 (svcrpc: demote some printks to a dprintk) adds
	warnings
Message-ID: <20130108121300.GA2251@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

Your commit below causes a new build warning in the kernel:

net/sunrpc/svc.c: In function 'svc_printk':
net/sunrpc/svc.c:1050:7: warning: unused variable 'buf'

which affects all ARM builds; it is the only warning in a lot of cases.
Please can you resolve this new warning using whatever method you feel
is most appropriate, thanks.

commit 7032a3dd923f434132643321ad5faad128611f9e
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Oct 9 18:33:38 2012 -0400

    svcrpc: demote some printks to a dprintk
    
    In general I'd rather random bad behavior on the network won't trigger a
    printk.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3ee7461..be301e1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1035,7 +1035,7 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 }
 
 /*
- * Printk the given error with the address of the client that caused it.
+ * dprintk the given error with the address of the client that caused it.
  */
 static __printf(2, 3)
 void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
@@ -1049,8 +1049,7 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
        vaf.fmt = fmt;
        vaf.va = &args;
 
-       net_warn_ratelimited("svc: %s: %pV",
-                            svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
+       dprintk("svc: %s: %pV", svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
 
        va_end(args);
 }

-- 
Russell King
