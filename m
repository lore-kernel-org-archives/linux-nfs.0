From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 4] Fix two xdr-encode bugs for readdirplus reply
Date: Fri, 20 Aug 2004 16:51:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1By3FQ-00073C-6b@notabene.cse.unsw.edu.au>
References: <20040820164909.27056.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By3Fc-0004fx-OG
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1By3Fc-0006lL-67
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:48 -0700
To: Andrew Morton <akpm@osdl.org>
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


More fall-out from the change to allow multi-page 
replies to readdir requests.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs3proc.c |   12 ++++++++++--
 ./fs/nfsd/nfs3xdr.c  |   10 ++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs3proc.c~current~ ./fs/nfsd/nfs3proc.c
--- ./fs/nfsd/nfs3proc.c~current~	2004-08-20 16:38:12.000000000 +1000
+++ ./fs/nfsd/nfs3proc.c	2004-08-20 16:46:46.000000000 +1000
@@ -492,8 +492,16 @@ nfsd3_proc_readdirplus(struct svc_rqst *
 		count += PAGE_SIZE;
 	}
 	resp->count = count >> 2;
-	if (resp->offset)
-		xdr_encode_hyper(resp->offset, offset);
+	if (resp->offset) {
+		if (unlikely(resp->offset1)) {
+			/* we ended up with offset on a page boundary */
+			*resp->offset = htonl(offset >> 32);
+			*resp->offset1 = htonl(offset & 0xffffffff);
+			resp->offset1 = NULL;
+		} else {
+			xdr_encode_hyper(resp->offset, offset);
+		}
+	}
 
 	RETURN_STATUS(nfserr);
 }

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2004-08-20 16:38:12.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2004-08-20 16:38:21.000000000 +1000
@@ -762,10 +762,16 @@ nfs3svc_encode_readdirres(struct svc_rqs
 		/* stupid readdir cookie */
 		memcpy(p, resp->verf, 8); p += 2;
 		xdr_ressize_check(rqstp, p);
-		p = resp->buffer;
+		if (rqstp->rq_res.head[0].iov_len + (2<<2) > PAGE_SIZE)
+			return 1; /*No room for trailer */
+		rqstp->rq_res.page_len = (resp->count) << 2;
+
+		/* add the 'tail' to the end of the 'head' page - page 0. */
+		rqstp->rq_restailpage = 0;
+		rqstp->rq_res.tail[0].iov_base = p;
 		*p++ = 0;		/* no more entries */
 		*p++ = htonl(resp->common.err == nfserr_eof);
-		rqstp->rq_res.page_len = (resp->count + 2) << 2;
+		rqstp->rq_res.tail[0].iov_len = 2<<2;
 		return 1;
 	} else
 		return xdr_ressize_check(rqstp, p);


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
