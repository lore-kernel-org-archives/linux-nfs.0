From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 8 - NFSv4 patch for new setclientid, setclientid_confirm
Date: Wed, 16 Oct 2002 16:03:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH1-0000JQ-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHC-0002mm-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 16 Oct 2002 16:03:17 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

From: "William A.(Andy) Adamson" <andros@citi.umich.edu>

this patch brings the linux-2.5.42 tree up to spec WRT setclientid and 
setclientid_confirm

-->Andy


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c        |    3 ++-
 ./fs/nfsd/nfs4xdr.c         |   10 ++++++----
 ./include/linux/nfsd/xdr4.h |    8 +++++++-
 3 files changed, 15 insertions(+), 6 deletions(-)

--- ./fs/nfsd/nfs4proc.c	2002/10/16 04:45:56	1.2
+++ ./fs/nfsd/nfs4proc.c	2002/10/16 04:47:27	1.3
@@ -177,11 +177,12 @@ static inline int
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclientid)
 {
 	memset(&setclientid->se_clientid, 0, sizeof(clientid_t));
+	memset(&setclientid->se_confirm, 0, sizeof(nfs4_verifier));
 	return nfs_ok;
 }
 
 static inline int
-nfsd4_setclientid_confirm(struct svc_rqst *rqstp, clientid_t *clientid)
+nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
 	return nfs_ok;
 }
--- ./fs/nfsd/nfs4xdr.c	2002/10/16 04:47:24	1.1
+++ ./fs/nfsd/nfs4xdr.c	2002/10/16 04:47:27	1.2
@@ -717,12 +717,13 @@ nfsd4_decode_setclientid(struct nfsd4_co
 }
 
 static int
-nfsd4_decode_setclientid_confirm(struct nfsd4_compoundargs *argp, clientid_t *clientid)
+nfsd4_decode_setclientid_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_setclientid_confirm *scd_c)
 {
 	DECODE_HEAD;
 
-	READ_BUF(8);
-	COPYMEM(clientid, 8);
+	READ_BUF(8 + sizeof(nfs4_verifier));
+	COPYMEM(&scd_c->sc_clientid, 8);
+	COPYMEM(&scd_c->sc_confirm, sizeof(nfs4_verifier));
 
 	DECODE_TAIL;
 }
@@ -1736,8 +1737,9 @@ nfsd4_encode_setclientid(struct nfsd4_co
 	ENCODE_HEAD;
 
 	if (!nfserr) {
-		RESERVE_SPACE(8);
+		RESERVE_SPACE(8 + sizeof(nfs4_verifier));
 		WRITEMEM(&scd->se_clientid, 8);
+		WRITEMEM(&scd->se_confirm, sizeof(nfs4_verifier));
 		ADJUST_ARGS();
 	}
 	else if (nfserr == nfserr_clid_inuse) {
--- ./include/linux/nfsd/xdr4.h	2002/10/16 04:45:57	1.2
+++ ./include/linux/nfsd/xdr4.h	2002/10/16 04:47:27	1.3
@@ -224,6 +224,12 @@ struct nfsd4_setclientid {
 	char *		se_callback_addr_val;   /* request */
 	u32		se_callback_ident;  /* request */
 	clientid_t	se_clientid;        /* response */
+	nfs4_verifier	se_confirm;         /* response */
+};
+
+struct nfsd4_setclientid_confirm {
+	clientid_t	sc_clientid;
+	nfs4_verifier	sc_confirm;
 };
 
 /* also used for NVERIFY */
@@ -267,7 +273,7 @@ struct nfsd4_op {
 		clientid_t			renew;
 		struct nfsd4_setattr		setattr;
 		struct nfsd4_setclientid	setclientid;
-		clientid_t			setclientid_confirm;
+		struct nfsd4_setclientid_confirm setclientid_confirm;
 		struct nfsd4_verify		verify;
 		struct nfsd4_write		write;
 	} u;


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
