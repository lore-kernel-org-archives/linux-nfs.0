Return-Path: linux-nfs-owner@vger.kernel.org
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:51391 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751189Ab2BPNzG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 08:55:06 -0500
From: Danny Kukawka <danny.kukawka@bisect.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Danny Kukawka <dkukawka@suse.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] fs/nfs/dns_resolve.c: included linux/sunrpc/clnt.h twice
Date: Thu, 16 Feb 2012 14:55:01 +0100
Message-Id: <1329400501-31682-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfs/dns_resolve.c included 'linux/sunrpc/clnt.h' twice.
No need to include it in the '#ifdef CONFIG_NFS_USE_KERNEL_DNS'
and the '#else' block, include it at top of the file, since
the file is always needed.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 fs/nfs/dns_resolve.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index a6e711a..ab08011 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -6,9 +6,10 @@
  * Resolves DNS hostnames into valid ip addresses
  */
 
+#include <linux/sunrpc/clnt.h>
+
 #ifdef CONFIG_NFS_USE_KERNEL_DNS
 
-#include <linux/sunrpc/clnt.h>
 #include <linux/dns_resolver.h>
 
 ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
@@ -37,7 +38,6 @@ ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
 #include <linux/socket.h>
 #include <linux/seq_file.h>
 #include <linux/inet.h>
-#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/svcauth.h>
 
-- 
1.7.8.3

