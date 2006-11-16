From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/21] SUNRPC: skb_read_bits is the same as
	xs_tcp_copy_data
Date: Thu, 16 Nov 2006 15:04:29 -0500
Message-ID: <20061116200428.32549.26493.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1X-0006rO-E4
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:51 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1W-0004sO-MH
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:51 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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

Clean-up: eliminate xs_tcp_copy_data -- it's exactly the same logic as the
common routine skb_read_bits.  The UDP and TCP socket read code now share
the same routine for copying data into an xdr_buf.

Now that skb_read_bits() is exported, rename it to avoid confusing it with
a generic skb_* function.  As these functions are XDR-specific, they should
not have names that suggest they are of generic use.  Also rename
skb_read_and_csum_bits() to be consistent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/socklib.c       |   14 +++++++-------
 net/sunrpc/xprtsock.c      |   24 ++++--------------------
 3 files changed, 12 insertions(+), 27 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index ac69e55..b5728ca 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -156,6 +156,7 @@ typedef struct {
 
 typedef size_t (*skb_read_actor_t)(skb_reader_t *desc, void *to, size_t len);
 
+size_t xdr_skb_read_bits(skb_reader_t *desc, void *to, size_t len);
 extern int csum_partial_copy_to_xdr(struct xdr_buf *, struct sk_buff *);
 extern ssize_t xdr_partial_copy_from_skb(struct xdr_buf *, unsigned int,
 		skb_reader_t *, skb_read_actor_t);
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 6f17527..cb7d46b 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -16,7 +16,7 @@ #include <linux/sunrpc/xdr.h>
 
 
 /**
- * skb_read_bits - copy some data bits from skb to internal buffer
+ * xdr_skb_read_bits - copy some data bits from skb to internal buffer
  * @desc: sk_buff copy helper
  * @to: copy destination
  * @len: number of bytes to copy
@@ -24,11 +24,11 @@ #include <linux/sunrpc/xdr.h>
  * Possibly called several times to iterate over an sk_buff and copy
  * data out of it.
  */
-static size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len)
+size_t xdr_skb_read_bits(skb_reader_t *desc, void *to, size_t len)
 {
 	if (len > desc->count)
 		len = desc->count;
-	if (skb_copy_bits(desc->skb, desc->offset, to, len))
+	if (unlikely(skb_copy_bits(desc->skb, desc->offset, to, len)))
 		return 0;
 	desc->count -= len;
 	desc->offset += len;
@@ -36,14 +36,14 @@ static size_t skb_read_bits(skb_reader_t
 }
 
 /**
- * skb_read_and_csum_bits - copy and checksum from skb to buffer
+ * xdr_skb_read_and_csum_bits - copy and checksum from skb to buffer
  * @desc: sk_buff copy helper
  * @to: copy destination
  * @len: number of bytes to copy
  *
  * Same as skb_read_bits, but calculate a checksum at the same time.
  */
-static size_t skb_read_and_csum_bits(skb_reader_t *desc, void *to, size_t len)
+static size_t xdr_skb_read_and_csum_bits(skb_reader_t *desc, void *to, size_t len)
 {
 	unsigned int	csum2, pos;
 
@@ -157,7 +157,7 @@ int csum_partial_copy_to_xdr(struct xdr_
 		goto no_checksum;
 
 	desc.csum = csum_partial(skb->data, desc.offset, skb->csum);
-	if (xdr_partial_copy_from_skb(xdr, 0, &desc, skb_read_and_csum_bits) < 0)
+	if (xdr_partial_copy_from_skb(xdr, 0, &desc, xdr_skb_read_and_csum_bits) < 0)
 		return -1;
 	if (desc.offset != skb->len) {
 		unsigned int csum2;
@@ -172,7 +172,7 @@ int csum_partial_copy_to_xdr(struct xdr_
 		netdev_rx_csum_fault(skb->dev);
 	return 0;
 no_checksum:
-	if (xdr_partial_copy_from_skb(xdr, 0, &desc, skb_read_bits) < 0)
+	if (xdr_partial_copy_from_skb(xdr, 0, &desc, xdr_skb_read_bits) < 0)
 		return -1;
 	if (desc.count)
 		return -1;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9afa987..4de26bd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -661,22 +661,6 @@ static void xs_udp_data_ready(struct soc
 	read_unlock(&sk->sk_callback_lock);
 }
 
-static inline size_t xs_tcp_copy_data(skb_reader_t *desc, void *p, size_t len)
-{
-	if (len > desc->count)
-		len = desc->count;
-	if (skb_copy_bits(desc->skb, desc->offset, p, len)) {
-		dprintk("RPC:      failed to copy %zu bytes from skb. %zu bytes remain\n",
-				len, desc->count);
-		return 0;
-	}
-	desc->offset += len;
-	desc->count -= len;
-	dprintk("RPC:      copied %zu bytes from skb. %zu bytes remain\n",
-			len, desc->count);
-	return len;
-}
-
 static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, skb_reader_t *desc)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -685,7 +669,7 @@ static inline void xs_tcp_read_fraghdr(s
 
 	p = ((char *) &transport->tcp_fraghdr) + transport->tcp_offset;
 	len = sizeof(transport->tcp_fraghdr) - transport->tcp_offset;
-	used = xs_tcp_copy_data(desc, p, len);
+	used = xdr_skb_read_bits(desc, p, len);
 	transport->tcp_offset += used;
 	if (used != len)
 		return;
@@ -731,7 +715,7 @@ static inline void xs_tcp_read_xid(struc
 	len = sizeof(transport->tcp_xid) - transport->tcp_offset;
 	dprintk("RPC:      reading XID (%Zu bytes)\n", len);
 	p = ((char *) &transport->tcp_xid) + transport->tcp_offset;
-	used = xs_tcp_copy_data(desc, p, len);
+	used = xdr_skb_read_bits(desc, p, len);
 	transport->tcp_offset += used;
 	if (used != len)
 		return;
@@ -771,12 +755,12 @@ static inline void xs_tcp_read_request(s
 		memcpy(&my_desc, desc, sizeof(my_desc));
 		my_desc.count = len;
 		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
-					  &my_desc, xs_tcp_copy_data);
+					  &my_desc, xdr_skb_read_bits);
 		desc->count -= r;
 		desc->offset += r;
 	} else
 		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
-					  desc, xs_tcp_copy_data);
+					  desc, xdr_skb_read_bits);
 
 	if (r > 0) {
 		transport->tcp_copied += r;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
