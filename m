From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: nfs client fixup
Date: Wed, 27 Feb 2008 16:52:51 +1100
Message-ID: <20080227165251.f3393be2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-next@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:33309 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbYB0Fww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2008 00:52:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I assume you have already found this, but the current linux-next tree
fails to build if CONFIG_NFS_V4 is not set and CONFIG_NFS_FS is set.

s/nfs/client.c:192: error: 'struct nfs_client' has no member named 'cl_rpcwaitq'

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2b20650..b7daf24 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -189,7 +189,9 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
 		nfs_callback_down();
 
+#ifdef CONFIG_NFS_V4
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+#endif
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
