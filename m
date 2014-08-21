Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123AbaHUVeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2014 17:34:22 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1XKZzy-0001Sc-0u
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 17:34:22 -0400
Date: Thu, 21 Aug 2014 17:34:21 -0400
To: linux-nfs@vger.kernel.org
Subject: kernel not recovering from statd port change
Message-ID: <20140821213421.GA5474@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While testing server restart somebody noticed that knfsd can't recover
from statd restarting with a new port.

>From only a very quick skim of the code it looked like creating the nsm
client with RPC_CLNT_CREATE_AUTOBIND should cause us to call rpcbind
again on connection failures, but that doesn't seem to be working.

Any ideas?  I'll keep looking....

--b.

commit 2c9fb5570fe2
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Aug 20 17:21:32 2014 -0400

    lockd: allow rebinding to statd
    
    During normal operation statd isn't restarted, but it may be if, for
    example, the server is shut down and restarted to simulate a shutdown or
    perform some kind of failover.  In that case the kernel may need to
    query rpcbind again to get statd's new port number.
    
    Symptoms were locking failures after a manual server restart (without
    rebooting the machine), and loopback network traces showing the new
    kernel nfsd attempting to contact statd at its old port number.
    
    This was probably introduced by cb7323fffa85, which first allowed
    reusing the statd rpc client, but it looks like a reference count may
    typically have prevented any symptoms until e498daa81295 "LOCKD: Clear
    ln->nsm_clnt only when ln->nsm_users is zero".
    
    Fixes: cb7323fffa85 "lockd: create and use per-net NSM RPC clients on MON/UNMON requests"
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 1812f026960c..3bce1d318435 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -80,7 +80,8 @@ static struct rpc_clnt *nsm_create(struct net *net)
 		.program		= &nsm_program,
 		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
-		.flags			= RPC_CLNT_CREATE_NOPING,
+		.flags			= RPC_CLNT_CREATE_NOPING|
+			                  RPC_CLNT_CREATE_AUTOBIND,
 	};
 
 	return rpc_create(&args);
