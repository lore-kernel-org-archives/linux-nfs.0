From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH] the NFSv2/NFSv3 server does not handle zero length
 WRITE requests correctly
Date: Thu, 15 Feb 2007 11:41:26 -0500
Message-ID: <45D48D36.4050508@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040305010100000802080104"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HHjg1-00020I-I4
	for nfs@lists.sourceforge.net; Thu, 15 Feb 2007 08:41:45 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HHjfy-0006oC-Jc
	for nfs@lists.sourceforge.net; Thu, 15 Feb 2007 08:41:47 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------040305010100000802080104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

The NFSv2 and NFSv3 servers do not handle WRITE requests for 0 bytes
correctly.  The specifications indicate that the server should accept
the request, but it should mostly turn into a no-op.  Currently, the
server will return an XDR decode error, which it should not.

Attached is a patch which addresses this issue.  It also adds some
boundary checking to ensure that the request contains as much data
as was requested to be written.  It also correctly handles an NFSv3
request which requests to write more data than the server has stated
that it is prepared to handle.  Previously, there was some support
which looked like it should work, but wasn't quite right.

Questions or comments?

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------040305010100000802080104
Content-Type: text/plain;
 name="nfsxdr.devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfsxdr.devel"

--- linux-2.6.20.i686/fs/nfsd/nfsxdr.c.org
+++ linux-2.6.20.i686/fs/nfsd/nfsxdr.c
@@ -271,8 +271,9 @@ int
 nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_writeargs *args)
 {
-	unsigned int len;
+	unsigned int len, hdr, dlen;
 	int v;
+
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 
@@ -280,11 +281,42 @@ nfssvc_decode_writeargs(struct svc_rqst 
 	args->offset = ntohl(*p++);	/* offset */
 	p++;				/* totalcount */
 	len = args->len = ntohl(*p++);
-	rqstp->rq_vec[0].iov_base = (void*)p;
-	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len -
-				(((void*)p) - rqstp->rq_arg.head[0].iov_base);
+	/*
+	 * The protocol specifies a maximum of 8192 bytes.
+	 */
 	if (len > NFSSVC_MAXBLKSIZE_V2)
-		len = NFSSVC_MAXBLKSIZE_V2;
+		return 0;
+
+	/*
+	 * Check to make sure that we got the right number of
+	 * bytes.
+	 *
+	 * If more than one page was used, then compute the length
+	 * of the data in the request as the total size of the
+	 * request minus the transport protocol headers minus the
+	 * RPC protocol headers minus the NFS protocol fields
+	 * already consumed.  If the request fits into a single
+	 * page, then compete the length of the data as the size
+	 * of the NFS portion of the request minus the NFS
+	 * protocol fields already consumed.
+	 */
+	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
+	if (rqstp->rq_respages != rqstp->rq_pages + 1) {
+		dlen = rqstp->rq_arg.len -
+			(PAGE_SIZE - rqstp->rq_arg.head[0].iov_len) - hdr;
+	} else {
+		dlen = rqstp->rq_arg.head[0].iov_len - hdr;
+	}
+	/*
+	 * Round the length of the data which was specified up to
+	 * the next multiple of XDR units and then compare that
+	 * against the length which was actually received.
+	 */
+	if (dlen != ((len + 3) & ~0x3))
+		return 0;
+
+	rqstp->rq_vec[0].iov_base = (void*)p;
+	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
 	v = 0;
 	while (len > rqstp->rq_vec[v].iov_len) {
 		len -= rqstp->rq_vec[v].iov_len;
@@ -293,8 +325,8 @@ nfssvc_decode_writeargs(struct svc_rqst 
 		rqstp->rq_vec[v].iov_len = PAGE_SIZE;
 	}
 	rqstp->rq_vec[v].iov_len = len;
-	args->vlen = v+1;
-	return rqstp->rq_vec[0].iov_len > 0;
+	args->vlen = v + 1;
+	return 1;
 }
 
 int
--- linux-2.6.20.i686/fs/nfsd/nfs3xdr.c.org
+++ linux-2.6.20.i686/fs/nfsd/nfs3xdr.c
@@ -354,7 +354,7 @@ int
 nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_writeargs *args)
 {
-	unsigned int len, v, hdr;
+	unsigned int len, v, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
 	if (!(p = decode_fh(p, &args->fh))
@@ -364,18 +364,47 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	args->count = ntohl(*p++);
 	args->stable = ntohl(*p++);
 	len = args->len = ntohl(*p++);
+	/*
+	 * The count must equal the amount of data passed.
+	 */
+	if (args->count != args->len)
+		return 0;
 
+	/*
+	 * Check to make sure that we got the right number of
+	 * bytes.
+	 *
+	 * If more than one page was used, then compute the length
+	 * of the data in the request as the total size of the
+	 * request minus the transport protocol headers minus the
+	 * RPC protocol headers minus the NFS protocol fields
+	 * already consumed.  If the request fits into a single
+	 * page, then compete the length of the data as the size
+	 * of the NFS portion of the request minus the NFS
+	 * protocol fields already consumed.
+	 */
 	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
-	if (rqstp->rq_arg.len < hdr ||
-	    rqstp->rq_arg.len - hdr < len)
+	if (rqstp->rq_respages != rqstp->rq_pages + 1) {
+		dlen = rqstp->rq_arg.len -
+			(PAGE_SIZE - rqstp->rq_arg.head[0].iov_len) - hdr;
+	} else {
+		dlen = rqstp->rq_arg.head[0].iov_len - hdr;
+	}
+	/*
+	 * Round the length of the data which was specified up to
+	 * the next multiple of XDR units and then compare that
+	 * against the length which was actually received.
+	 */
+	if (dlen != ((len + 3) & ~0x3))
 		return 0;
 
+	if (args->count > max_blocksize) {
+		args->count = max_blocksize;
+		len = args->len = max_blocksize;
+	}
 	rqstp->rq_vec[0].iov_base = (void*)p;
 	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
-
-	if (len > max_blocksize)
-		len = max_blocksize;
-	v=  0;
+	v = 0;
 	while (len > rqstp->rq_vec[v].iov_len) {
 		len -= rqstp->rq_vec[v].iov_len;
 		v++;
@@ -383,9 +412,8 @@ nfs3svc_decode_writeargs(struct svc_rqst
 		rqstp->rq_vec[v].iov_len = PAGE_SIZE;
 	}
 	rqstp->rq_vec[v].iov_len = len;
-	args->vlen = v+1;
-
-	return args->count == args->len && rqstp->rq_vec[0].iov_len > 0;
+	args->vlen = v + 1;
+	return 1;
 }
 
 int

--------------040305010100000802080104
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------040305010100000802080104
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040305010100000802080104--
