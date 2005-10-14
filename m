From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 004 of 4] Fix some minor sign problems in nfsd/xdr
Date: Fri, 14 Oct 2005 12:23:09 +1000
Message-ID: <1051014022309.11579@cse.unsw.edu.au>
References: <20051014122041.11376.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQFE6-0006Re-7E
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:18 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EQFE4-0006Jg-Lo
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:18 -0700
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


There are a couple of tests which could possibly be confused by
extremely large numbers appearing in 'xdr' packets.
I think the closest to an exploit you could get would be writing
random data from a free page into a file - i.e. leak data
out of kernel space.

I'm fairly sure they cannot be used for remote compromise.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs3xdr.c          |    3 ++-
 ./include/linux/nfsd/xdr3.h  |    2 +-
 ./include/linux/sunrpc/svc.h |    3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2005-10-14 12:03:04.000000000 +1000
@@ -366,7 +366,8 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	len = args->len = ntohl(*p++);
 
 	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
-	if (rqstp->rq_arg.len < len + hdr)
+	if (rqstp->rq_arg.len < hdr ||
+	    rqstp->rq_arg.len - hdr < len)
 		return 0;
 
 	args->vec[0].iov_base = (void*)p;

diff ./include/linux/nfsd/xdr3.h~current~ ./include/linux/nfsd/xdr3.h
--- ./include/linux/nfsd/xdr3.h~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./include/linux/nfsd/xdr3.h	2005-10-14 12:03:04.000000000 +1000
@@ -42,7 +42,7 @@ struct nfsd3_writeargs {
 	__u64			offset;
 	__u32			count;
 	int			stable;
-	int			len;
+	__u32			len;
 	struct kvec		vec[RPCSVC_MAXPAGES];
 	int			vlen;
 };

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2005-10-14 12:03:04.000000000 +1000
@@ -171,7 +171,8 @@ xdr_argsize_check(struct svc_rqst *rqstp
 {
 	char *cp = (char *)p;
 	struct kvec *vec = &rqstp->rq_arg.head[0];
-	return cp - (char*)vec->iov_base <= vec->iov_len;
+	return cp >= (char*)vec->iov_base
+		&& cp <= (char*)vec->iov_base + vec->iov_len;
 }
 
 static inline int


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
