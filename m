From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - nfsv4 - 1 of 2 - teach nfsv4 request decode to handle multi-page requests
Date: Wed, 13 Nov 2002 09:45:23 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15825.33923.741698.59087@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Bjmm-0007OI-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 14:45:32 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 13 Nov 2002 09:45:24 +1100
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



Now that nfsd uses a list of pages for requests instead of
one large buffer, NFSv4 need to know about this.
This first patch deal with requests.
note: This compiles (with next patch), but I haven't tested it (I
haven't got around to getting a 'mount' that understands nfsv4).

The most interesting part of this is that it is possible
that section of a request, like a path name, could span 
two pages, so we need to be able to kmalloc as little bit
of space to copy them into, and make sure they get
freed later.




 ----------- Diffstat output ------------
 fs/nfsd/nfs4proc.c        |   13 +++
 fs/nfsd/nfs4xdr.c         |  169 +++++++++++++++++++++++++++++++++++++++-------
 include/linux/nfsd/xdr4.h |   12 ++-
 3 files changed, 167 insertions(+), 27 deletions(-)

diff fs/nfsd/nfs4proc.c~current~ fs/nfsd/nfs4proc.c
--- fs/nfsd/nfs4proc.c~current~	2002-11-12 15:42:38.000000000 +1100
+++ fs/nfsd/nfs4proc.c	2002-11-12 15:42:38.000000000 +1100
@@ -481,7 +481,8 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	*p++ = nfssvc_boot.tv_usec;
 
 	return nfsd_write(rqstp, current_fh, write->wr_offset,
-			  write->wr_buf, write->wr_buflen, &write->wr_how_written);
+			  write->wr_vec, write->wr_vlen, write->wr_buflen,
+			  &write->wr_how_written);
 }
 
 /* This routine never returns NFS_OK!  If there are no other errors, it
@@ -700,6 +701,16 @@ out:
 		kfree(args->ops);
 		args->ops = args->iops;
 	}
+	if (args->tmpp) {
+		kfree(args->tmpp);
+		args->tmpp = NULL;
+	}
+	while (args->to_free) {
+		struct tmpbuf *tb = args->to_free;
+		args->to_free = tb->next;
+		kfree(tb->buf);
+		kfree(tb);
+	}
 	fh_put(&current_fh);
 	fh_put(&save_fh);
 	return status;

diff fs/nfsd/nfs4xdr.c~current~ fs/nfsd/nfs4xdr.c
--- fs/nfsd/nfs4xdr.c~current~	2002-11-12 15:42:38.000000000 +1100
+++ fs/nfsd/nfs4xdr.c	2002-11-12 15:42:38.000000000 +1100
@@ -217,20 +217,92 @@ xdr_error:					\
 	x = (char *)p;				\
 	p += XDR_QUADLEN(nbytes);		\
 } while (0)
+#define SAVEMEM(x,nbytes) do {			\
+	if (!(x = (p==argp->tmp || p == argp->tmpp) ? \
+ 		savemem(argp, p, nbytes) :	\
+ 		(char *)p)) {			\
+		printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__); \
+		goto xdr_error;			\
+		}				\
+	p += XDR_QUADLEN(nbytes);		\
+} while (0)
 #define COPYMEM(x,nbytes) do {			\
 	memcpy((x), p, nbytes);			\
 	p += XDR_QUADLEN(nbytes);		\
 } while (0)
 
 #define READ_BUF(nbytes)  do {			\
-	if (nbytes > (u32)((char *)argp->end - (char *)argp->p)) {	\
+	if (nbytes <= (u32)((char *)argp->end - (char *)argp->p)) {	\
+		p = argp->p;			\
+		argp->p += XDR_QUADLEN(nbytes);	\
+	} else if (!(p = read_buf(argp, nbytes))) { \
 		printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__); \
 		goto xdr_error;			\
 	}					\
-	p = argp->p;				\
-	argp->p += XDR_QUADLEN(nbytes);		\
 } while (0)
 
+u32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
+{
+	/* We want more bytes than seem to be available.
+	 * Maybe we need a new page, may wehave just run out
+	 */
+	int avail = (char*)argp->end - (char*)argp->p;
+	u32 *p;
+	if (avail + argp->pagelen < nbytes)
+		return NULL;
+	if (avail + PAGE_SIZE > nbytes) /* need more than a page !! */
+		return NULL;
+	/* ok, we can do it with the tail plus the next page */
+	if (nbytes <= sizeof(argp->tmp))
+		p = argp->tmp;
+	else {
+		if (argp->tmpp)
+			kfree(argp->tmpp);
+		p = argp->tmpp = kmalloc(nbytes, GFP_KERNEL);
+		if (!p)
+			return NULL;
+		
+	}
+	memcpy(p, argp->p, avail);
+	/* step to next page */
+	argp->p = page_address(argp->pagelist[0]);
+	argp->pagelist++;
+	if (argp->pagelen < PAGE_SIZE) {
+		argp->end = p + (argp->pagelen>>2);
+		argp->pagelen = 0;
+	} else {
+		argp->end = p + (PAGE_SIZE>>2);
+		argp->pagelen -= PAGE_SIZE;
+	}
+	memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
+	argp->p += XDR_QUADLEN(nbytes - avail);
+	return p;
+}
+
+char *savemem(struct nfsd4_compoundargs *argp, u32 *p, int nbytes)
+{
+	struct tmpbuf *tb;
+	if (p == argp->tmp) {
+		p = kmalloc(nbytes, GFP_KERNEL);
+		if (!p) return NULL;
+		memcpy(p, argp->tmp, nbytes);
+	} else {
+		if (p != argp->tmpp)
+			BUG();
+		argp->tmpp = NULL;
+	}
+	tb = kmalloc(sizeof(*tb), GFP_KERNEL);
+	if (!tb) {
+		kfree(p);
+		return NULL;
+	}
+	tb->buf = p;
+	tb->next = argp->to_free;
+	argp->to_free = tb;
+	return (char*)p;
+}
+
+
 static int
 nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 {
@@ -442,7 +514,7 @@ nfsd4_decode_create(struct nfsd4_compoun
 		READ_BUF(4);
 		READ32(create->cr_linklen);
 		READ_BUF(create->cr_linklen);
-		READMEM(create->cr_linkname, create->cr_linklen);
+		SAVEMEM(create->cr_linkname, create->cr_linklen);
 		if (check_utf8(create->cr_linkname, create->cr_linklen))
 			return nfserr_inval;
 		break;
@@ -463,7 +535,7 @@ nfsd4_decode_create(struct nfsd4_compoun
 	READ_BUF(4);
 	READ32(create->cr_namelen);
 	READ_BUF(create->cr_namelen);
-	READMEM(create->cr_name, create->cr_namelen);
+	SAVEMEM(create->cr_name, create->cr_namelen);
 	if ((status = check_filename(create->cr_name, create->cr_namelen, nfserr_inval)))
 		return status;
 
@@ -487,7 +559,7 @@ nfsd4_decode_link(struct nfsd4_compounda
 	READ_BUF(4);
 	READ32(link->li_namelen);
 	READ_BUF(link->li_namelen);
-	READMEM(link->li_name, link->li_namelen);
+	SAVEMEM(link->li_name, link->li_namelen);
 	if ((status = check_filename(link->li_name, link->li_namelen, nfserr_inval)))
 		return status;
 
@@ -502,7 +574,7 @@ nfsd4_decode_lookup(struct nfsd4_compoun
 	READ_BUF(4);
 	READ32(lookup->lo_len);
 	READ_BUF(lookup->lo_len);
-	READMEM(lookup->lo_name, lookup->lo_len);
+	SAVEMEM(lookup->lo_name, lookup->lo_len);
 	if ((status = check_filename(lookup->lo_name, lookup->lo_len, nfserr_noent)))
 		return status;
 
@@ -527,7 +599,7 @@ nfsd4_decode_open(struct nfsd4_compounda
 
 	/* owner, open_flag */
 	READ_BUF(open->op_ownerlen + 4);
-	READMEM(open->op_owner, open->op_ownerlen);
+	SAVEMEM(open->op_owner, open->op_ownerlen);
 	READ32(open->op_create);
 	switch (open->op_create) {
 	case NFS4_OPEN_NOCREATE:
@@ -562,7 +634,7 @@ nfsd4_decode_open(struct nfsd4_compounda
 		READ_BUF(4);
 		READ32(open->op_namelen);
 		READ_BUF(open->op_namelen);
-		READMEM(open->op_name, open->op_namelen);
+		SAVEMEM(open->op_name, open->op_namelen);
 		if ((status = check_filename(open->op_name, open->op_namelen, nfserr_inval)))
 			return status;
 		break;
@@ -575,7 +647,7 @@ nfsd4_decode_open(struct nfsd4_compounda
 		COPYMEM(&open->op_delegate_stateid, sizeof(delegation_stateid_t));
 		READ32(open->op_namelen);
 		READ_BUF(open->op_namelen);
-		READMEM(open->op_name, open->op_namelen);
+		SAVEMEM(open->op_name, open->op_namelen);
 		if ((status = check_filename(open->op_name, open->op_namelen, nfserr_inval)))
 			return status;
 		break;
@@ -596,7 +668,7 @@ nfsd4_decode_putfh(struct nfsd4_compound
 	if (putfh->pf_fhlen > NFS4_FHSIZE)
 		goto xdr_error;
 	READ_BUF(putfh->pf_fhlen);
-	READMEM(putfh->pf_fhval, putfh->pf_fhlen);
+	SAVEMEM(putfh->pf_fhval, putfh->pf_fhlen);
 
 	DECODE_TAIL;
 }
@@ -639,7 +711,7 @@ nfsd4_decode_remove(struct nfsd4_compoun
 	READ_BUF(4);
 	READ32(remove->rm_namelen);
 	READ_BUF(remove->rm_namelen);
-	READMEM(remove->rm_name, remove->rm_namelen);
+	SAVEMEM(remove->rm_name, remove->rm_namelen);
 	if ((status = check_filename(remove->rm_name, remove->rm_namelen, nfserr_noent)))
 		return status;
 
@@ -654,10 +726,10 @@ nfsd4_decode_rename(struct nfsd4_compoun
 	READ_BUF(4);
 	READ32(rename->rn_snamelen);
 	READ_BUF(rename->rn_snamelen + 4);
-	READMEM(rename->rn_sname, rename->rn_snamelen);
+	SAVEMEM(rename->rn_sname, rename->rn_snamelen);
 	READ32(rename->rn_tnamelen);
 	READ_BUF(rename->rn_tnamelen);
-	READMEM(rename->rn_tname, rename->rn_tnamelen);
+	SAVEMEM(rename->rn_tname, rename->rn_tnamelen);
 	if ((status = check_filename(rename->rn_sname, rename->rn_snamelen, nfserr_noent)))
 		return status;
 	if ((status = check_filename(rename->rn_tname, rename->rn_tnamelen, nfserr_inval)))
@@ -701,16 +773,16 @@ nfsd4_decode_setclientid(struct nfsd4_co
 	READ32(setclientid->se_namelen);
 
 	READ_BUF(setclientid->se_namelen + 8);
-	READMEM(setclientid->se_name, setclientid->se_namelen);
+	SAVEMEM(setclientid->se_name, setclientid->se_namelen);
 	READ32(setclientid->se_callback_prog);
 	READ32(setclientid->se_callback_netid_len);
 
 	READ_BUF(setclientid->se_callback_netid_len + 4);
-	READMEM(setclientid->se_callback_netid_val, setclientid->se_callback_netid_len);
+	SAVEMEM(setclientid->se_callback_netid_val, setclientid->se_callback_netid_len);
 	READ32(setclientid->se_callback_addr_len);
 
 	READ_BUF(setclientid->se_callback_addr_len + 4);
-	READMEM(setclientid->se_callback_addr_val, setclientid->se_callback_addr_len);
+	SAVEMEM(setclientid->se_callback_addr_val, setclientid->se_callback_addr_len);
 	READ32(setclientid->se_callback_ident);
 
 	DECODE_TAIL;
@@ -739,7 +811,7 @@ nfsd4_decode_verify(struct nfsd4_compoun
 	READ_BUF(4);
 	READ32(verify->ve_attrlen);
 	READ_BUF(verify->ve_attrlen);
-	READMEM(verify->ve_attrval, verify->ve_attrlen);
+	SAVEMEM(verify->ve_attrval, verify->ve_attrlen);
 
 	DECODE_TAIL;
 }
@@ -747,6 +819,9 @@ nfsd4_decode_verify(struct nfsd4_compoun
 static int
 nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 {
+	int avail;
+	int v;
+	int len;
 	DECODE_HEAD;
 
 	READ_BUF(sizeof(stateid_t) + 16);
@@ -758,8 +833,36 @@ nfsd4_decode_write(struct nfsd4_compound
 		goto xdr_error;
 	READ32(write->wr_buflen);
 
-	READ_BUF(write->wr_buflen);
-	READMEM(write->wr_buf, write->wr_buflen);
+	/* Sorry .. no magic macros for this.. *
+	 * READ_BUF(write->wr_buflen);
+	 * SAVEMEM(write->wr_buf, write->wr_buflen);
+	 */
+	avail = (char*)argp->end - (char*)argp->p;
+	if (avail + argp->pagelen < write->wr_buflen) {
+		printk(KERN_NOTICE "xdr error! (%s:%d)\n", __FILE__, __LINE__); 
+		goto xdr_error;
+	}
+	write->wr_vec[0].iov_base = p;
+	write->wr_vec[0].iov_len = avail;
+	v = 0;
+	len = write->wr_buflen;
+	while (len > write->wr_vec[v].iov_len) {
+		len -= write->wr_vec[v].iov_len;
+		v++;
+		write->wr_vec[v].iov_base = page_address(argp->pagelist[0]);
+		argp->pagelist++;
+		if (argp->pagelen >= PAGE_SIZE) {
+			write->wr_vec[v].iov_len = PAGE_SIZE;
+			argp->pagelen -= PAGE_SIZE;
+		} else {
+			write->wr_vec[v].iov_len = argp->pagelen;
+			argp->pagelen = 0;
+		}
+	}
+	argp->end = (u32*) (write->wr_vec[v].iov_base + write->wr_vec[v].iov_len);
+	argp->p = (u32*)  (write->wr_vec[v].iov_base + len);
+	write->wr_vec[v].iov_len = len;
+	write->wr_vlen = v+1;
 
 	DECODE_TAIL;
 }
@@ -780,7 +883,7 @@ nfsd4_decode_compound(struct nfsd4_compo
 	READ_BUF(4);
 	READ32(argp->taglen);
 	READ_BUF(argp->taglen + 8);
-	READMEM(argp->tag, argp->taglen);
+	SAVEMEM(argp->tag, argp->taglen);
 	READ32(argp->minorversion);
 	READ32(argp->opcnt);
 
@@ -1891,13 +1994,29 @@ nfs4svc_decode_compoundargs(struct svc_r
 	int status;
 
 	args->p = p;
-	args->end = rqstp->rq_argbuf.base + rqstp->rq_argbuf.buflen;
+	args->end = rqstp->rq_arg.head[0].iov_base + rqstp->rq_arg.head[0].iov_len;
+	args->pagelist = rqstp->rq_arg.pages;
+	args->pagelen = rqstp->rq_args.page_len;
+	args->tmpp = NULL;
+	args->to_free = NULL;
 	args->ops = args->iops;
 
 	status = nfsd4_decode_compound(args);
-	if (status && args->ops != args->iops) {
-		kfree(args->ops);
-		args->ops = args->iops;
+	if (status) {
+		if (args->ops != args->iops) {
+			kfree(args->ops);
+			args->ops = args->iops;
+		}
+		if (args->tmpp) {
+			kfree(args->tmpp);
+			args->tmpp = NULL;
+		}
+		while (args->to_free) {
+			struct tmpbuf *tb = args->to_free;
+			args->to_free = tb->next;
+			kfree(tb->buf);
+			kfree(tb);
+		}
 	}
 	return !status;
 }

diff include/linux/nfsd/xdr4.h~current~ include/linux/nfsd/xdr4.h
--- include/linux/nfsd/xdr4.h~current~	2002-11-12 15:42:38.000000000 +1100
+++ include/linux/nfsd/xdr4.h	2002-11-12 15:42:38.000000000 +1100
@@ -249,7 +249,9 @@ struct nfsd4_write {
 	u64		wr_offset;          /* request */
 	u32		wr_stable_how;      /* request */
 	u32		wr_buflen;          /* request */
-	char *		wr_buf;             /* request */
+	struct iovec	wr_vec[RPCSVC_MAXPAGES]; /* request */
+	int		wr_vlen;
+
 	u32		wr_bytes_written;   /* response */
 	u32		wr_how_written;     /* response */
 	nfs4_verifier	wr_verifier;        /* response */
@@ -288,6 +290,14 @@ struct nfsd4_compoundargs {
 	/* scratch variables for XDR decode */
 	u32 *				p;
 	u32 *				end;
+	struct page **			pagelist;
+	int				pagelen;
+	u32				tmp[8];
+	u32 *				tmpp;
+	struct tmpbuf {
+		struct tmpbuf *next;
+		void *buf;
+	}				*to_free;
 	
 	u32				taglen;
 	char *				tag;


-------------------------------------------------------
This sf.net email is sponsored by: 
To learn the basics of securing your web site with SSL, 
click here to get a FREE TRIAL of a Thawte Server Certificate: 
http://www.gothawte.com/rd522.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
