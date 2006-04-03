From: NeilBrown <neilb@suse.de>
Subject: [PATCH 013 of 16] knfsd: nfsd4: nfsd4_probe_callback cleanup
Date: Mon, 3 Apr 2006 15:19:10 +1000
Message-ID: <1060403051910.1881@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751487AbWDCFXg@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


Some obvious cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2006-04-03 15:12:16.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2006-04-03 15:12:16.000000000 +1000
@@ -441,8 +441,9 @@ nfsd4_probe_callback(struct nfs4_client 
 		goto out_clnt;
 	}
 
-	/* the task holds a reference to the nfs4_client struct */
 	cb->cb_client = clnt;
+
+	/* the task holds a reference to the nfs4_client struct */
 	atomic_inc(&clp->cl_count);
 
 	msg.rpc_cred = nfsd4_lookupcred(clp,0);
@@ -460,13 +461,12 @@ nfsd4_probe_callback(struct nfs4_client 
 out_rpciod:
 	atomic_dec(&clp->cl_count);
 	rpciod_down();
+	cb->cb_client = NULL;
 out_clnt:
 	rpc_shutdown_client(clnt);
-	goto out_err;
 out_err:
 	dprintk("NFSD: warning: no callback path to client %.*s\n",
 		(int)clp->cl_name.len, clp->cl_name.data);
-	cb->cb_client = NULL;
 }
 
 static void
