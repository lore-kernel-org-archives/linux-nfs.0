Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53528 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070Ab0JVXUk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Oct 2010 19:20:40 -0400
Date: Fri, 22 Oct 2010 16:18:52 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        akpm <akpm@linux-foundation.org>
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH -next] nfs: include ratelimit.h, fix nfs4state build error
Message-Id: <20101022161852.2ef2638c.randy.dunlap@oracle.com>
In-Reply-To: <20101022152350.fc79e2b9.sfr@canb.auug.org.au>
References: <20101022152350.fc79e2b9.sfr@canb.auug.org.au>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Randy Dunlap <randy.dunlap@oracle.com>

nfs4state.c uses interfaces from ratelimit.h.  It needs to include
that header file to fix build errors:

fs/nfs/nfs4state.c:1195: warning: type defaults to 'int' in declaration of 'DEFINE_RATELIMIT_STATE'
fs/nfs/nfs4state.c:1195: warning: parameter names (without types) in function declaration
fs/nfs/nfs4state.c:1195: error: invalid storage class for function 'DEFINE_RATELIMIT_STATE'
fs/nfs/nfs4state.c:1195: error: implicit declaration of function '__ratelimit'
fs/nfs/nfs4state.c:1195: error: '_rs' undeclared (first use in this function)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc:	Trond Myklebust <Trond.Myklebust@netapp.com>
Cc:	linux-nfs@vger.kernel.org
---
 fs/nfs/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20101022.orig/fs/nfs/nfs4state.c
+++ linux-next-20101022/fs/nfs/nfs4state.c
@@ -46,6 +46,7 @@
 #include <linux/kthread.h>
 #include <linux/module.h>
 #include <linux/random.h>
+#include <linux/ratelimit.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
 
