Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:36691 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935817AbcKJUmb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 15:42:31 -0500
Date: Thu, 10 Nov 2016 12:42:24 -0800
From: Petr Vandrovec <petr@vandrovec.name>
To: <linux-nfs@vger.kernel.org>
CC: <anna.schumaker@netapp.com>, <trond.myklebust@primarydata.com>
Subject: [PATCH] Do not dereference ERR_PTR(-EINVAL) in NFS client code
Message-ID: <20161110204224.xcbu3ttyk7codgqi@petr-dev3.eng.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
  Andy Adamson's change added code that unconditionally calls
rpc_clnt_xptr_switch_has_addr() with clp->cl_rpcclient from place
where clp->cl_rpcclient may be still set to its initial
ERR_PTR(-EINVAL) value, rather than to real RPC client.

This then causes dereference of
ERR_PTR(-EINVAL) + offsetof(rpc_clnt, cl_xpi.xpi_xpswitch)
in net/sunrpc/clnt.c at line 2773.

There seems to be other code that accesses cl_rpcclient, but
as far as I can tell, all remaining sites cannot encounter
clp that is in the middle of initializing.

Problem is also tracked in bugzilla.kernel.org as bug 182171.
As it is regression in 4.9.0, it would be great if it can be fixed
before 4.9.0 is final.

Thanks,
Petr Vandrovec



commit d2d51793392a176aaba7fe2ea3edb3c6f62d5e68
Author: Petr Vandrovec <petr@vandrovec.name>
Date:   Mon Nov 7 12:11:29 2016 -0800

    Ignore connections that have cl_rpcclient uninitialized
    
    cl_rpcclient starts as ERR_PTR(-EINVAL), and connections like that
    are floating freely through the system.  Most places check whether
    pointer is valid before dereferencing it, but newly added code
    in nfs_match_client does not.
    
    Which causes crashes when more than one NFS mount point is present.
    
    Signed-off-by: Petr Vandrovec <petr@vandrovec.name>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7555ba8..ebecfb8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -314,7 +314,8 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		/* Match the full socket address */
 		if (!rpc_cmp_addr_port(sap, clap))
 			/* Match all xprt_switch full socket addresses */
-			if (!rpc_clnt_xprt_switch_has_addr(clp->cl_rpcclient,
+			if (IS_ERR(clp->cl_rpcclient) ||
+                            !rpc_clnt_xprt_switch_has_addr(clp->cl_rpcclient,
 							   sap))
 				continue;
 
