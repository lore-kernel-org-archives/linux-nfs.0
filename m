From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] SUNRPC: Add a default setting for CONFIG_SUNRPC_BIND34
Date: Fri, 14 Mar 2008 14:15:18 -0400
Message-ID: <20080314181518.29889.73453.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:41142 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995AbYCNSPd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:15:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most distros will want support for rpcbind protocols 3 and 4 to default off
until they have integrated user-space support for the new rpcbind daemon
which supports IPv6 RPC services.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 93c3e9c..bbc8e52 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1773,6 +1773,7 @@ config SUNRPC_XPRT_RDMA
 config SUNRPC_BIND34
 	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
+	default n
 	help
 	  RPC requests over IPv6 networks require support for larger
 	  addresses when performing an RPC bind.  Sun added support for

