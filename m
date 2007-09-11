From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/15] NFS: Convert printk's to dprintk's in
	fs/nfs/nfs?xdr.c
Date: Tue, 11 Sep 2007 18:01:10 -0400
Message-ID: <20070911220109.26136.81881.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDnR-0006yC-2a
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:25 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDnV-00022y-CC
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:29 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Due to recent edict to replace or remove printk's that can be triggered en
masse by remote misbehavior.  Left a few that only occur just before a BUG.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   18 +++++++++---------
 fs/nfs/nfs3xdr.c |   23 ++++++++++++-----------
 fs/nfs/nfs4xdr.c |   43 +++++++++++++++++++++----------------------
 3 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index c5fce75..1c57094 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -271,7 +271,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	res->eof = 0;
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READ reply header overflowed:"
+		dprintk("NFS: READ reply header overflowed:"
 				"length %d > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
@@ -281,7 +281,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
-		printk(KERN_WARNING "NFS: server cheating in read reply: "
+		dprintk("NFS: server cheating in read reply: "
 			"count %d > recvd %d\n", count, recvd);
 		count = recvd;
 	}
@@ -431,7 +431,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READDIR reply header overflowed:"
+		dprintk("NFS: READDIR reply header overflowed:"
 				"length %d > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
@@ -454,7 +454,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 		len = ntohl(*p++);
 		p += XDR_QUADLEN(len) + 1;	/* name plus cookie */
 		if (len > NFS2_MAXNAMLEN) {
-			printk(KERN_WARNING "NFS: giant filename in readdir (len 0x%x)!\n",
+			dprintk("NFS: giant filename in readdir (len 0x%x)!\n",
 						len);
 			goto err_unmap;
 		}
@@ -471,7 +471,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	entry[0] = entry[1] = 0;
 	/* truncate listing ? */
 	if (!nr) {
-		printk(KERN_NOTICE "NFS: readdir reply truncated!\n");
+		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
 	}
 	goto out;
@@ -583,12 +583,12 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	/* Convert length of symlink */
 	len = ntohl(*p++);
 	if (len >= rcvbuf->page_len || len <= 0) {
-		dprintk(KERN_WARNING "nfs: server returned giant symlink!\n");
+		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READLINK reply header overflowed:"
+		dprintk("NFS: READLINK reply header overflowed:"
 				"length %d > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
@@ -597,7 +597,7 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	}
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (recvd < len) {
-		printk(KERN_WARNING "NFS: server cheating in readlink reply: "
+		dprintk("NFS: server cheating in readlink reply: "
 				"count %u > recvd %u\n", len, recvd);
 		return -EIO;
 	}
@@ -695,7 +695,7 @@ nfs_stat_to_errno(int stat)
 		if (nfs_errtbl[i].stat == stat)
 			return nfs_errtbl[i].errno;
 	}
-	printk(KERN_ERR "nfs_stat_to_errno: bad nfs status return value: %d\n", stat);
+	dprintk("nfs_stat_to_errno: bad nfs status return value: %d\n", stat);
 	return nfs_errtbl[i].errno;
 }
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d9e08f0..8a225fb 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -524,7 +524,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READDIR reply header overflowed:"
+		dprintk("NFS: READDIR reply header overflowed:"
 				"length %d > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
@@ -547,7 +547,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 		len = ntohl(*p++);		/* string length */
 		p += XDR_QUADLEN(len) + 2;	/* name + cookie */
 		if (len > NFS3_MAXNAMLEN) {
-			printk(KERN_WARNING "NFS: giant filename in readdir (len %x)!\n",
+			dprintk("NFS: giant filename in readdir (len %x)!\n",
 						len);
 			goto err_unmap;
 		}
@@ -567,7 +567,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 					goto short_pkt;
 				len = ntohl(*p++);
 				if (len > NFS3_FHSIZE) {
-					printk(KERN_WARNING "NFS: giant filehandle in "
+					dprintk("NFS: giant filehandle in "
 						"readdir (len %x)!\n", len);
 					goto err_unmap;
 				}
@@ -588,7 +588,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	entry[0] = entry[1] = 0;
 	/* truncate listing ? */
 	if (!nr) {
-		printk(KERN_NOTICE "NFS: readdir reply truncated!\n");
+		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
 	}
 	goto out;
@@ -826,22 +826,23 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	/* Convert length of symlink */
 	len = ntohl(*p++);
 	if (len >= rcvbuf->page_len || len <= 0) {
-		dprintk(KERN_WARNING "nfs: server returned giant symlink!\n");
+		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
 
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READLINK reply header overflowed:"
+		dprintk("NFS: READLINK reply header overflowed:"
 				"length %d > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READLINK header is short. iovec will be shifted.\n");
+		dprintk("NFS: READLINK header is short. "
+			"iovec will be shifted.\n");
 		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
 	}
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (recvd < len) {
-		printk(KERN_WARNING "NFS: server cheating in readlink reply: "
+		dprintk("NFS: server cheating in readlink reply: "
 				"count %u > recvd %u\n", len, recvd);
 		return -EIO;
 	}
@@ -876,13 +877,13 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	ocount   = ntohl(*p++);
 
 	if (ocount != count) {
-		printk(KERN_WARNING "NFS: READ count doesn't match RPC opaque count.\n");
+		dprintk("NFS: READ count doesn't match RPC opaque count.\n");
 		return -errno_NFSERR_IO;
 	}
 
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READ reply header overflowed:"
+		dprintk("NFS: READ reply header overflowed:"
 				"length %d > %Zu\n", hdrlen, iov->iov_len);
        		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
@@ -892,7 +893,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
-		printk(KERN_WARNING "NFS: server cheating in read reply: "
+		dprintk("NFS: server cheating in read reply: "
 			"count %d > recvd %d\n", count, recvd);
 		count = recvd;
 		res->eof = 0;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1fde1e7..e95a2e6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -564,7 +564,6 @@ struct compound_hdr {
 
 #define RESERVE_SPACE(nbytes)	do {				\
 	p = xdr_reserve_space(xdr, nbytes);			\
-	if (!p) printk("RESERVE_SPACE(%d) failed in function %s\n", (int) (nbytes), __FUNCTION__); \
 	BUG_ON(!p);						\
 } while (0)
 
@@ -630,8 +629,8 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	if (iap->ia_valid & ATTR_UID) {
 		owner_namelen = nfs_map_uid_to_name(server->nfs_client, iap->ia_uid, owner_name);
 		if (owner_namelen < 0) {
-			printk(KERN_WARNING "nfs: couldn't resolve uid %d to string\n",
-			       iap->ia_uid);
+			dprintk("nfs: couldn't resolve uid %d to string\n",
+					iap->ia_uid);
 			/* XXX */
 			strcpy(owner_name, "nobody");
 			owner_namelen = sizeof("nobody") - 1;
@@ -642,8 +641,8 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	if (iap->ia_valid & ATTR_GID) {
 		owner_grouplen = nfs_map_gid_to_group(server->nfs_client, iap->ia_gid, owner_group);
 		if (owner_grouplen < 0) {
-			printk(KERN_WARNING "nfs4: couldn't resolve gid %d to string\n",
-			       iap->ia_gid);
+			dprintk("nfs: couldn't resolve gid %d to string\n",
+					iap->ia_gid);
 			strcpy(owner_group, "nobody");
 			owner_grouplen = sizeof("nobody") - 1;
 			/* goto out; */
@@ -713,7 +712,7 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	 * Now we backfill the bitmap and the attribute buffer length.
 	 */
 	if (len != ((char *)p - (char *)q) + 4) {
-		printk ("encode_attr: Attr length calculation error! %u != %Zu\n",
+		printk(KERN_ERR "nfs: Attr length error, %u != %Zu\n",
 				len, ((char *)p - (char *)q) + 4);
 		BUG();
 	}
@@ -2188,9 +2187,9 @@ out:
 #define READ_BUF(nbytes)  do { \
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (unlikely(!p)) { \
-		printk(KERN_INFO "%s: prematurely hit end of receive" \
+		dprintk("nfs: %s: prematurely hit end of receive" \
 				" buffer\n", __FUNCTION__); \
-		printk(KERN_INFO "%s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
+		dprintk("nfs: %s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
 				__FUNCTION__, xdr->p, nbytes, xdr->end); \
 		return -EIO; \
 	} \
@@ -2231,9 +2230,8 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	READ_BUF(8);
 	READ32(opnum);
 	if (opnum != expected) {
-		printk(KERN_NOTICE
-				"nfs4_decode_op_hdr: Server returned operation"
-			       	" %d but we issued a request for %d\n",
+		dprintk("nfs: Server returned operation"
+			" %d but we issued a request for %d\n",
 				opnum, expected);
 		return -EIO;
 	}
@@ -2766,7 +2764,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 				dprintk("%s: nfs_map_name_to_uid failed!\n",
 						__FUNCTION__);
 		} else
-			printk(KERN_WARNING "%s: name too long (%u)!\n",
+			dprintk("%s: name too long (%u)!\n",
 					__FUNCTION__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER;
 	}
@@ -2791,7 +2789,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 				dprintk("%s: nfs_map_group_to_gid failed!\n",
 						__FUNCTION__);
 		} else
-			printk(KERN_WARNING "%s: name too long (%u)!\n",
+			dprintk("%s: name too long (%u)!\n",
 					__FUNCTION__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 	}
@@ -2958,7 +2956,8 @@ static int verify_attr_len(struct xdr_stream *xdr, __be32 *savep, uint32_t attrl
 	unsigned int nwords = xdr->p - savep;
 
 	if (unlikely(attrwords != nwords)) {
-		printk(KERN_WARNING "%s: server returned incorrect attribute length: %u %c %u\n",
+		dprintk("%s: server returned incorrect attribute length: "
+			"%u %c %u\n",
 				__FUNCTION__,
 				attrwords << 2,
 				(attrwords < nwords) ? '<' : '>',
@@ -3459,7 +3458,7 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
-		printk(KERN_WARNING "NFS: server cheating in read reply: "
+		dprintk("NFS: server cheating in read reply: "
 				"count %u > recvd %u\n", count, recvd);
 		count = recvd;
 		eof = 0;
@@ -3508,7 +3507,8 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		p += 2;			/* cookie */
 		len = ntohl(*p++);	/* filename length */
 		if (len > NFS4_MAXNAMLEN) {
-			printk(KERN_WARNING "NFS: giant filename in readdir (len 0x%x)\n", len);
+			dprintk("NFS: giant filename in readdir (len 0x%x)\n",
+					len);
 			goto err_unmap;
 		}
 		xlen = XDR_QUADLEN(len);
@@ -3536,7 +3536,7 @@ short_pkt:
 	entry[0] = entry[1] = 0;
 	/* truncate listing ? */
 	if (!nr) {
-		printk(KERN_NOTICE "NFS: readdir reply truncated!\n");
+		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
 	}
 	goto out;
@@ -3562,13 +3562,13 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	READ_BUF(4);
 	READ32(len);
 	if (len >= rcvbuf->page_len || len <= 0) {
-		dprintk(KERN_WARNING "nfs: server returned giant symlink!\n");
+		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
 	hdrlen = (char *) xdr->p - (char *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (recvd < len) {
-		printk(KERN_WARNING "NFS: server cheating in readlink reply: "
+		dprintk("NFS: server cheating in readlink reply: "
 				"count %u > recvd %u\n", len, recvd);
 		return -EIO;
 	}
@@ -3651,7 +3651,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		hdrlen = (u8 *)xdr->p - (u8 *)iov->iov_base;
 		recvd = req->rq_rcv_buf.len - hdrlen;
 		if (attrlen > recvd) {
-			printk(KERN_WARNING "NFS: server cheating in getattr"
+			dprintk("NFS: server cheating in getattr"
 					" acl reply: attrlen %u > recvd %u\n",
 					attrlen, recvd);
 			return -EINVAL;
@@ -3696,8 +3696,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	READ_BUF(8);
 	READ32(opnum);
 	if (opnum != OP_SETCLIENTID) {
-		printk(KERN_NOTICE
-				"nfs4_decode_setclientid: Server returned operation"
+		dprintk("nfs: decode_setclientid: Server returned operation"
 			       	" %d\n", opnum);
 		return -EIO;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
