From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 5 - Convert readlink to use a separate page for returning symlink contents.
Date: Thu, 07 Nov 2002 11:56:46 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E189ayU-0008K5-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189ayc-0001ca-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 16:56:54 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 7 Nov 2002 11:56:46 +1100
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

This allows NFSv3 to manage 4096byte symlinks. 

Also remove now-unused svcbuf_reserver function.

This was used to reserve space in output buffer
for 'data', but now this is stored in separate page.




 ----------- Diffstat output ------------
 ./drivers/md/raid5.c        |   17 ++++++++---------
 ./fs/nfsd/nfs3proc.c        |   23 ++++-------------------
 ./fs/nfsd/nfs3xdr.c         |   30 +++++++++++++++++++++++++-----
 ./fs/nfsd/nfsproc.c         |   19 ++++---------------
 ./fs/nfsd/nfsxdr.c          |   26 ++++++++++++++++++++++----
 ./include/linux/nfsd/xdr.h  |    9 ++++++++-
 ./include/linux/nfsd/xdr3.h |    9 ++++++++-
 7 files changed, 79 insertions(+), 54 deletions(-)

--- ./drivers/md/raid5.c	2002/11/06 23:07:44	1.3
+++ ./drivers/md/raid5.c	2002/11/06 23:12:49	1.4
@@ -682,10 +682,9 @@ static void compute_parity(struct stripe
 	raid5_conf_t *conf = sh->raid_conf;
 	int i, pd_idx = sh->pd_idx, disks = conf->raid_disks, count;
 	void *ptr[MAX_XOR_BLOCKS];
-	struct bio *chosen[MD_SB_DISKS];
+	struct bio *chosen;
 
 	PRINTK("compute_parity, stripe %llu, method %d\n", (unsigned long long)sh->sector, method);
-	memset(chosen, 0, sizeof(chosen));
 
 	count = 1;
 	ptr[0] = page_address(sh->dev[pd_idx].page);
@@ -699,10 +698,10 @@ static void compute_parity(struct stripe
 			if (sh->dev[i].towrite &&
 			    test_bit(R5_UPTODATE, &sh->dev[i].flags)) {
 				ptr[count++] = page_address(sh->dev[i].page);
-				chosen[i] = sh->dev[i].towrite;
+				chosen = sh->dev[i].towrite;
 				sh->dev[i].towrite = NULL;
 				if (sh->dev[i].written) BUG();
-				sh->dev[i].written = chosen[i];
+				sh->dev[i].written = chosen;
 				check_xor();
 			}
 		}
@@ -711,10 +710,10 @@ static void compute_parity(struct stripe
 		memset(ptr[0], 0, STRIPE_SIZE);
 		for (i= disks; i-- ;)
 			if (i!=pd_idx && sh->dev[i].towrite) {
-				chosen[i] = sh->dev[i].towrite;
+				chosen = sh->dev[i].towrite;
 				sh->dev[i].towrite = NULL;
 				if (sh->dev[i].written) BUG();
-				sh->dev[i].written = chosen[i];
+				sh->dev[i].written = chosen;
 			}
 		break;
 	case CHECK_PARITY:
@@ -726,9 +725,9 @@ static void compute_parity(struct stripe
 	}
 	
 	for (i = disks; i--;)
-		if (chosen[i]) {
+		if (sh->dev[i].written) {
 			sector_t sector = sh->dev[i].sector;
-			copy_data(1, chosen[i], sh->dev[i].page, sector);
+			copy_data(1, sh->dev[i].written, sh->dev[i].page, sector);
 
 			set_bit(R5_LOCKED, &sh->dev[i].flags);
 			set_bit(R5_UPTODATE, &sh->dev[i].flags);
@@ -745,7 +744,7 @@ static void compute_parity(struct stripe
 		break;
 	case READ_MODIFY_WRITE:
 		for (i = disks; i--;)
-			if (chosen[i]) {
+			if (sh->dev[i].written) {
 				ptr[count++] = page_address(sh->dev[i].page);
 				check_xor();
 			}
--- ./include/linux/nfsd/xdr.h	2002/11/06 23:12:16	1.2
+++ ./include/linux/nfsd/xdr.h	2002/11/06 23:12:49	1.3
@@ -57,6 +57,11 @@ struct nfsd_renameargs {
 	int			tlen;
 };
 
+struct nfsd_readlinkargs {
+	struct svc_fh		fh;
+	char *			buffer;
+};
+	
 struct nfsd_linkargs {
 	struct svc_fh		ffh;
 	struct svc_fh		tfh;
@@ -129,7 +134,7 @@ union nfsd_xdrstore {
 
 
 int nfssvc_decode_void(struct svc_rqst *, u32 *, void *);
-int nfssvc_decode_fhandle(struct svc_rqst *, u32 *, struct svc_fh *);
+int nfssvc_decode_fhandle(struct svc_rqst *, u32 *, struct nfsd_fhandle *);
 int nfssvc_decode_sattrargs(struct svc_rqst *, u32 *,
 				struct nfsd_sattrargs *);
 int nfssvc_decode_diropargs(struct svc_rqst *, u32 *,
@@ -142,6 +147,8 @@ int nfssvc_decode_createargs(struct svc_
 				struct nfsd_createargs *);
 int nfssvc_decode_renameargs(struct svc_rqst *, u32 *,
 				struct nfsd_renameargs *);
+int nfssvc_decode_readlinkargs(struct svc_rqst *, u32 *,
+				struct nfsd_readlinkargs *);
 int nfssvc_decode_linkargs(struct svc_rqst *, u32 *,
 				struct nfsd_linkargs *);
 int nfssvc_decode_symlinkargs(struct svc_rqst *, u32 *,
--- ./include/linux/nfsd/xdr3.h	2002/11/06 23:12:16	1.2
+++ ./include/linux/nfsd/xdr3.h	2002/11/06 23:12:49	1.3
@@ -74,6 +74,11 @@ struct nfsd3_renameargs {
 	int			tlen;
 };
 
+struct nfsd3_readlinkargs {
+	struct svc_fh		fh;
+	char *			buffer;
+};
+
 struct nfsd3_linkargs {
 	struct svc_fh		ffh;
 	struct svc_fh		tfh;
@@ -239,7 +244,7 @@ union nfsd3_xdrstore {
 
 #define NFS3_SVC_XDRSIZE		sizeof(union nfsd3_xdrstore)
 
-int nfs3svc_decode_fhandle(struct svc_rqst *, u32 *, struct svc_fh *);
+int nfs3svc_decode_fhandle(struct svc_rqst *, u32 *, struct nfsd_fhandle *);
 int nfs3svc_decode_sattrargs(struct svc_rqst *, u32 *,
 				struct nfsd3_sattrargs *);
 int nfs3svc_decode_diropargs(struct svc_rqst *, u32 *,
@@ -258,6 +263,8 @@ int nfs3svc_decode_mknodargs(struct svc_
 				struct nfsd3_mknodargs *);
 int nfs3svc_decode_renameargs(struct svc_rqst *, u32 *,
 				struct nfsd3_renameargs *);
+int nfs3svc_decode_readlinkargs(struct svc_rqst *, u32 *,
+				struct nfsd3_readlinkargs *);
 int nfs3svc_decode_linkargs(struct svc_rqst *, u32 *,
 				struct nfsd3_linkargs *);
 int nfs3svc_decode_symlinkargs(struct svc_rqst *, u32 *,
--- ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:23	1.4
+++ ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:49	1.5
@@ -188,9 +188,9 @@ nfssvc_decode_void(struct svc_rqst *rqst
 }
 
 int
-nfssvc_decode_fhandle(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
+nfssvc_decode_fhandle(struct svc_rqst *rqstp, u32 *p, struct nfsd_fhandle *args)
 {
-	if (!(p = decode_fh(p, fhp)))
+	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 	return xdr_argsize_check(rqstp, p);
 }
@@ -305,6 +305,17 @@ nfssvc_decode_renameargs(struct svc_rqst
 }
 
 int
+nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, u32 *p, struct nfsd_readlinkargs *args)
+{
+	if (!(p = decode_fh(p, &args->fh)))
+		return 0;
+	svc_take_page(rqstp);
+	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
+
+	return xdr_argsize_check(rqstp, p);
+}
+
+int
 nfssvc_decode_linkargs(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_linkargs *args)
 {
@@ -377,8 +388,15 @@ nfssvc_encode_readlinkres(struct svc_rqs
 					struct nfsd_readlinkres *resp)
 {
 	*p++ = htonl(resp->len);
-	p += XDR_QUADLEN(resp->len);
-	return xdr_ressize_check(rqstp, p);
+	xdr_ressize_check(rqstp, p);
+	rqstp->rq_res.page_len = resp->len;
+	if (resp->len & 3) {
+		/* need to pad the tail */
+		rqstp->rq_res.tail[0].iov_base = p;
+		*p = 0;
+		rqstp->rq_res.tail[0].iov_len = 4 - (resp->len&3);
+	}
+	return 1;
 }
 
 int
--- ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:23	1.4
+++ ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:49	1.5
@@ -275,9 +275,9 @@ encode_wcc_data(struct svc_rqst *rqstp, 
  * XDR decode functions
  */
 int
-nfs3svc_decode_fhandle(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
+nfs3svc_decode_fhandle(struct svc_rqst *rqstp, u32 *p, struct nfsd_fhandle *args)
 {
-	if (!(p = decode_fh(p, fhp)))
+	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 	return xdr_argsize_check(rqstp, p);
 }
@@ -468,6 +468,18 @@ nfs3svc_decode_renameargs(struct svc_rqs
 }
 
 int
+nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, u32 *p,
+					struct nfsd3_readlinkargs *args)
+{
+	if (!(p = decode_fh(p, &args->fh)))
+		return 0;
+	svc_take_page(rqstp);
+	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
+
+	return xdr_argsize_check(rqstp, p);
+}
+
+int
 nfs3svc_decode_linkargs(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd3_linkargs *args)
 {
@@ -592,9 +604,17 @@ nfs3svc_encode_readlinkres(struct svc_rq
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
 	if (resp->status == 0) {
 		*p++ = htonl(resp->len);
-		p += XDR_QUADLEN(resp->len);
-	}
-	return xdr_ressize_check(rqstp, p);
+		xdr_ressize_check(rqstp, p);
+		rqstp->rq_res.page_len = resp->len;
+		if (resp->len & 3) {
+			/* need to pad the tail */
+			rqstp->rq_res.tail[0].iov_base = p;
+			*p = 0;
+			rqstp->rq_res.tail[0].iov_len = 4 - (resp->len&3);
+		}
+		return 1;
+	} else
+		return xdr_ressize_check(rqstp, p);
 }
 
 /* READ */
--- ./fs/nfsd/nfsproc.c	2002/11/06 23:12:16	1.2
+++ ./fs/nfsd/nfsproc.c	2002/11/06 23:12:49	1.3
@@ -30,13 +30,6 @@ typedef struct svc_buf	svc_buf;
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 
-static inline void
-svcbuf_reserve(struct xdr_buf *buf, u32 **ptr, int *len, int nr)
-{
-	*ptr = (u32*)(buf->head[0].iov_base+buf->head[0].iov_len) + nr;
-	*len = ((PAGE_SIZE-buf->head[0].iov_len)>>2) - nr;
-}
-
 static int
 nfsd_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
 {
@@ -100,20 +93,16 @@ nfsd_proc_lookup(struct svc_rqst *rqstp,
  * Read a symlink.
  */
 static int
-nfsd_proc_readlink(struct svc_rqst *rqstp, struct nfsd_fhandle     *argp,
+nfsd_proc_readlink(struct svc_rqst *rqstp, struct nfsd_readlinkargs *argp,
 					   struct nfsd_readlinkres *resp)
 {
-	u32		*path;
-	int		dummy, nfserr;
+	int	nfserr;
 
 	dprintk("nfsd: READLINK %s\n", SVCFH_fmt(&argp->fh));
 
-	/* Reserve room for status and path length */
-	svcbuf_reserve(&rqstp->rq_res, &path, &dummy, 2);
-
 	/* Read the symlink. */
 	resp->len = NFS_MAXPATHLEN;
-	nfserr = nfsd_readlink(rqstp, &argp->fh, (char *) path, &resp->len);
+	nfserr = nfsd_readlink(rqstp, &argp->fh, argp->buffer, &resp->len);
 
 	fh_put(&argp->fh);
 	return nfserr;
@@ -545,7 +534,7 @@ static struct svc_procedure		nfsd_proced
   PROC(setattr,  sattrargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
   PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT),
-  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4),
+  PROC(readlink, readlinkargs,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4),
   PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE),
   PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
--- ./fs/nfsd/nfs3proc.c	2002/11/06 23:12:16	1.2
+++ ./fs/nfsd/nfs3proc.c	2002/11/06 23:12:49	1.3
@@ -41,16 +41,6 @@ static int	nfs3_ftypes[] = {
 };
 
 /*
- * Reserve room in the send buffer
- */
-static inline void
-svcbuf_reserve(struct xdr_buf *buf, u32 **ptr, int *len, int nr)
-{
-	*ptr = (u32*)(buf->head[0].iov_base+buf->head[0].iov_len) + nr;
-	*len = ((PAGE_SIZE-buf->head[0].iov_len)>>2) - nr;
-}
-
-/*
  * NULL call.
  */
 static int
@@ -141,22 +131,17 @@ nfsd3_proc_access(struct svc_rqst *rqstp
  * Read a symlink.
  */
 static int
-nfsd3_proc_readlink(struct svc_rqst *rqstp, struct nfsd_fhandle     *argp,
+nfsd3_proc_readlink(struct svc_rqst *rqstp, struct nfsd3_readlinkargs *argp,
 					   struct nfsd3_readlinkres *resp)
 {
-	u32		*path;
-	int		dummy, nfserr;
+	int nfserr;
 
 	dprintk("nfsd: READLINK(3) %s\n", SVCFH_fmt(&argp->fh));
 
-	/* Reserve room for status, post_op_attr, and path length */
-	svcbuf_reserve(&rqstp->rq_res, &path, &dummy,
-				1 + NFS3_POST_OP_ATTR_WORDS + 1);
-
 	/* Read the symlink. */
 	fh_copy(&resp->fh, &argp->fh);
 	resp->len = NFS3_MAXPATHLEN;
-	nfserr = nfsd_readlink(rqstp, &resp->fh, (char *) path, &resp->len);
+	nfserr = nfsd_readlink(rqstp, &resp->fh, argp->buffer, &resp->len);
 	RETURN_STATUS(nfserr);
 }
 
@@ -669,7 +654,7 @@ static struct svc_procedure		nfsd_proced
   PROC(setattr,  sattr,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
   PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT),
   PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1),
-  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4),
+  PROC(readlink, readlink,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4),
   PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE),
   PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4),
   PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
