From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 9 - Minor rearrangements in NFSv4 server code to prepare for mroe state management.
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-000624-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1g-0000vo-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:10 +1000
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

this is the first of several patches against 2.5 concerning NFSv4 state for 
nfsd. it cleans up the names of state structures in preperation for future 
share, lease, byte-range, and delegation patches. specifically, it

1) renames portions of the stateid_t and moves it along with the clientid_t 
from xdr.h into state.h

2) uses xdr_netobj to gather related data and length fields in struct 
nfs4_open (in xdr4.h) (e.g. we have op_fname.data and op_fname.len
instead of op_name and op_namelen).

3) renames NFSD4_CLIENT_MAXNAME to NFS4_OPAQUE_LIMIT which will be used in 
other state fields (not just for name length)

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |    7 +++---
 ./fs/nfsd/nfs4state.c        |    4 +--
 ./fs/nfsd/nfs4xdr.c          |   47 +++++++++++++++++++++----------------------
 ./include/linux/nfsd/state.h |   20 ++++++++++++++++--
 ./include/linux/nfsd/xdr4.h  |   29 +++-----------------------
 5 files changed, 52 insertions(+), 55 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-05-20 16:34:35.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-05-20 16:34:36.000000000 +1000
@@ -50,6 +50,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfs4.h>
+#include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
@@ -80,14 +81,14 @@ do_open_lookup(struct svc_rqst *rqstp, s
 		 * Note: create modes (UNCHECKED,GUARDED...) are the same
 		 * in NFSv4 as in v3.
 		 */
-		status = nfsd_create_v3(rqstp, current_fh, open->op_name,
-					open->op_namelen, &open->op_iattr,
+		status = nfsd_create_v3(rqstp, current_fh, open->op_fname.data,
+					open->op_fname.len, &open->op_iattr,
 					&resfh, open->op_createmode,
 					(u32 *)open->op_verf, &open->op_truncate);
 	}
 	else {
 		status = nfsd_lookup(rqstp, current_fh,
-				     open->op_name, open->op_namelen, &resfh);
+				     open->op_fname.data, open->op_fname.len, &resfh);
 		fh_unlock(current_fh);
 	}
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-05-20 16:34:35.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-05-20 16:34:36.000000000 +1000
@@ -43,8 +43,8 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfs4.h>
-#include <linux/nfsd/xdr4.h>
 #include <linux/nfsd/state.h>
+#include <linux/nfsd/xdr4.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -225,7 +225,7 @@ check_name(struct xdr_netobj name) {
 
 	if (name.len == 0) 
 		return 0;
