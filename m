From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [PATCH] NFSv3 READDIRPLUS fails SpecSFS validation test - 2nd
 ed.
Date: 19 Nov 2003 16:35:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069288507.4192.6.camel@w-bwa3.beaverton.ibm.com>
References: <1069121605.1244.94.camel@w-bwa1.beaverton.ibm.com>
	 <16313.34113.687049.258087@notabene.cse.unsw.edu.au>
	 <1069204822.4249.11.camel@w-bwa3.beaverton.ibm.com>
	 <16316.914.451342.638426@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-cjv4Vw96jXUCQK1J8ED0"
Cc: nfs@lists.sourceforge.net, jrsantos@austin.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMcni-00079Q-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 16:36:02 -0800
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AMcn4-0005u1-1C
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 16:35:22 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16316.914.451342.638426@notabene.cse.unsw.edu.au>
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


--=-cjv4Vw96jXUCQK1J8ED0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Sorry about that, I recently upgraded to RH9 and apparently the newer
version of Evolution skewed the patch.  I realize attachments are
generally frowned upon, but I'm sending the patch along as one now
(which should resolve the line wrap problem) and will figure out how to
get around this for the future.

Bruce

On Wed, 2003-11-19 at 15:58, Neil Brown wrote:
> On  November 18, bwa@us.ibm.com wrote:
> > Hi Neil,
> > 
> > Below is the updated patch with your recommended changes.  How does it
> > look?
> 
> Looks much better.
>  A little nit:  You check against NFSSVC_MAXBLKSIZE twice, once in
>  nfs3xdr and once in nfs3proc.  It would be nice if nfs3xdr did the
>  check and imposed it so nfs3proc could never see a too-large number.
> 
>  I was going to just fix that myself, but then discovered all the long
>  lines are wrapped :-(  Could you send the patch again in some way
>  that there isn't any line wrap?
> 
> Thanks
> NeilBrown
> 

--=-cjv4Vw96jXUCQK1J8ED0
Content-Disposition: attachment; filename=2.6.0-test9_readdirplus-2.diff
Content-Type: text/x-patch; name=2.6.0-test9_readdirplus-2.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Naur linux-2.6.0-test9-vanilla/fs/nfsd/nfs3proc.c linux-2.6.0-test9/fs/nfsd/nfs3proc.c
--- linux-2.6.0-test9-vanilla/fs/nfsd/nfs3proc.c	2003-10-25 11:43:24.000000000 -0700
+++ linux-2.6.0-test9/fs/nfsd/nfs3proc.c	2003-11-18 16:30:59.000000000 -0800
@@ -458,27 +458,45 @@
 {
 	int	nfserr, count;
 	loff_t	offset;
+	int	i;
+	caddr_t	page_addr = NULL;
 
 	dprintk("nfsd: READDIR+(3) %s %d bytes at %d\n",
 				SVCFH_fmt(&argp->fh),
 				argp->count, (u32) argp->cookie);
 
-	/* Make sure we've room for the NULL ptr & eof flag, and shrink to
-	 * client read size */
-	count = (argp->count >> 2) - 2;
+	count = (argp->count > NFSSVC_MAXBLKSIZE) ? NFSSVC_MAXBLKSIZE : 
+						    argp->count;
+	
+	/* Convert byte count to number of words (i.e. >> 2),
+	 * and reserve room for the NULL ptr & eof flag (-2 words) */
+	resp->count = (count >> 2) - 2;
 
 	/* Read directory and encode entries on the fly */
 	fh_copy(&resp->fh, &argp->fh);
 
-	resp->buflen = count;
 	resp->common.err = nfs_ok;
 	resp->buffer = argp->buffer;
+	resp->buflen = resp->count;
 	resp->rqstp = rqstp;
 	offset = argp->cookie;
-	nfserr = nfsd_readdir(rqstp, &resp->fh, &offset, 
-			      &resp->common, nfs3svc_encode_entry_plus);
+	nfserr = nfsd_readdir(rqstp, &resp->fh,
+				     &offset, 
+				     &resp->common,
+				     nfs3svc_encode_entry_plus);
 	memcpy(resp->verf, argp->verf, 8);
-	resp->count = resp->buffer - argp->buffer;
+	count = 0;
+	for (i=1; i<rqstp->rq_resused ; i++) {
+		page_addr = page_address(rqstp->rq_respages[i]);
+
+		if (((caddr_t)resp->buffer >= page_addr) &&
+		    ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
+			count += (caddr_t)resp->buffer - page_addr;
+			break;
+		}
+		count += PAGE_SIZE;
+	}
+	resp->count = count >> 2;
 	if (resp->offset)
 		xdr_encode_hyper(resp->offset, offset);
 
diff -Naur linux-2.6.0-test9-vanilla/fs/nfsd/nfs3xdr.c linux-2.6.0-test9/fs/nfsd/nfs3xdr.c
--- linux-2.6.0-test9-vanilla/fs/nfsd/nfs3xdr.c	2003-10-25 11:42:41.000000000 -0700
+++ linux-2.6.0-test9/fs/nfsd/nfs3xdr.c	2003-11-18 16:50:18.000000000 -0800
@@ -560,6 +560,8 @@
 nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd3_readdirargs *args)
 {
+	int len, pn;
+
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 	p = xdr_decode_hyper(p, &args->cookie);
@@ -567,11 +569,17 @@
 	args->dircount = ntohl(*p++);
 	args->count    = ntohl(*p++);
 
-	if (args->count > PAGE_SIZE)
-		args->count = PAGE_SIZE;
-
-	svc_take_page(rqstp);
-	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
+	len = args->count;
+	if (len > NFSSVC_MAXBLKSIZE)
+		len = NFSSVC_MAXBLKSIZE;
+
+	while (len > 0) {
+		pn = rqstp->rq_resused;
+		svc_take_page(rqstp);
+		if (!args->buffer)
+			args->buffer = page_address(rqstp->rq_respages[pn]);
+		len -= PAGE_SIZE;
+	}
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -754,12 +762,64 @@
 		p = resp->buffer;
 		*p++ = 0;		/* no more entries */
 		*p++ = htonl(resp->common.err == nfserr_eof);
-		rqstp->rq_res.page_len = (((unsigned long)p-1) & ~PAGE_MASK)+1;
+		rqstp->rq_res.page_len = (resp->count + 2) << 2;
 		return 1;
 	} else
 		return xdr_ressize_check(rqstp, p);
 }
 
