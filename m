From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 5 - nfsd_readdir changes.
Date: Thu, 31 Oct 2002 11:08:21 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021031000821.29585@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872sy-00065e-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 16:08:32 -0800
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

nfsd_readdir - the common readdir code for all version of nfsd,
contains a number of version-specific things with appropriate checks, 
and also does some xdr-encoding which rightly belongs elsewhere.

This patch simplifies nfsd_readdir to do just the core stuff, and moves
the version specifics into version specific files, and the xdr encoding
into xdr encoding files.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c        |   31 ++++++++++++++-----
 ./fs/nfsd/nfs3xdr.c         |   22 ++++++-------
 ./fs/nfsd/nfs4xdr.c         |   57 ++++++++++++++++++++---------------
 ./fs/nfsd/nfsproc.c         |   16 +++++++---
 ./fs/nfsd/nfsxdr.c          |   15 ++++++---
 ./fs/nfsd/vfs.c             |   70 +++++++++-----------------------------------
 ./include/linux/nfsd/nfsd.h |   22 ++++---------
 ./include/linux/nfsd/xdr.h  |    5 +++
 ./include/linux/nfsd/xdr3.h |    7 ++++
 ./include/linux/nfsd/xdr4.h |    5 +++
 10 files changed, 129 insertions(+), 121 deletions(-)

--- ./fs/nfsd/vfs.c	2002/10/30 22:40:45	1.1
+++ ./fs/nfsd/vfs.c	2002/10/30 22:40:51	1.2
@@ -1386,16 +1386,15 @@ out_nfserr:
 
 /*
  * Read entries from a directory.
- * The verifier is an NFSv3 thing we ignore for now.
+ * The  NFSv3/4 verifier we ignore for now.
  */
 int
-nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset, 
-             encode_dent_fn func, u32 *buffer, int *countp, u32 *verf, u32 *bmval)
+nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp, 
+	     struct readdir_cd *cdp, encode_dent_fn func)
 {
-	u32		*p;
-	int		oldlen, eof, err;
+	int		err;
 	struct file	file;
-	struct readdir_cd cd;
+	loff_t		offset = *offsetp;
 
 	err = nfsd_open(rqstp, fhp, S_IFDIR, MAY_READ, &file);
 	if (err)
@@ -1405,17 +1404,6 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 
 	file.f_pos = offset;
 
-	/* Set up the readdir context */
-	memset(&cd, 0, sizeof(cd));
-	cd.rqstp  = rqstp;
-	cd.buffer = buffer;
-	cd.buflen = *countp; /* count of words */
-	cd.dirfh  = fhp;
-	if (bmval) {
-		cd.bmval[0] = bmval[0];
-		cd.bmval[1] = bmval[1];
-	}
-
 	/*
 	 * Read the directory entries. This silly loop is necessary because
 	 * readdir() is not guaranteed to fill up the entire buffer, but
@@ -1423,49 +1411,21 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	 */
 
 	do {
-		oldlen = cd.buflen;
-
-		err = vfs_readdir(&file, (filldir_t) func, &cd);
-
-		if (err < 0)
-			goto out_nfserr;
-
-		err = cd.nfserr;
-		if (err)
-			goto out_close;
-	} while (oldlen != cd.buflen && !cd.eob);
-
-	err = nfserr_readdir_nospc;
-	if (rqstp->rq_vers == 4 && cd.eob && cd.buffer == buffer)
-		goto out_close;
-
-	/* If we didn't fill the buffer completely, we're at EOF */
-	eof = !cd.eob;
-
-	if (cd.offset) {
-		if (rqstp->rq_vers > 2)
-			(void)xdr_encode_hyper(cd.offset, file.f_pos);
-		else
-			*cd.offset = htonl(file.f_pos);
-	}
+		cdp->err = nfserr_eof; /* will be cleared on successful read */
+		err = vfs_readdir(&file, (filldir_t) func, cdp);
+	} while (err >=0 && cdp->err == nfs_ok);
+	if (err)
+		err = nfserrno(err);
+	else
+		err = cdp->err;
+	*offsetp = file.f_pos;
 
-	p = cd.buffer;
-	*p++ = 0;			/* no more entries */
-	*p++ = htonl(eof);		/* end of directory */
-	*countp = (caddr_t) p - (caddr_t) buffer;
-
-	dprintk("nfsd: readdir result %d bytes, eof %d offset %d\n",
-				*countp, eof,
-				cd.offset? ntohl(*cd.offset) : -1);
-	err = 0;
+	if (err == nfserr_eof || err == nfserr_readdir_nospc)
+		err = nfs_ok; /* can still be found in ->err */
 out_close:
 	nfsd_close(&file);
 out:
 	return err;