-	if (name.len > NFSD4_CLIENT_MAXNAME) {
+	if (name.len > NFS4_OPAQUE_LIMIT) {
 		printk("NFSD: check_name: name too long(%d)!\n", name.len);
 		return 0;
 	}

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-05-20 16:34:35.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-05-20 16:34:36.000000000 +1000
@@ -53,6 +53,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/name_lookup.h>
 #include <linux/nfsd/nfsd.h>
+#include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
@@ -483,8 +484,8 @@ nfsd4_decode_close(struct nfsd4_compound
 
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(close->cl_seqid);
-	READ32(close->cl_stateid.st_generation);
-	COPYMEM(&close->cl_stateid.st_other, sizeof(stateid_other_t));
+	READ32(close->cl_stateid.si_generation);
+	COPYMEM(&close->cl_stateid.si_opaque, sizeof(stateid_opaque_t));
 
 	DECODE_TAIL;
 }
@@ -595,11 +596,11 @@ nfsd4_decode_open(struct nfsd4_compounda
 	READ32(open->op_share_access);
 	READ32(open->op_share_deny);
 	COPYMEM(&open->op_clientid, sizeof(clientid_t));
-	READ32(open->op_ownerlen);
+	READ32(open->op_owner.len);
 
 	/* owner, open_flag */
-	READ_BUF(open->op_ownerlen + 4);
-	SAVEMEM(open->op_owner, open->op_ownerlen);
+	READ_BUF(open->op_owner.len + 4);
+	SAVEMEM(open->op_owner.data, open->op_owner.len);
 	READ32(open->op_create);
 	switch (open->op_create) {
 	case NFS4_OPEN_NOCREATE:
@@ -632,10 +633,10 @@ nfsd4_decode_open(struct nfsd4_compounda
 	case NFS4_OPEN_CLAIM_NULL:
 	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
 		READ_BUF(4);
-		READ32(open->op_namelen);
-		READ_BUF(open->op_namelen);
-		SAVEMEM(open->op_name, open->op_namelen);
-		if ((status = check_filename(open->op_name, open->op_namelen, nfserr_inval)))
+		READ32(open->op_fname.len);
+		READ_BUF(open->op_fname.len);
+		SAVEMEM(open->op_fname.data, open->op_fname.len);
+		if ((status = check_filename(open->op_fname.data, open->op_fname.len, nfserr_inval)))
 			return status;
 		break;
 	case NFS4_OPEN_CLAIM_PREVIOUS:
@@ -645,10 +646,10 @@ nfsd4_decode_open(struct nfsd4_compounda
 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
 		READ_BUF(sizeof(delegation_stateid_t) + 4);
 		COPYMEM(&open->op_delegate_stateid, sizeof(delegation_stateid_t));
-		READ32(open->op_namelen);
-		READ_BUF(open->op_namelen);
-		SAVEMEM(open->op_name, open->op_namelen);
-		if ((status = check_filename(open->op_name, open->op_namelen, nfserr_inval)))
+		READ32(open->op_fname.len);
+		READ_BUF(open->op_fname.len);
+		SAVEMEM(open->op_fname.data, open->op_fname.len);
+		if ((status = check_filename(open->op_fname.data, open->op_fname.len, nfserr_inval)))
 			return status;
 		break;
 	default:
@@ -679,8 +680,8 @@ nfsd4_decode_read(struct nfsd4_compounda
 	DECODE_HEAD;
 
 	READ_BUF(sizeof(stateid_t) + 12);
-	READ32(read->rd_stateid.st_generation);
-	COPYMEM(&read->rd_stateid.st_other, sizeof(stateid_other_t));
+	READ32(read->rd_stateid.si_generation);
+	COPYMEM(&read->rd_stateid.si_opaque, sizeof(stateid_opaque_t));
 	READ64(read->rd_offset);
 	READ32(read->rd_length);
 
@@ -755,8 +756,8 @@ nfsd4_decode_setattr(struct nfsd4_compou
 	DECODE_HEAD;
 
 	READ_BUF(sizeof(stateid_t));
-	READ32(setattr->sa_stateid.st_generation);
-	COPYMEM(&setattr->sa_stateid.st_other, sizeof(stateid_other_t));
+	READ32(setattr->sa_stateid.si_generation);
+	COPYMEM(&setattr->sa_stateid.si_opaque, sizeof(stateid_opaque_t));
 	if ((status = nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr)))
 		goto out;
 
@@ -825,8 +826,8 @@ nfsd4_decode_write(struct nfsd4_compound
 	DECODE_HEAD;
 
 	READ_BUF(sizeof(stateid_t) + 16);
-	READ32(write->wr_stateid.st_generation);
-	COPYMEM(&write->wr_stateid.st_other, sizeof(stateid_other_t));
+	READ32(write->wr_stateid.si_generation);
+	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
 	READ64(write->wr_offset);
 	READ32(write->wr_stable_how);
 	if (write->wr_stable_how > 2)
@@ -1543,8 +1544,8 @@ nfsd4_encode_close(struct nfsd4_compound
 
 	if (!nfserr) {
 		RESERVE_SPACE(sizeof(stateid_t));
-		WRITE32(close->cl_stateid.st_generation);
-		WRITEMEM(&close->cl_stateid.st_other, sizeof(stateid_other_t));
+		WRITE32(close->cl_stateid.si_generation);
+		WRITEMEM(&close->cl_stateid.si_opaque, sizeof(stateid_opaque_t));
 		ADJUST_ARGS();
 	}
 }
@@ -1632,8 +1633,8 @@ nfsd4_encode_open(struct nfsd4_compoundr
 		return;
 
 	RESERVE_SPACE(36 + sizeof(stateid_t));
-	WRITE32(open->op_stateid.st_generation);
-	WRITEMEM(&open->op_stateid.st_other, sizeof(stateid_other_t));
+	WRITE32(open->op_stateid.si_generation);
+	WRITEMEM(&open->op_stateid.si_opaque, sizeof(stateid_opaque_t));
 	WRITECINFO(open->op_cinfo);
 	WRITE32(open->op_rflags);
 	WRITE32(2);

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-05-20 16:34:35.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-05-20 16:34:36.000000000 +1000
@@ -39,9 +39,25 @@
 
 #include <linux/list.h>
 
-#define NFSD4_CLIENT_MAXNAME 1024
+#define NFS4_OPAQUE_LIMIT 1024
+typedef struct {
+	u32             cl_boot;
+	u32             cl_id;
+} clientid_t;
 
-extern int nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclid);
+typedef struct {
+	u32             so_boot;
+	u32             so_stateownerid;
+	u32             so_fileid;
+} stateid_opaque_t;
+
+typedef struct {
+	u32                     si_generation;
+	stateid_opaque_t        si_opaque;
+} stateid_t;
+#define si_boot           si_opaque.so_boot
+#define si_stateownerid   si_opaque.so_stateownerid
+#define si_fileid         si_opaque.so_fileid
 
 /*
  * struct nfs4_client - one per client.  Clientids live here.

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-05-20 16:34:35.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2003-05-20 16:34:36.000000000 +1000
@@ -41,27 +41,6 @@
 
 #define NFSD4_MAX_TAGLEN	128
 
-typedef struct {
-	u32		cl_boot;
-	u32		cl_id;
-} clientid_t;
-
-typedef u32 stateid_boot_t;        /* used to detect stale stateids */
-typedef u32 stateid_lockowner_t;   /* lockowner id - used in various places */
-typedef u32 stateid_file_t;        /* identifies a unique file per lockowner */
-typedef u32 stateid_generation_t;  /* used to update stateids */
-
-typedef struct {
-	stateid_boot_t		so_boot;
-	stateid_lockowner_t	so_lockowner;
-	stateid_file_t		so_file;
-} stateid_other_t;
-
-typedef struct {
-	stateid_generation_t	st_generation;
-	stateid_other_t		st_other;
-} stateid_t;
-
 typedef u32 delegation_zero_t;
 typedef u32 delegation_boot_t;
 typedef u64 delegation_id_t;
@@ -143,8 +122,7 @@ struct nfsd4_putfh {
 
 struct nfsd4_open {
 	u32		op_claim_type;      /* request */
-	u32		op_namelen;	    /* request - everything but CLAIM_PREV */
-	char *		op_name;	    /* request - everything but CLAIM_PREV */
+	struct xdr_netobj op_fname;	    /* request - everything but CLAIM_PREV */
 	u32		op_delegate_type;   /* request - CLAIM_PREV only */
 	delegation_stateid_t	op_delegate_stateid; /* request - CLAIM_DELEGATE_CUR only */
 	u32		op_create;     	    /* request */
@@ -155,8 +133,7 @@ struct nfsd4_open {
 		nfs4_verifier	verf;		                     /* EXCLUSIVE4 */
 	} u;
 	clientid_t	op_clientid;        /* request */
-	u32		op_ownerlen;        /* request */
-	char *		op_owner;           /* request */
+	struct xdr_netobj op_owner;           /* request */
 	u32		op_seqid;           /* request */
 	u32		op_share_access;    /* request */
 	u32		op_share_deny;      /* request */
@@ -343,6 +320,8 @@ int nfs4svc_encode_compoundres(struct sv
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 int nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		       struct dentry *dentry, u32 *buffer, int *countp, u32 *bmval);
+extern int nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclid);
+extern int nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm);
 
 #endif
 


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
