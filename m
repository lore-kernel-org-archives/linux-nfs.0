Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:54865 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab2BOTmD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 14:42:03 -0500
Received: by yhoo21 with SMTP id o21so904245yho.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 11:42:02 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/13] SUNRPC: Use KERN_DEFAULT for debugging printk's
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 14:42:00 -0500
Message-ID: <20120215194200.2925.93896.stgit@ellison.1015granger.net>
In-Reply-To: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
References: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our dprintk() debugging facility doesn't specify any verbosity level
for it's printk() calls, but it should.

The default verbosity for printk's is KERN_DEFAULT.  You might argue
that these are debugging printk's and thus the verbosity should be
KERN_DEBUG.  That would mean that to see NFS and SUNRPC debugging
output an admin would also have to boost the syslog verbosity, which
would be insufferably noisy.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/debug.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index c2786f2..e0927c2 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -51,7 +51,11 @@ extern unsigned int		nlm_debug;
 #undef ifdebug
 #ifdef RPC_DEBUG			
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
-# define dfprintk(fac, args...)	do { ifdebug(fac) printk(args); } while(0)
+# define dfprintk(fac, args...)	\
+	do { \
+		ifdebug(fac) \
+			printk(KERN_DEFAULT args); \
+	} while (0)
 # define RPC_IFDEBUG(x)		x
 #else
 # define ifdebug(fac)		if (0)

