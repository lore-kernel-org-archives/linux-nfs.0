From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 21 of 23] Add the DELEGRETURN operation.
Date: Fri, 17 Dec 2004 16:23:57 +1100
Message-ID: <E1CfAar-0002ei-Ci@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAc1-0005BI-CD
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbz-0006Ar-2N
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:09 -0800
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
 ./fs/nfsd/nfs4proc.c        |    3 +++
 ./fs/nfsd/nfs4state.c       |   16 ++++++++++++++++
 ./fs/nfsd/nfs4xdr.c         |   17 +++++++++++++++++
 ./include/linux/nfsd/xdr4.h |    7 +++++++
 4 files changed, 43 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-12-15 13:37:21.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-12-15 13:37:51.000000000 +1100
@@ -840,6 +840,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		case OP_CREATE:
 			op->status = nfsd4_create(rqstp, current_fh, &op->u.create);
 			break;
+		case OP_DELEGRETURN:
+			op->status = nfsd4_delegreturn(rqstp, current_fh, &op->u.delegreturn);
+			break;
 		case OP_GETATTR:
 			op->status = nfsd4_getattr(rqstp, current_fh, &op->u.getattr);
 			break;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:51.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:51.000000000 +1100
@@ -2332,6 +2332,22 @@ out:
 	return status;
 }
 
+int
+nfsd4_delegreturn(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_delegreturn *dr)
+{
+	int status;
+
+	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0)))
+		goto out;
+
+	nfs4_lock_state();
+	status = nfs4_preprocess_stateid_op(current_fh, &dr->dr_stateid, DELEG_RET);
+	nfs4_unlock_state();
+out:
+	return status;
+}
+
+
 /* 
  * Lock owner state (byte-range locks)
  */

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-12-15 13:37:21.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-12-15 13:37:51.000000000 +1100
@@ -615,6 +615,18 @@ nfsd4_decode_create(struct nfsd4_compoun
 }
 
 static inline int
+nfsd4_decode_delegreturn(struct nfsd4_compoundargs *argp, struct nfsd4_delegreturn *dr)
+{
+	DECODE_HEAD;
+
+	READ_BUF(sizeof(stateid_t));
+	READ32(dr->dr_stateid.si_generation);
+	COPYMEM(&dr->dr_stateid.si_opaque, sizeof(stateid_opaque_t));
+
+	DECODE_TAIL;
+}
+
+static inline int
 nfsd4_decode_getattr(struct nfsd4_compoundargs *argp, struct nfsd4_getattr *getattr)
 {
 	return nfsd4_decode_bitmap(argp, getattr->ga_bmval);
@@ -1170,6 +1182,9 @@ nfsd4_decode_compound(struct nfsd4_compo
 		case OP_CREATE:
 			op->status = nfsd4_decode_create(argp, &op->u.create);
 			break;
+		case OP_DELEGRETURN:
+			op->status = nfsd4_decode_delegreturn(argp, &op->u.delegreturn);
+			break;
 		case OP_GETATTR:
 			op->status = nfsd4_decode_getattr(argp, &op->u.getattr);
 			break;
@@ -2451,6 +2466,8 @@ nfsd4_encode_operation(struct nfsd4_comp
 	case OP_CREATE:
 		nfsd4_encode_create(resp, op->status, &op->u.create);
 		break;
+	case OP_DELEGRETURN:
+		break;
 	case OP_GETATTR:
 		op->status = nfsd4_encode_getattr(resp, op->status, &op->u.getattr);
 		break;

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-12-15 13:37:21.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2004-12-15 13:37:51.000000000 +1100
@@ -94,6 +94,10 @@ struct nfsd4_create {
 #define cr_specdata1	u.dev.specdata1
 #define cr_specdata2	u.dev.specdata2
 
+struct nfsd4_delegreturn {
+	stateid_t	dr_stateid;
+};
+
 struct nfsd4_getattr {
 	u32		ga_bmval[2];        /* request */
 	struct svc_fh	*ga_fhp;            /* response */
@@ -335,6 +339,7 @@ struct nfsd4_op {
 		struct nfsd4_close		close;
 		struct nfsd4_commit		commit;
 		struct nfsd4_create		create;
+		struct nfsd4_delegreturn	delegreturn;
 		struct nfsd4_getattr		getattr;
 		struct svc_fh *			getfh;
 		struct nfsd4_link		link;
@@ -446,6 +451,8 @@ extern int
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		struct nfsd4_release_lockowner *rlockowner);
 extern void nfsd4_release_compoundargs(struct nfsd4_compoundargs *);
+extern int nfsd4_delegreturn(struct svc_rqst *rqstp,
+		struct svc_fh *current_fh, struct nfsd4_delegreturn *dr);
 #endif
 
 /*


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
