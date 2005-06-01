From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 025 of 28] nfsd4: remove cb_parsed
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006ix-SG@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3I-0005vZ-6O
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0002Pj-Te
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:07 -0700
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


The cb_parsed field is only used by probe_callback, to determine whether the
callback information has been filled in by setclientid.  But there is no way
that probe_callback() can be called without that having already happened, so
that check is superfluous, as is cb_parsed.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c     |    4 +---
 ./fs/nfsd/nfs4state.c        |    5 +----
 ./include/linux/nfsd/state.h |    1 -
 3 files changed, 2 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-05-31 14:21:03.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2005-05-31 14:21:07.000000000 +1000
@@ -386,9 +386,7 @@ nfsd4_probe_callback(struct nfs4_client 
 	char                    hostname[32];
 	int status;
 
-	dprintk("NFSD: probe_callback. cb_parsed %d cb_set %d\n",
-			cb->cb_parsed, atomic_read(&cb->cb_set));
-	if (!cb->cb_parsed || atomic_read(&cb->cb_set))
+	if (atomic_read(&cb->cb_set))
 		return;
 
 	/* Initialize address */

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:06.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:07.000000000 +1000
@@ -377,7 +377,6 @@ create_client(struct xdr_netobj name, ch
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_count, 1);
 	atomic_set(&clp->cl_callback.cb_set, 0);
-	clp->cl_callback.cb_parsed = 0;
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
@@ -620,14 +619,12 @@ gen_callback(struct nfs4_client *clp, st
 		goto out_err;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
-	cb->cb_parsed = 1;
 	return;
 out_err:
 	printk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
 		"will not receive delegations\n",
 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
 
-	cb->cb_parsed = 0;
 	return;
 }
 
@@ -872,7 +869,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		else {
 			/* XXX: We just turn off callbacks until we can handle
 			  * change request correctly. */
-			conf->cl_callback.cb_parsed = 0;
+			atomic_set(&conf->cl_callback.cb_set, 0);
 			gen_confirm(conf);
 			expire_client(unconf);
 			status = nfs_ok;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-05-31 14:21:06.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-05-31 14:21:07.000000000 +1000
@@ -92,7 +92,6 @@ struct nfs4_delegation {
 /* client delegation callback info */
 struct nfs4_callback {
 	/* SETCLIENTID info */
-	u32			cb_parsed;  /* addr parsed */
 	u32                     cb_addr;
 	unsigned short          cb_port;
 	u32                     cb_prog;


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
