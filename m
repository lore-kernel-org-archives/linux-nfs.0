From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - nfsd to handle large symlinks again
Date: Wed, 13 Nov 2002 09:43:07 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15825.33787.907202.423393@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Bjka-00079e-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 14:43:17 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 13 Nov 2002 09:43:08 +1100
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


After the recent rewrite for nfsd to use a list of pages to hold
request/response, nfsd could not handle a request to create a symlink
larger than about 3800 bytes, as the entire request would exceed one
page.

This is only significant for nfsv3 as nfsv2 limits symlinks to
1024chars.

This patches will, if needed, copy the parts of a symlink from two
separate pages into one newpage, so symlinks upto one page are now
supported.



 ----------- Diffstat output ------------
 fs/nfsd/nfs3xdr.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 41 insertions(+), 2 deletions(-)

diff fs/nfsd/nfs3xdr.c~current~ fs/nfsd/nfs3xdr.c
--- fs/nfsd/nfs3xdr.c~current~	2002-11-12 15:42:34.000000000 +1100
+++ fs/nfsd/nfs3xdr.c	2002-11-12 15:42:34.000000000 +1100
@@ -421,13 +421,52 @@ int
 nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd3_symlinkargs *args)
 {
+	int len;
+	int avail;
+	char *old, *new;
+	struct iovec *vec;
+
 	if (!(p = decode_fh(p, &args->ffh))
 	 || !(p = decode_filename(p, &args->fname, &args->flen))
 	 || !(p = decode_sattr3(p, &args->attrs))
-	 || !(p = decode_pathname(p, &args->tname, &args->tlen)))
+		)
+		return 0;
+	/* now decode the pathname, which might be larger than the first page.
+	 * As we have to check for nul's anyway, we copy it into a new page
+	 * This page appears in the rq_res.pages list, but as pages_len is always
+	 * 0, it won't get in the way
+	 */
+	svc_take_page(rqstp);
+	len = ntohl(*p++);
+	if (len <= 0 || len > NFS3_MAXPATHLEN)
+		return 0;
+	args->tname = new = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
+	args->tlen = len;
+	/* first copy and check from the first page */
+	old = (char*)p;
+	vec = &rqstp->rq_arg.head[0];
+	avail = vec->iov_len - (old - (char*)vec->iov_base);
+	while (len > 0 && *old && avail) {
+		*new++ = *old++;
+		len--;
+		avail--;
+	}
+	/* now copy next page if there is one */
+	if (len && !avail && rqstp->rq_arg.page_len) {
+		avail = rqstp->rq_arg.page_len;
+		if (avail > PAGE_SIZE) avail = PAGE_SIZE;
+		old = page_address(rqstp->rq_arg.pages[0]);
+	}
+	while (len > 0 && *old && avail) {
+		*new++ = *old++;
+		len--;
+		avail--;
+	}
+	*new = '\0';
+	if (len)
 		return 0;
 
-	return xdr_argsize_check(rqstp, p);
+	return 1;
 }
 
 int


-------------------------------------------------------
This sf.net email is sponsored by: 
To learn the basics of securing your web site with SSL, 
click here to get a FREE TRIAL of a Thawte Server Certificate: 
http://www.gothawte.com/rd522.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