-
-out_nfserr:
-	err = nfserrno(err);
-	goto out_close;
 }
 
 /*
--- ./fs/nfsd/nfsxdr.c	2002/10/30 22:40:45	1.1
+++ ./fs/nfsd/nfsxdr.c	2002/10/30 22:40:51	1.2
@@ -380,7 +380,10 @@ int
 nfssvc_encode_readdirres(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_readdirres *resp)
 {
-	p += XDR_QUADLEN(resp->count);
+	p = resp->buffer;
+	*p++ = 0;			/* no more entries */
+	*p++ = htonl((resp->common.err == nfserr_eof));
+
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -399,9 +402,10 @@ nfssvc_encode_statfsres(struct svc_rqst 
 }
 
 int
-nfssvc_encode_entry(struct readdir_cd *cd, const char *name,
+nfssvc_encode_entry(struct readdir_cd *ccd, const char *name,
 		    int namlen, loff_t offset, ino_t ino, unsigned int d_type)
 {
+	struct nfsd_readdirres *cd = container_of(ccd, struct nfsd_readdirres, common);
 	u32	*p = cd->buffer;
 	int	buflen, slen;
 
@@ -410,8 +414,10 @@ nfssvc_encode_entry(struct readdir_cd *c
 			namlen, name, offset, ino);
 	 */
 
-	if (offset > ~((u32) 0))
+	if (offset > ~((u32) 0)) {
+		cd->common.err = nfserr_fbig;
 		return -EINVAL;
+	}
 	if (cd->offset)
 		*cd->offset = htonl(offset);
 	if (namlen > NFS2_MAXNAMLEN)
@@ -419,7 +425,7 @@ nfssvc_encode_entry(struct readdir_cd *c
 
 	slen = XDR_QUADLEN(namlen);
 	if ((buflen = cd->buflen - slen - 4) < 0) {
-		cd->eob = 1;
+		cd->common.err = nfserr_readdir_nospc;
 		return -EINVAL;
 	}
 	*p++ = xdr_one;				/* mark entry present */
@@ -430,6 +436,7 @@ nfssvc_encode_entry(struct readdir_cd *c
 
 	cd->buflen = buflen;
 	cd->buffer = p;
+	cd->common.err = nfs_ok;
 	return 0;
 }
 
--- ./fs/nfsd/nfs3xdr.c	2002/10/30 22:40:45	1.1
+++ ./fs/nfsd/nfs3xdr.c	2002/10/30 22:40:51	1.2
@@ -644,10 +644,13 @@ nfs3svc_encode_readdirres(struct svc_rqs
 					struct nfsd3_readdirres *resp)
 {
 	p = encode_post_op_attr(rqstp, p, &resp->fh);
+
 	if (resp->status == 0) {
 		/* stupid readdir cookie */
 		memcpy(p, resp->verf, 8); p += 2;
-		p += XDR_QUADLEN(resp->count);
+		p = resp->buffer;
+		*p++ = 0;		/* no more entries */
+		*p++ = htonl(resp->common.err == nfserr_eof);
 	}
 
 	return xdr_ressize_check(rqstp, p);
@@ -666,20 +669,16 @@ nfs3svc_encode_readdirres(struct svc_rqs
 #define NFS3_ENTRY_BAGGAGE	(2 + 1 + 2 + 1)
 #define NFS3_ENTRYPLUS_BAGGAGE	(1 + 21 + 1 + (NFS3_FHSIZE >> 2))
 static int
-encode_entry(struct readdir_cd *cd, const char *name,
+encode_entry(struct readdir_cd *ccd, const char *name,
 	     int namlen, off_t offset, ino_t ino, unsigned int d_type, int plus)
 {
+	struct nfsd3_readdirres *cd = container_of(ccd, struct nfsd3_readdirres, common);
 	u32		*p = cd->buffer;
 	int		buflen, slen, elen;
 
 	if (cd->offset)
 		xdr_encode_hyper(cd->offset, (u64) offset);
 
-	/* nfsd_readdir calls us with name == 0 when it wants us to
-	 * set the last offset entry. */
-	if (name == 0)
-		return 0;
-
 	/*
 	dprintk("encode_entry(%.*s @%ld%s)\n",
 		namlen, name, (long) offset, plus? " plus" : "");
@@ -693,7 +692,7 @@ encode_entry(struct readdir_cd *cd, cons
 	elen = slen + NFS3_ENTRY_BAGGAGE
 		+ (plus? NFS3_ENTRYPLUS_BAGGAGE : 0);
 	if ((buflen = cd->buflen - elen) < 0) {
-		cd->eob = 1;
+		cd->common.err = nfserr_readdir_nospc;
 		return -EINVAL;
 	}
 	*p++ = xdr_one;				 /* mark entry present */
@@ -709,8 +708,8 @@ encode_entry(struct readdir_cd *cd, cons
 		struct svc_export	*exp;
 		struct dentry		*dparent, *dchild;
 
-		dparent = cd->dirfh->fh_dentry;
-		exp  = cd->dirfh->fh_export;
+		dparent = cd->fh.fh_dentry;
+		exp  = cd->fh.fh_export;
 
 		fh_init(&fh, NFS3_FHSIZE);
 		if (isdotent(name, namlen)) {
@@ -724,7 +723,7 @@ encode_entry(struct readdir_cd *cd, cons
 			dchild = lookup_one_len(name, dparent,namlen);
 		if (IS_ERR(dchild))
 			goto noexec;
-		if (fh_compose(&fh, exp, dchild, cd->dirfh) != 0 || !dchild->d_inode)
+		if (fh_compose(&fh, exp, dchild, &cd->fh) != 0 || !dchild->d_inode)
 			goto noexec;
 		p = encode_post_op_attr(cd->rqstp, p, &fh);
 		*p++ = xdr_one; /* yes, a file handle follows */
@@ -735,6 +734,7 @@ encode_entry(struct readdir_cd *cd, cons
 out:
 	cd->buflen = buflen;
 	cd->buffer = p;
+	cd->common.err = nfs_ok;
 	return 0;
 
 noexec:
--- ./fs/nfsd/nfsproc.c	2002/10/30 22:40:45	1.1
+++ ./fs/nfsd/nfsproc.c	2002/10/30 22:40:51	1.2
@@ -471,6 +471,7 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 {
 	u32 *		buffer;
 	int		nfserr, count;
+	loff_t		offset;
 
 	dprintk("nfsd: READDIR  %s %d bytes at %d\n",
 		SVCFH_fmt(&argp->fh),		
@@ -488,11 +489,18 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 	if (count < 0)
 		count = 0;
 
+	resp->buffer = buffer;
+	resp->offset = NULL;
+	resp->buflen = count;
+	resp->common.err = nfs_ok;
 	/* Read directory and encode entries on the fly */
-	nfserr = nfsd_readdir(rqstp, &argp->fh, (loff_t) argp->cookie, 
-			      nfssvc_encode_entry,
-			      buffer, &count, NULL, NULL);
-	resp->count = count;
+	offset = argp->cookie;
+	nfserr = nfsd_readdir(rqstp, &argp->fh, &offset, 
+			      &resp->common, nfssvc_encode_entry);
+
+	resp->count = resp->buffer - buffer;
+	if (resp->offset)
+		*resp->offset = (u32)offset;
 
 	fh_put(&argp->fh);
 	return nfserr;
--- ./fs/nfsd/nfs3proc.c	2002/10/30 22:40:46	1.1
+++ ./fs/nfsd/nfs3proc.c	2002/10/30 22:40:51	1.2
@@ -457,11 +457,18 @@ nfsd3_proc_readdir(struct svc_rqst *rqst
 
 	/* Read directory and encode entries on the fly */
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t) argp->cookie, 
-					nfs3svc_encode_entry,
-					buffer, &count, argp->verf, NULL);
+
+	resp->buflen = count;
+	resp->common.err = nfs_ok;
+	resp->buffer = buffer;
+	resp->offset = NULL;
+	resp->rqstp = rqstp;
+	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie, 
+					&resp->common, nfs3svc_encode_entry);
 	memcpy(resp->verf, argp->verf, 8);
-	resp->count = count;
+	resp->count = resp->buffer - buffer;
+	if (resp->offset)
+		xdr_encode_hyper(resp->offset, argp->cookie);
 
 	RETURN_STATUS(nfserr);
 }
@@ -476,6 +483,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *
 {
 	u32 *	buffer;
 	int	nfserr, count, want;
+	loff_t	offset;
 
 	dprintk("nfsd: READDIR+(3) %s %d bytes at %d\n",
 				SVCFH_fmt(&argp->fh),
@@ -492,11 +500,18 @@ nfsd3_proc_readdirplus(struct svc_rqst *
 
 	/* Read directory and encode entries on the fly */
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t) argp->cookie, 
-					nfs3svc_encode_entry_plus,
-					buffer, &count, argp->verf, NULL);
+
+	resp->buflen = count;
+	resp->common.err = nfs_ok;
+	resp->buffer = buffer;
+	resp->rqstp = rqstp;
+	offset = argp->cookie;
+	nfserr = nfsd_readdir(rqstp, &resp->fh, &offset, 
+			      &resp->common, nfs3svc_encode_entry_plus);
 	memcpy(resp->verf, argp->verf, 8);
-	resp->count = count;
+	resp->count = resp->buffer - buffer;
+	if (resp->offset)
+		xdr_encode_hyper(resp->offset, offset);
 
 	RETURN_STATUS(nfserr);
 }
--- ./fs/nfsd/nfs4xdr.c	2002/10/30 22:40:46	1.1
+++ ./fs/nfsd/nfs4xdr.c	2002/10/30 22:40:51	1.2
@@ -1313,9 +1313,10 @@ out_serverfault:
 }
 
 static int
-nfsd4_encode_dirent(struct readdir_cd *cd, const char *name, int namlen,
+nfsd4_encode_dirent(struct readdir_cd *ccd, const char *name, int namlen,
 		    loff_t offset, ino_t ino, unsigned int d_type)
 {
+	struct nfsd4_readdir *cd = container_of(ccd, struct nfsd4_readdir, common);
 	int buflen;
 	u32 *p = cd->buffer;
 	u32 *attrlenp;
@@ -1324,17 +1325,14 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	int nfserr = 0;
 
 	/* In nfsv4, "." and ".." never make it onto the wire.. */
-	if (name && isdotent(name, namlen))
+	if (name && isdotent(name, namlen)) {
+		cd->common.err = nfs_ok;
 		return 0;
+	}
 
 	if (cd->offset)
 		xdr_encode_hyper(cd->offset, (u64) offset);
 
-	/* nfsd_readdir calls us with name == 0 when it wants us to
-	 * set the last offset entry. */
-	if (name == 0)
-		return 0;
-
 	buflen = cd->buflen - 4 - XDR_QUADLEN(namlen);
 	if (buflen < 0)
 		goto nospc;
@@ -1347,8 +1345,8 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	/*
 	 * Now we come to the ugly part: writing the fattr for this entry.
 	 */
-	bmval0 = cd->bmval[0];
-	bmval1 = cd->bmval[1];
+	bmval0 = cd->rd_bmval[0];
+	bmval1 = cd->rd_bmval[1];
 	if ((bmval0 & ~(FATTR4_WORD0_RDATTR_ERROR | FATTR4_WORD0_FILEID)) || bmval1)  {
 		/*
 		 * "Heavyweight" case: we have no choice except to
@@ -1356,14 +1354,14 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		 * only Windows clients will trigger this code
 		 * path.
 		 */
-		dentry = lookup_one_len(name, cd->dirfh->fh_dentry, namlen);
+		dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
 		if (IS_ERR(dentry)) {
 			nfserr = nfserrno(PTR_ERR(dentry));
 			goto error;
 		}
 
-		nfserr = nfsd4_encode_fattr(NULL, cd->dirfh->fh_export,
-					    dentry, p, &buflen, cd->bmval);
+		nfserr = nfsd4_encode_fattr(NULL, cd->rd_fhp->fh_export,
+					    dentry, p, &buflen, cd->rd_bmval);
 		dput(dentry);
 
 		if (!nfserr) {
@@ -1384,7 +1382,7 @@ error:
 		 * entire READDIR operation(!)
 		 */
 		if (!(bmval0 & FATTR4_WORD0_RDATTR_ERROR)) {
-			cd->nfserr = nfserr;
+			cd->common.err = nfserr;
 			return -EINVAL;
 		}
 
@@ -1414,10 +1412,11 @@ error:
 out:
 	cd->buflen -= (p - cd->buffer);
 	cd->buffer = p;
+	cd->common.err = nfs_ok;
 	return 0;
 
 nospc:
-	cd->eob = 1;
+	cd->common.err = nfserr_readdir_nospc;
 	return -EINVAL;
 }
 
@@ -1643,6 +1642,7 @@ static int
 nfsd4_encode_readdir(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_readdir *readdir)
 {
 	int maxcount;
+	loff_t offset;
 	ENCODE_HEAD;
 
 	if (nfserr)
@@ -1667,17 +1667,26 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	WRITE32(0);
 	WRITE32(0);
 
+	readdir->common.err = 0;
+	readdir->buflen = maxcount;
+	readdir->buffer = p;
+	readdir->offset = NULL;
+
+	offset = readdir->rd_cookie;
 	nfserr = nfsd_readdir(readdir->rd_rqstp, readdir->rd_fhp,
-			      readdir->rd_cookie, nfsd4_encode_dirent,
-			      p, &maxcount, NULL, readdir->rd_bmval);
-	if (!nfserr) {
-		/*
-		 * nfsd_readdir() expects 'maxcount' to be a count of
-		 * words, but fills it in with a count of bytes at the
-		 * end!
-		 */
-		BUG_ON(maxcount & 3);
-		p += (maxcount >> 2);
+			      &offset,
+			      &readdir->common, nfsd4_encode_dirent);
+	if (nfserr == nfs_ok &&
+	    readdir->common.err == nfserr_readdir_nospc &&
+	    readdir->buffer == p)
+		nfserr = nfserr_readdir_nospc;
+	if (!nfserr) {
+		if (readdir->offset)
+			xdr_encode_hyper(readdir->offset, offset);
+
+		p = readdir->buffer;
+		*p++ = 0;	/* no more entries */
+		*p++ = htonl(readdir->common.err == nfserr_eof);
 		ADJUST_ARGS();
 	}
 	return nfserr;
--- ./include/linux/nfsd/xdr.h	2002/10/30 22:40:46	1.1
+++ ./include/linux/nfsd/xdr.h	2002/10/30 22:40:51	1.2
@@ -98,6 +98,11 @@ struct nfsd_readres {
 
 struct nfsd_readdirres {
 	int			count;
+
+	struct readdir_cd	common;
+	u32 *			buffer;
+	int			buflen;
+	u32 *			offset;
 };
 
 struct nfsd_statfsres {
--- ./include/linux/nfsd/nfsd.h	2002/10/30 22:40:46	1.1
+++ ./include/linux/nfsd/nfsd.h	2002/10/30 22:40:51	1.2
@@ -48,16 +48,7 @@
  * Callback function for readdir
  */
 struct readdir_cd {
-	struct svc_rqst *	rqstp;
-	struct svc_fh *		dirfh;
-	u32 *			buffer;
-	int			buflen;
-	u32 *			offset;		/* previous dirent->d_next */
-	char			plus;		/* readdirplus */
-	char			eob;		/* end of buffer */
-	char			dotonly;
-	int			nfserr;		/* v4 only */
-	u32			bmval[2];	/* v4 only */
+	int			err;	/* 0, nfserr, or nfserr_eof */
 };
 typedef int		(*encode_dent_fn)(struct readdir_cd *, const char *,
 						int, loff_t, ino_t, unsigned int);
@@ -117,9 +108,7 @@ int		nfsd_unlink(struct svc_rqst *, stru
 int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
 				unsigned long size);
 int		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
-				loff_t, encode_dent_fn,
-				u32 *buffer, int *countp, u32 *verf,
-				u32 *bmval);
+			     loff_t *, struct readdir_cd *, encode_dent_fn);
 int		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 				struct statfs *);
 
@@ -180,10 +169,13 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_readdir_nospc	__constant_htonl(NFSERR_READDIR_NOSPC)
 #define	nfserr_bad_xdr		__constant_htonl(NFSERR_BAD_XDR)
 
-/* error code for internal use - if a request fails due to
- * kmalloc failure, it gets dropped.  Client should resend eventually
+/* error codes for internal use */
+/* if a request fails due to kmalloc failure, it gets dropped.
+ *  Client should resend eventually
  */
 #define	nfserr_dropit		__constant_htonl(30000)
+/* end-of-file indicator in readdir */
+#define	nfserr_eof		__constant_htonl(30001)
 
 /* Check for dir entries '.' and '..' */
 #define isdotent(n, l)	(l < 3 && n[0] == '.' && (l == 1 || n[1] == '.'))
--- ./include/linux/nfsd/xdr3.h	2002/10/30 22:40:46	1.1
+++ ./include/linux/nfsd/xdr3.h	2002/10/30 22:40:51	1.2
@@ -156,6 +156,13 @@ struct nfsd3_readdirres {
 	struct svc_fh		fh;
 	int			count;
 	__u32			verf[2];
+
+	struct readdir_cd	common;
+	u32 *			buffer;
+	int			buflen;
+	u32 *			offset;
+	struct svc_rqst *	rqstp;
+
 };
 
 struct nfsd3_fsstatres {
--- ./include/linux/nfsd/xdr4.h	2002/10/30 22:40:46	1.1
+++ ./include/linux/nfsd/xdr4.h	2002/10/30 22:40:51	1.2
@@ -185,6 +185,11 @@ struct nfsd4_readdir {
 	u32		rd_bmval[2];        /* request */
 	struct svc_rqst *rd_rqstp;          /* response */
 	struct svc_fh * rd_fhp;             /* response */
+
+	struct readdir_cd	common;
+	u32 *			buffer;
+	int			buflen;
+	u32 *			offset;
 };
 
 struct nfsd4_readlink {


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
