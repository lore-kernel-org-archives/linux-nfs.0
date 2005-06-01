From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 007 of 28] nfsd4: delegation recovery
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006hz-B9@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3X-0005y9-7e
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:23 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3V-0002Sc-Uf
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:22 -0700
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


Allow recovery of delegations after reboot.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |   36 ++++++++++++++++++++++++++++--------
 ./fs/nfsd/nfs4xdr.c         |    2 +-
 ./include/linux/nfsd/xdr4.h |    1 +
 3 files changed, 30 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:20:59.000000000 +1000
@@ -1709,14 +1709,30 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	int status, flag = 0;
 
 	flag = NFS4_OPEN_DELEGATE_NONE;
-	if (open->op_claim_type != NFS4_OPEN_CLAIM_NULL
-	     || !atomic_read(&cb->cb_set) || !sop->so_confirmed)
-		goto out;
-
-	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
-		flag = NFS4_OPEN_DELEGATE_WRITE;
-	else
-		flag = NFS4_OPEN_DELEGATE_READ;
+	open->op_recall = 0;
+	switch (open->op_claim_type) {
+		case NFS4_OPEN_CLAIM_PREVIOUS:
+			if (!atomic_read(&cb->cb_set))
+				open->op_recall = 1;
+			flag = open->op_delegate_type;
+			if (flag == NFS4_OPEN_DELEGATE_NONE)
+				goto out;
+			break;
+		case NFS4_OPEN_CLAIM_NULL:
+			/* Let's not give out any delegations till everyone's
+			 * had the chance to reclaim theirs.... */
+			if (nfs4_in_grace())
+				goto out;
+			if (!atomic_read(&cb->cb_set) || !sop->so_confirmed)
+				goto out;
+			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
+				flag = NFS4_OPEN_DELEGATE_WRITE;
+			else
+				flag = NFS4_OPEN_DELEGATE_READ;
+			break;
+		default:
+			goto out;
+	}
 
 	dp = alloc_init_deleg(sop->so_client, stp, fh, flag);
 	if (dp == NULL) {
@@ -1750,6 +1766,10 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	             dp->dl_stateid.si_fileid,
 	             dp->dl_stateid.si_generation);
 out:
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
+			&& flag == NFS4_OPEN_DELEGATE_NONE
+			&& open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
+		printk("NFSD: WARNING: refusing delegation reclaim\n");
 	open->op_delegate_type = flag;
 }
 

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2005-05-31 14:20:59.000000000 +1000
@@ -1972,7 +1972,7 @@ nfsd4_encode_open(struct nfsd4_compoundr
 	case NFS4_OPEN_DELEGATE_READ:
 		RESERVE_SPACE(20 + sizeof(stateid_t));
 		WRITEMEM(&open->op_delegate_stateid, sizeof(stateid_t));
-		WRITE32(0);
+		WRITE32(open->op_recall);
 
 		/*
 		 * TODO: ACE's in delegations

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2005-05-31 14:20:59.000000000 +1000
@@ -210,6 +210,7 @@ struct nfsd4_open {
 	u32		op_share_access;    /* request */
 	u32		op_share_deny;      /* request */
 	stateid_t	op_stateid;         /* response */
+	u32		op_recall;          /* recall */
 	struct nfsd4_change_info  op_cinfo; /* response */
 	u32		op_rflags;          /* response */
 	int		op_truncate;        /* used during processing */


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
