From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 29 of 54] nfsd4: return callback_ident in callbacks
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018f-A0@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000287-SA
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0005D2-VB
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
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


Pass the callback_ident received in SETCLIENTID to the CB_RECALL rpc.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    1 +
 ./fs/nfsd/nfs4state.c    |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:35:49.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:35:59.000000000 +1100
@@ -247,6 +247,7 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr = {
+		.ident = args->cbr_ident,
 		.nops   = 1,
 	};
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:59.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:59.000000000 +1100
@@ -130,9 +130,11 @@ spinlock_t recall_lock;
 static struct list_head del_recall_lru;
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp, struct svc_fh *current_fh, u32 type)
+alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_fh *current_fh, u32 type)
 {
 	struct nfs4_delegation *dp;
+	struct nfs4_file *fp = stp->st_file;
+	struct nfs4_callback *cb = &stp->st_stateowner->so_client->cl_callback;
 
 	dprintk("NFSD alloc_init_deleg\n");
 	if ((dp = kmalloc(sizeof(struct nfs4_delegation),
@@ -147,7 +149,7 @@ alloc_init_deleg(struct nfs4_client *clp
 	dp->dl_stp = NULL;
 	dp->dl_type = type;
 	dp->dl_recall.cbr_dp = NULL;
-	dp->dl_recall.cbr_ident = 0;
+	dp->dl_recall.cbr_ident = cb->cb_ident;
 	dp->dl_recall.cbr_trunc = 0;
 	dp->dl_stateid.si_boot = boot_time;
 	dp->dl_stateid.si_stateownerid = current_delegid++;
@@ -1666,7 +1668,7 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	else
 		*flag = NFS4_OPEN_DELEGATE_READ;
 
-	dp = alloc_init_deleg(sop->so_client, stp->st_file, fh, *flag);
+	dp = alloc_init_deleg(sop->so_client, stp, fh, *flag);
 	if (dp == NULL) {
 		*flag = NFS4_OPEN_DELEGATE_NONE;
 		return;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
