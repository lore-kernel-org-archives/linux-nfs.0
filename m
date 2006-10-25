From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] SUNRPC: Rename skb_reader_t and friends
Date: Wed, 25 Oct 2006 12:47:23 -0400
Message-ID: <20061025164722.6410.84105.stgit@localhost.localdomain>
References: <20061025164602.6410.27449.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcrR6-0006WH-EM
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:41:26 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcrR6-0003rp-Gd
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:41:25 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061025164602.6410.27449.stgit@localhost.localdomain>
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

Clean-up:  hch suggested that the RPC client shouldn't pollute the name
space used by the generic skb manipulation routines in net/core/skbuff.c.

Rename a couple of types in xdr.h to adhere to this convention.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xdr.h |    8 ++++----
 net/sunrpc/socklib.c       |    8 ++++----
 net/sunrpc/xprtsock.c      |   12 ++++++------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index b5728ca..a91a22a 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -152,14 +152,14 @@ typedef struct {
 	unsigned int	offset;
 	size_t		count;
 	unsigned int	csum;
-} skb_reader_t;
+} xdr_skb_reader_t;
 
-typedef size_t (*skb_read_actor_t)(skb_reader_t *desc, void *to, size_t len);
+typedef size_t (*xdr_skb_read_actor_t)(xdr_skb_reader_t *desc, void *to, size_t len);
 
-size_t xdr_skb_read_bits(skb_reader_t *desc, void *to, size_t len);
+size_t xdr_skb_read_bits(xdr_skb_reader_t *desc, void *to, size_t len);
 extern int csum_partial_copy_to_xdr(struct xdr_buf *, struct sk_buff *);
 extern ssize_t xdr_partial_copy_from_skb(struct xdr_buf *, unsigned int,
-		skb_reader_t *, skb_read_actor_t);
+		xdr_skb_reader_t *, xdr_skb_read_actor_t);
 
 extern int xdr_encode_word(struct xdr_buf *, int, u32);
 extern int xdr_decode_word(struct xdr_buf *, int, u32 *);
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 4bb37e8..2ba1888 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -24,7 +24,7 @@ #include <linux/sunrpc/xdr.h>
  * Possibly called several times to iterate over an sk_buff and copy
  * data out of it.
  */
-size_t xdr_skb_read_bits(skb_reader_t *desc, void *to, size_t len)
+size_t xdr_skb_read_bits(xdr_skb_reader_t *desc, void *to, size_t len)
 {
 	if (len > desc->count)
 		len = desc->count;
@@ -43,7 +43,7 @@ size_t xdr_skb_read_bits(skb_reader_t *d
  *
  * Same as skb_read_bits, but calculate a checksum at the same time.
  */
-static size_t xdr_skb_read_and_csum_bits(skb_reader_t *desc, void *to, size_t len)
+static size_t xdr_skb_read_and_csum_bits(xdr_skb_reader_t *desc, void *to, size_t len)
 {
 	unsigned int	csum2, pos;
 
@@ -65,7 +65,7 @@ static size_t xdr_skb_read_and_csum_bits
  * @copy_actor: virtual method for copying data
  *
  */
-ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, skb_reader_t *desc, skb_read_actor_t copy_actor)
+ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, xdr_skb_reader_t *desc, xdr_skb_read_actor_t copy_actor)
 {
 	struct page	**ppage = xdr->pages;
 	unsigned int	len, pglen = xdr->page_len;
@@ -147,7 +147,7 @@ out:
  */
 int csum_partial_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 {
-	skb_reader_t	desc;
+	xdr_skb_reader_t	desc;
 
 	desc.skb = skb;
 	desc.offset = sizeof(struct udphdr);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7ec1ea6..cedf752 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -661,7 +661,7 @@ static void xs_udp_data_ready(struct soc
 	read_unlock(&sk->sk_callback_lock);
 }
 
-static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, skb_reader_t *desc)
+static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, xdr_skb_reader_t *desc)
 {
 	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 	size_t len, used;
@@ -707,7 +707,7 @@ static void xs_tcp_check_fraghdr(struct 
 	}
 }
 
-static inline void xs_tcp_read_xid(struct sock_xprt *sx, skb_reader_t *desc)
+static inline void xs_tcp_read_xid(struct sock_xprt *sx, xdr_skb_reader_t *desc)
 {
 	size_t len, used;
 	char *p;
@@ -727,7 +727,7 @@ static inline void xs_tcp_read_xid(struc
 	xs_tcp_check_fraghdr(sx);
 }
 
-static inline void xs_tcp_read_request(struct rpc_xprt *xprt, skb_reader_t *desc)
+static inline void xs_tcp_read_request(struct rpc_xprt *xprt, xdr_skb_reader_t *desc)
 {
 	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
@@ -749,7 +749,7 @@ static inline void xs_tcp_read_request(s
 	rcvbuf = &req->rq_private_buf;
 	len = desc->count;
 	if (len > sx->tcp_reclen - sx->tcp_offset) {
-		skb_reader_t my_desc;
+		xdr_skb_reader_t my_desc;
 
 		len = sx->tcp_reclen - sx->tcp_offset;
 		memcpy(&my_desc, desc, sizeof(my_desc));
@@ -803,7 +803,7 @@ out:
 	xs_tcp_check_fraghdr(sx);
 }
 
-static inline void xs_tcp_read_discard(struct sock_xprt *sx, skb_reader_t *desc)
+static inline void xs_tcp_read_discard(struct sock_xprt *sx, xdr_skb_reader_t *desc)
 {
 	size_t len;
 
@@ -821,7 +821,7 @@ static int xs_tcp_data_recv(read_descrip
 {
 	struct rpc_xprt *xprt = rd_desc->arg.data;
 	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
-	skb_reader_t desc = {
+	xdr_skb_reader_t desc = {
 		.skb	= skb,
 		.offset	= offset,
 		.count	= len,

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
