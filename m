From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 7 of 23] Get rid of the special delegation_stateid_t, use the existing stateid_t.
Date: Fri, 17 Dec 2004 16:23:55 +1100
Message-ID: <E1CfAap-0002do-Uj@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAb1-00058F-MA
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:07 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAb0-00064y-MB
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:07 -0800
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


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c         |   12 ++++++------
 ./include/linux/nfsd/xdr4.h |   16 +++-------------
 2 files changed, 9 insertions(+), 19 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-12-15 11:57:44.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-12-15 11:57:44.000000000 +1100
@@ -790,8 +790,8 @@ nfsd4_decode_open(struct nfsd4_compounda
 		READ32(open->op_delegate_type);
 		break;
 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
-		READ_BUF(sizeof(delegation_stateid_t) + 4);
-		COPYMEM(&open->op_delegate_stateid, sizeof(delegation_stateid_t));
+		READ_BUF(sizeof(stateid_t) + 4);
+		COPYMEM(&open->op_delegate_stateid, sizeof(stateid_t));
 		READ32(open->op_fname.len);
 		READ_BUF(open->op_fname.len);
 		SAVEMEM(open->op_fname.data, open->op_fname.len);
@@ -2072,8 +2072,8 @@ nfsd4_encode_open(struct nfsd4_compoundr
 	case NFS4_OPEN_DELEGATE_NONE:
 		break;
 	case NFS4_OPEN_DELEGATE_READ:
-		RESERVE_SPACE(20 + sizeof(delegation_stateid_t));
-		WRITEMEM(&open->op_delegate_stateid, sizeof(delegation_stateid_t));
+		RESERVE_SPACE(20 + sizeof(stateid_t));
+		WRITEMEM(&open->op_delegate_stateid, sizeof(stateid_t));
 		WRITE32(0);
 
 		/*
@@ -2086,8 +2086,8 @@ nfsd4_encode_open(struct nfsd4_compoundr
 		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
-		RESERVE_SPACE(32 + sizeof(delegation_stateid_t));
-		WRITEMEM(&open->op_delegate_stateid, sizeof(delegation_stateid_t));
+		RESERVE_SPACE(32 + sizeof(stateid_t));
+		WRITEMEM(&open->op_delegate_stateid, sizeof(stateid_t));
 		WRITE32(0);
 
 		/*

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-12-15 11:57:44.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2004-12-15 11:57:44.000000000 +1100
@@ -44,16 +44,6 @@
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
-typedef u32 delegation_zero_t;
-typedef u32 delegation_boot_t;
-typedef u64 delegation_id_t;
-
-typedef struct {
-	delegation_zero_t	ds_zero;
-	delegation_boot_t	ds_boot;
-	delegation_id_t		ds_id;
-} delegation_stateid_t;
-
 struct nfsd4_change_info {
 	u32		atomic;
 	u32		before_ctime_sec;
@@ -202,13 +192,13 @@ struct nfsd4_open {
 	u32		op_claim_type;      /* request */
 	struct xdr_netobj op_fname;	    /* request - everything but CLAIM_PREV */
 	u32		op_delegate_type;   /* request - CLAIM_PREV only */
-	delegation_stateid_t	op_delegate_stateid; /* request - CLAIM_DELEGATE_CUR only */
+	stateid_t       op_delegate_stateid; /* request - response */
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
 	u32		op_bmval[2];        /* request */
 	union {                             /* request */
-		struct iattr	iattr;		            /* UNCHECKED4,GUARDED4 */
-		nfs4_verifier	verf;		                     /* EXCLUSIVE4 */
+		struct iattr	iattr;                      /* UNCHECKED4,GUARDED4 */
+		nfs4_verifier	verf;                                /* EXCLUSIVE4 */
 	} u;
 	clientid_t	op_clientid;        /* request */
 	struct xdr_netobj op_owner;           /* request */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