+static inline u32 *
+encode_entry_baggage(struct nfsd3_readdirres *cd, u32 *p, const char *name,
+	     int namlen, ino_t ino)
+{
+	*p++ = xdr_one;				 /* mark entry present */
+	p    = xdr_encode_hyper(p, ino);	 /* file id */
+	p    = xdr_encode_array(p, name, namlen);/* name length & name */
+
+	cd->offset = p;				/* remember pointer */
+	p = xdr_encode_hyper(p, NFS_OFFSET_MAX);/* offset of next entry */
+	
+	return p;
+}
+
+static inline u32 *
+encode_entryplus_baggage(struct nfsd3_readdirres *cd, u32 *p,
+		struct svc_fh *fhp)
+{
+		p = encode_post_op_attr(cd->rqstp, p, fhp);
+		*p++ = xdr_one;			/* yes, a file handle follows */
+		p = encode_fh(p, fhp);
+		fh_put(fhp);
+		return p;
+}
+
+static int
+compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
+		const char *name, int namlen)
+{
+	struct svc_export	*exp;
+	struct dentry		*dparent, *dchild;
+
+	dparent = cd->fh.fh_dentry;
+	exp  = cd->fh.fh_export;
+
+	fh_init(fhp, NFS3_FHSIZE);
+	if (isdotent(name, namlen)) {
+		if (namlen == 2) {
+			dchild = dget_parent(dparent);
+		} else
+			dchild = dget(dparent);
+	} else
+		dchild = lookup_one_len(name, dparent, namlen);
+	if (IS_ERR(dchild))
+		return 1;
+	if (d_mountpoint(dchild))
+		return 1;
+	if (fh_compose(fhp, exp, dchild, &cd->fh) != 0 || !dchild->d_inode)
+		return 1;
+	return 0;
+}
+
 /*
  * Encode a directory entry. This one works for both normal readdir
  * and readdirplus.
@@ -776,9 +836,14 @@
 encode_entry(struct readdir_cd *ccd, const char *name,
 	     int namlen, off_t offset, ino_t ino, unsigned int d_type, int plus)
 {
-	struct nfsd3_readdirres *cd = container_of(ccd, struct nfsd3_readdirres, common);
+	struct nfsd3_readdirres *cd = container_of(ccd, struct nfsd3_readdirres,
+		       					common);
 	u32		*p = cd->buffer;
-	int		slen, elen;
+	caddr_t		curr_page_addr = NULL;
+	int		pn;		/* current page number */
+	int		slen;		/* string (name) length */
+	int		elen;		/* estimated entry length in words */
+	int		num_entry_words = 0;	/* actual number of words */
 
 	if (cd->offset)
 		xdr_encode_hyper(cd->offset, (u64) offset);
@@ -795,48 +860,93 @@
 	slen = XDR_QUADLEN(namlen);
 	elen = slen + NFS3_ENTRY_BAGGAGE
 		+ (plus? NFS3_ENTRYPLUS_BAGGAGE : 0);
