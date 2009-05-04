From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFS: Fix false error return from nfs_callback_up() if
	ipv6.ko is not available
Date: Mon, 04 May 2009 13:01:33 -0400
Message-ID: <20090504170132.2733.84230.stgit@ingres.1015granger.net>
References: <20090504165839.2733.50787.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:55661 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754677AbZEDRBn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2009 13:01:43 -0400
In-Reply-To: <20090504165839.2733.50787.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clear "ret" if the error return from svc_create_xprt(AF_INET6) was
-EAFNOSUPORT.  Otherwise, callback start-up will succeed, but
nfs_callback_up() will return -EAFNOSUPPORT anyway, and the first
NFSv4 mount attempt after a reboot will fail.

Bug introduced by commit f738f517 in 2.6.30-rc1.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a886e69..6e3bd42 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -127,7 +127,9 @@ int nfs_callback_up(void)
 		nfs_callback_tcpport6 = ret;
 		dprintk("NFS: Callback listener port = %u (af %u)\n",
 				nfs_callback_tcpport6, PF_INET6);
-	} else if (ret != -EAFNOSUPPORT)
+	} else if (ret == -EAFNOSUPPORT)
+		ret = 0;
+	else
 		goto out_err;
 #endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 

