From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 9/9] SUNRPC: skb_read_bits is the same as
	xs_tcp_copy_data
Date: Thu, 12 Oct 2006 17:15:23 -0400
Message-ID: <20061012211523.8734.63869.stgit@ingres.dsl.sfldmi.ameritech.net>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GY7tx-00086V-Nw
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 14:15:37 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GY7ty-0002mg-1j
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 14:15:38 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
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

Test plan:
None.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/socklib.c       |    5 +++--
 net/sunrpc/xprtsock.c      |   24 ++++--------------------
 3 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 953723b..73b700e 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -155,6 +155,7 @@ typedef struct {
 
 typedef size_t (*skb_read_actor_t)(skb_reader_t *desc, void *to, size_t len);
 
+size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len);
 extern int csum_partial_copy_to_xdr(struct xdr_buf *, struct sk_buff *);
 extern ssize_t xdr_partial_copy_from_skb(struct xdr_buf *, unsigned int,
 		skb_reader_t *, skb_read_actor_t);
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 6f17527..9d20136 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -24,16 +24,17 @@ #include <linux/sunrpc/xdr.h>
  * Possibly called several times to iterate over an sk_buff and copy
  * data out of it.
  */
-static size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len)
+size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len)
 {
 	if (len > desc->count)
 		len = desc->count;
-	if (skb_copy_bits(desc->skb, desc->offset, to, len))
+	if (unlikely(skb_copy_bits(desc->skb, desc->offset, to, len)))
 		return 0;
 	desc->count -= len;
 	desc->offset += len;
 	return len;
 }
+EXPORT_SYMBOL_GPL(skb_read_bits);
 
 /**
  * skb_read_and_csum_bits - copy and checksum from skb to buffer
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index de15e42..0eb958f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -667,22 +667,6 @@ static void xs_udp_data_ready(struct soc
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
 	struct xs_xprt *private = xs_private_data(xprt);
@@ -691,7 +675,7 @@ static inline void xs_tcp_read_fraghdr(s
 
 	p = ((char *) &private->tcp_fraghdr) + private->tcp_offset;
 	len = sizeof(private->tcp_fraghdr) - private->tcp_offset;
-	used = xs_tcp_copy_data(desc, p, len);
+	used = skb_read_bits(desc, p, len);
 	private->tcp_offset += used;
 	if (used != len)
 		return;
@@ -737,7 +721,7 @@ static inline void xs_tcp_read_xid(struc
 	len = sizeof(private->tcp_xid) - private->tcp_offset;
 	dprintk("RPC:      reading XID (%Zu bytes)\n", len);
 	p = ((char *) &private->tcp_xid) + private->tcp_offset;
-	used = xs_tcp_copy_data(desc, p, len);
+	used = skb_read_bits(desc, p, len);
 	private->tcp_offset += used;
 	if (used != len)
 		return;
@@ -777,12 +761,12 @@ static inline void xs_tcp_read_request(s
 		memcpy(&my_desc, desc, sizeof(my_desc));
 		my_desc.count = len;
 		r = xdr_partial_copy_from_skb(rcvbuf, private->tcp_copied,
-					  &my_desc, xs_tcp_copy_data);
+					  &my_desc, skb_read_bits);
 		desc->count -= r;
 		desc->offset += r;
 	} else
 		r = xdr_partial_copy_from_skb(rcvbuf, private->tcp_copied,
-					  desc, xs_tcp_copy_data);
+					  desc, skb_read_bits);
 
 	if (r > 0) {
 		private->tcp_copied += r;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