+
 	if (cd->buflen < elen) {
 		cd->common.err = nfserr_readdir_nospc;
 		return -EINVAL;
 	}
-	*p++ = xdr_one;				 /* mark entry present */
-	p    = xdr_encode_hyper(p, ino);	 /* file id */
-	p    = xdr_encode_array(p, name, namlen);/* name length & name */
 
-	cd->offset = p;			/* remember pointer */
-	p = xdr_encode_hyper(p, NFS_OFFSET_MAX);	/* offset of next entry */
+	/* determine which page in rq_respages[] we are currently filling */
+	for (pn=1; pn < cd->rqstp->rq_resused; pn++) {
+		curr_page_addr = page_address(cd->rqstp->rq_respages[pn]);
+
+		if (((caddr_t)cd->buffer >= curr_page_addr) &&
+		    ((caddr_t)cd->buffer <  curr_page_addr + PAGE_SIZE))
+			break;
+	}
+
+	if ((caddr_t)(cd->buffer + elen) < (curr_page_addr + PAGE_SIZE)) {
+		/* encode entry in current page */
+
+		p = encode_entry_baggage(cd, p, name, namlen, ino);
 
-	/* throw in readdirplus baggage */
-	if (plus) {
-		struct svc_fh	fh;
-		struct svc_export	*exp;
-		struct dentry		*dparent, *dchild;
-
-		dparent = cd->fh.fh_dentry;
-		exp  = cd->fh.fh_export;
-
-		fh_init(&fh, NFS3_FHSIZE);
-		if (isdotent(name, namlen)) {
-			if (namlen == 2) {
-				dchild = dget_parent(dparent);
+		/* throw in readdirplus baggage */
+		if (plus) {
+			struct svc_fh	fh;
+
+			if (compose_entry_fh(cd, &fh, name, namlen) > 0)
+				goto noexec;
+
+			p = encode_entryplus_baggage(cd, p, &fh);
+		}
+		num_entry_words = p - cd->buffer;
+	} else if (cd->rqstp->rq_respages[pn+1] != NULL) {
+		/* temporarily encode entry into next page, then move back to
+		 * current and next page in rq_respages[] */
+		u32 *p1, *tmp;
+		int len1, len2;
+
+		/* grab next page for temporary storage of entry */
+		p1 = tmp = page_address(cd->rqstp->rq_respages[pn+1]);
+
+		p1 = encode_entry_baggage(cd, p1, name, namlen, ino);
+
+		/* throw in readdirplus baggage */
+		if (plus) {
+			struct svc_fh	fh;
+
+			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
+				/* zero out the filehandle */
+				*p1++ = 0;
+				*p1++ = 0;
 			} else
-				dchild = dget(dparent);
-		} else
-			dchild = lookup_one_len(name, dparent,namlen);
-		if (IS_ERR(dchild))
-			goto noexec;
-		if (d_mountpoint(dchild))
-			goto noexec;
-		if (fh_compose(&fh, exp, dchild, &cd->fh) != 0 || !dchild->d_inode)
-			goto noexec;
-		p = encode_post_op_attr(cd->rqstp, p, &fh);
-		*p++ = xdr_one; /* yes, a file handle follows */
-		p = encode_fh(p, &fh);
-		fh_put(&fh);
+				p1 = encode_entryplus_baggage(cd, p1, &fh);
+		}
+
+		/* determine entry word length and lengths to go in pages */
+		num_entry_words = p1 - tmp;
+		len1 = curr_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
+		if ((num_entry_words << 2) <= len1) {
+			/* the actual number of words in the entry is less
+			 * than elen and can still fit in the current page
+			 */
+			memmove(p, tmp, num_entry_words << 2);
+			p += num_entry_words;
+
+			/* update offset */
+			cd->offset = cd->buffer + (cd->offset - tmp);
+		} else {
+			len2 = (num_entry_words << 2) - len1;
+
+			/* move from temp page to current and next pages */
+			memmove(p, tmp, len1);
+			memmove(tmp, (caddr_t)tmp+len1, len2);
+
+			/* update offset */
+			if (((cd->offset - tmp) << 2) <= len1)
+				cd->offset = p + (cd->offset - tmp);
+			else
+				cd->offset -= len1 >> 2;
+			p = tmp + (len2 >> 2);
+		}
+	}
+	else {
+		cd->common.err = nfserr_readdir_nospc;
+		return -EINVAL;
 	}
 
 out:
-	cd->buflen -= p - cd->buffer;
+	cd->buflen -= num_entry_words;
 	cd->buffer = p;
 	cd->common.err = nfs_ok;
 	return 0;

--=-cjv4Vw96jXUCQK1J8ED0--



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
