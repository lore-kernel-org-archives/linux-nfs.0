Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42146 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab3AHV2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2013 16:28:23 -0500
Date: Tue, 8 Jan 2013 16:28:16 -0500
To: Russell King <rmk@arm.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Commit 7032a3dd9 (svcrpc: demote some printks to a dprintk) adds
 warnings
Message-ID: <20130108212816.GA24572@fieldses.org>
References: <20130108121300.GA2251@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130108121300.GA2251@flint.arm.linux.org.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2013 at 12:13:00PM +0000, Russell King wrote:
> Bruce,
> 
> Your commit below causes a new build warning in the kernel:
> 
> net/sunrpc/svc.c: In function 'svc_printk':
> net/sunrpc/svc.c:1050:7: warning: unused variable 'buf'
> 
> which affects all ARM builds; it is the only warning in a lot of cases.
> Please can you resolve this new warning using whatever method you feel
> is most appropriate, thanks.

Bah, these "unused variable" warnings for buffers unused in the
!RPC_DEBUG case keep popping up.

I guess I'll commit the following for 3.9.

--b.

commit 31e815406973ef86e2e42a36086d65afb8f4e396
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Jan 8 16:22:15 2013 -0500

    svcrpc: silence "unused variable" warning in !RPC_DEBUG case
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dbf12ac..b9ba2a8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1042,6 +1042,7 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 /*
  * dprintk the given error with the address of the client that caused it.
  */
+#ifdef RPC_DEBUG
 static __printf(2, 3)
 void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
@@ -1058,6 +1059,9 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 
 	va_end(args);
 }
+#else
+static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...) {}
+#endif
 
 /*
  * Common routine for processing the RPC request.
