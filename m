From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 12 of 23] Changes to expire_client
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002e8-CS@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbM-00059d-UR
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:28 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbJ-00066i-Dl
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:28 -0800
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


... to shutdown the rpc callback client and remove all 
client associated delegations

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 12:04:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 12:05:08.000000000 +1100
@@ -335,8 +335,29 @@ static void
 expire_client(struct nfs4_client *clp)
 {
 	struct nfs4_stateowner *sop;
+	struct nfs4_delegation *dp;
+	struct nfs4_callback *cb = &clp->cl_callback;
+	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+
+	dprintk("NFSD: expire_client cl_count %d\n",
+	                    atomic_read(&clp->cl_count));
 
-	dprintk("NFSD: expire_client cl_count %d\n",atomic_read(&clp->cl_count));
+	/* shutdown rpc client, ending any outstanding recall rpcs */
+	if (atomic_read(&cb->cb_set) == 1 && clnt) {
+		rpc_shutdown_client(clnt);
+		clnt = clp->cl_callback.cb_client = NULL;
+	}
+	spin_lock(&recall_lock);
+	while (!list_empty(&clp->cl_del_perclnt)) {
+		dp = list_entry(clp->cl_del_perclnt.next, struct nfs4_delegation, dl_del_perclnt);
+		dprintk("NFSD: expire client. dp %p, dl_state %d, fp %p\n",
+				dp, atomic_read(&dp->dl_state), dp->dl_flock);
+
+		/* force release of delegation. */
+		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+		release_delegation(dp);
+	}
+	spin_unlock(&recall_lock);
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
 	list_del(&clp->cl_lru);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
