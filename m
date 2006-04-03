From: NeilBrown <neilb@suse.de>
Subject: [PATCH 014 of 16] knfsd: nfsd4: add missing rpciod_down()
Date: Mon, 3 Apr 2006 15:19:15 +1000
Message-ID: <1060403051915.1893@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHUu-0005XJ-SJ
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:21:04 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHUu-0008SH-43
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:21:04 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


We should be shutting down rpciod for the callback channel when we shut down
the server.

Also note that we do rpciod_up() and create the callback client *before*
setting cb_set--the cb_set only determines whether the initial null was
succesful.  So cb_set is not a reliable determiner of whether we need to
clean up, only cb_client is.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-04-03 15:12:16.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-04-03 15:12:16.000000000 +1000
@@ -330,22 +330,29 @@ put_nfs4_client(struct nfs4_client *clp)
 }
 
 static void
+shutdown_callback_client(struct nfs4_client *clp)
+{
+	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+
+	/* shutdown rpc client, ending any outstanding recall rpcs */
+	if (clnt) {
+		clp->cl_callback.cb_client = NULL;
+		rpc_shutdown_client(clnt);
+		rpciod_down();
+	}
+}
+
+static void
 expire_client(struct nfs4_client *clp)
 {
 	struct nfs4_stateowner *sop;
 	struct nfs4_delegation *dp;
-	struct nfs4_callback *cb = &clp->cl_callback;
-	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
 	struct list_head reaplist;
 
 	dprintk("NFSD: expire_client cl_count %d\n",
 	                    atomic_read(&clp->cl_count));
 
-	/* shutdown rpc client, ending any outstanding recall rpcs */
-	if (atomic_read(&cb->cb_set) == 1 && clnt) {
-		rpc_shutdown_client(clnt);
-		clnt = clp->cl_callback.cb_client = NULL;
-	}
+	shutdown_callback_client(clp);
 
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
