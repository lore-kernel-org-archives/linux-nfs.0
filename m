From: "David S. Miller" <davem@redhat.com>
Subject: [NEW PATCH] zerocopy UDP stuff
Date: Wed, 16 Oct 2002 01:49:47 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021016.014947.31982846.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au, taka@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pizda.ninka.net ([216.101.162.242])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181jzO-000870-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 01:57:14 -0700
To: linux-net@vger.kernel.org
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


Sorry, there was a bogon in my previous diff that I didn't
notice until after the previous email got sent.  I didn't
apply the "kill csum_partial_copy()" patch completely, so
it would result in link errors on some platforms.

Here is what should be a working patch :-)

ChangeSet@1.845, 2002-10-14 13:41:39-07:00, davem@nuts.ninka.net
  [NET]: Kill final traces of csum_partial_copy_fromuser.

diff -Nru a/include/asm-alpha/checksum.h b/include/asm-alpha/checksum.h
--- a/include/asm-alpha/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-alpha/checksum.h	Wed Oct 16 01:51:56 2002
@@ -42,16 +42,10 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
- */
-unsigned int csum_partial_copy(const char *src, char *dst, int len, unsigned int sum);
-
-/*
- * the same as csum_partial, but copies from user space (but on the alpha
- * we have just one address space, so this is identical to the above)
  *
- * this is obsolete and will go away.
+ * this will go away soon.
  */
-#define csum_partial_copy_fromuser csum_partial_copy
+unsigned int csum_partial_copy(const char *src, char *dst, int len, unsigned int sum);
 
 /*
  * this is a new version of the above that records errors it finds in *errp,
diff -Nru a/include/asm-arm/checksum.h b/include/asm-arm/checksum.h
--- a/include/asm-arm/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-arm/checksum.h	Wed Oct 16 01:51:56 2002
@@ -38,10 +38,10 @@
 csum_partial_copy_from_user(const char *src, char *dst, int len, int sum, int *err_ptr);
 
 /*
- * These are the old (and unsafe) way of doing checksums, a warning message will be
- * printed if they are used and an exception occurs.
+ * This is the old (and unsafe) way of doing checksums, a warning message will
+ * be printed if it is used and an exception occurs.
  *
- * these functions should go away after some time.
+ * this functions should go away after some time.
  */
 #define csum_partial_copy(src,dst,len,sum)	csum_partial_copy_nocheck(src,dst,len,sum)
 
diff -Nru a/include/asm-i386/checksum.h b/include/asm-i386/checksum.h
--- a/include/asm-i386/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-i386/checksum.h	Wed Oct 16 01:51:56 2002
@@ -50,13 +50,11 @@
 }
 
 /*
- * These are the old (and unsafe) way of doing checksums, a warning message will be
- * printed if they are used and an exeption occurs.
+ * This is the old (and unsafe) way of doing checksums, a warning message will
+ * be printed if it is used and an exeption occurs.
  *
- * these functions should go away after some time.
+ * this function should go away after some time.
  */
-
-#define csum_partial_copy_fromuser csum_partial_copy
 unsigned int csum_partial_copy( const char *src, char *dst, int len, int sum);
 
 /*
diff -Nru a/include/asm-ia64/checksum.h b/include/asm-ia64/checksum.h
--- a/include/asm-ia64/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-ia64/checksum.h	Wed Oct 16 01:51:56 2002
@@ -48,18 +48,11 @@
  *
  * Here it is even more important to align src and dst on a 32-bit (or
  * even better 64-bit) boundary.
+ *
+ * this will go away soon.
  */
 extern unsigned int csum_partial_copy (const char *src, char *dst, int len,
 				       unsigned int sum);
-
-/*
- * The same as csum_partial, but copies from user space (but on the
- * ia-64 we have just one address space, so this is identical to the
- * above).
- *
- * This is obsolete and will go away.
- */
-#define csum_partial_copy_fromuser csum_partial_copy
 
 /*
  * This is a new version of the above that records errors it finds in
diff -Nru a/include/asm-m68k/checksum.h b/include/asm-m68k/checksum.h
--- a/include/asm-m68k/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-m68k/checksum.h	Wed Oct 16 01:51:56 2002
@@ -21,6 +21,8 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
+ *
+ * this will go away soon.
  */
 
 unsigned int csum_partial_copy(const char *src, char *dst, int len, int sum);
diff -Nru a/include/asm-mips/checksum.h b/include/asm-mips/checksum.h
--- a/include/asm-mips/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-mips/checksum.h	Wed Oct 16 01:51:56 2002
@@ -61,7 +61,6 @@
  *
  * this is obsolete and will go away.
  */
-#define csum_partial_copy_fromuser csum_partial_copy
 unsigned int csum_partial_copy(const char *src, char *dst, int len,
 			       unsigned int sum);
 
diff -Nru a/include/asm-mips64/checksum.h b/include/asm-mips64/checksum.h
--- a/include/asm-mips64/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-mips64/checksum.h	Wed Oct 16 01:51:56 2002
@@ -63,7 +63,6 @@
  *
  * this is obsolete and will go away.
  */
-#define csum_partial_copy_fromuser csum_partial_copy
 unsigned int csum_partial_copy(const char *src, char *dst, int len,
 			       unsigned int sum);
 
diff -Nru a/include/asm-parisc/checksum.h b/include/asm-parisc/checksum.h
--- a/include/asm-parisc/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-parisc/checksum.h	Wed Oct 16 01:51:56 2002
@@ -21,15 +21,10 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
- */
-extern unsigned int csum_partial_copy(const char *, char *, int, unsigned int);
-
-/*
- * the same as csum_partial, but copies from user space
  *
- * this is obsolete and will go away.
+ * this will go away soon.
  */
-#define csum_partial_copy_fromuser csum_partial_copy
+extern unsigned int csum_partial_copy(const char *, char *, int, unsigned int);
 
 /*
  * this is a new version of the above that records errors it finds in *errp,
diff -Nru a/include/asm-ppc/checksum.h b/include/asm-ppc/checksum.h
--- a/include/asm-ppc/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-ppc/checksum.h	Wed Oct 16 01:51:56 2002
@@ -39,11 +39,10 @@
 #define csum_partial_copy_nocheck(src, dst, len, sum)	\
 	csum_partial_copy_generic((src), (dst), (len), (sum), 0, 0)     
 /*
- * Old versions which ignore errors.
+ * Old version which ignore errors.
+ * it will go away soon.
  */
 #define csum_partial_copy(src, dst, len, sum)	\
-	csum_partial_copy_generic((src), (dst), (len), (sum), 0, 0)
-#define csum_partial_copy_fromuser(src, dst, len, sum)	\
 	csum_partial_copy_generic((src), (dst), (len), (sum), 0, 0)
 
 
diff -Nru a/include/asm-ppc64/checksum.h b/include/asm-ppc64/checksum.h
--- a/include/asm-ppc64/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-ppc64/checksum.h	Wed Oct 16 01:51:56 2002
@@ -43,6 +43,8 @@
 /*
  * the same as csum_partial, but copies from src to dst while it
  * checksums
+ *
+ * csum_partial_copy will go away soon.
  */
 unsigned int csum_partial_copy(const char *src, char *dst, 
 			       int len, unsigned int sum);
@@ -51,14 +53,9 @@
 					      int len, unsigned int sum,
 					      int *src_err, int *dst_err);
 /*
- * the same as csum_partial, but copies from user space.
+ * the same as csum_partial, but copies from src to dst while it
+ * checksums.
  */
-
-unsigned int csum_partial_copy_fromuser(const char *src, 
-					char *dst, 
-					int len, 
-					unsigned int sum,
-					int *src_err);
 
 unsigned int csum_partial_copy_nocheck(const char *src, 
 				       char *dst, 
diff -Nru a/include/asm-s390/checksum.h b/include/asm-s390/checksum.h
--- a/include/asm-s390/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-s390/checksum.h	Wed Oct 16 01:51:56 2002
@@ -67,6 +67,8 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
+ *
+ * this will go away soon.
  */
 
 static inline unsigned int 
diff -Nru a/include/asm-s390x/checksum.h b/include/asm-s390x/checksum.h
--- a/include/asm-s390x/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-s390x/checksum.h	Wed Oct 16 01:51:56 2002
@@ -69,6 +69,8 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
+ *
+ * this will go away soon.
  */
 
 static inline unsigned int 
diff -Nru a/include/asm-sh/checksum.h b/include/asm-sh/checksum.h
--- a/include/asm-sh/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-sh/checksum.h	Wed Oct 16 01:51:56 2002
@@ -58,13 +58,11 @@
 }
 
 /*
- * These are the old (and unsafe) way of doing checksums, a warning message will be
- * printed if they are used and an exeption occurs.
+ * This is the old (and unsafe) way of doing checksums, a warning message will
+ * be printed if it is used and an exeption occurs.
  *
- * these functions should go away after some time.
+ * this function should go away after some time.
  */
-
-#define csum_partial_copy_fromuser csum_partial_copy
 unsigned int csum_partial_copy( const char *src, char *dst, int len, int sum);
 
 /*
diff -Nru a/include/asm-sparc/checksum.h b/include/asm-sparc/checksum.h
--- a/include/asm-sparc/checksum.h	Wed Oct 16 01:51:56 2002
+++ b/include/asm-sparc/checksum.h	Wed Oct 16 01:51:56 2002
@@ -40,11 +40,9 @@
  * better 64-bit) boundary
  */
 
-/* FIXME: Remove these two macros ASAP */
+/* FIXME: Remove this macro ASAP */
 #define csum_partial_copy(src, dst, len, sum) \
  		       csum_partial_copy_nocheck(src,dst,len,sum)
-#define csum_partial_copy_fromuser(s, d, l, w)  \
-                         csum_partial_copy((char *) (s), (d), (l), (w))
   
 extern unsigned int __csum_partial_copy_sparc_generic (const char *, char *);
 


ChangeSet@1.846, 2002-10-15 10:16:08-07:00, rob@osinvestor.com
  [NET]: Remove final traces of csum_partial_copy.

diff -Nru a/arch/i386/lib/old-checksum.c b/arch/i386/lib/old-checksum.c
--- a/arch/i386/lib/old-checksum.c	Wed Oct 16 01:51:58 2002
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,19 +0,0 @@
-/*
- * FIXME: old compatibility stuff, will be removed soon.
- */
-
-#include <net/checksum.h>
-
-unsigned int csum_partial_copy( const char *src, char *dst, int len, int sum)
-{
-	int src_err=0, dst_err=0;
-
-	sum = csum_partial_copy_generic ( src, dst, len, sum, &src_err, &dst_err);
-
-	if (src_err || dst_err)
-		printk("old csum_partial_copy_fromuser(), tell mingo to convert me.\n");
-
-	return sum;
-}
-
-
diff -Nru a/arch/sh/lib/old-checksum.c b/arch/sh/lib/old-checksum.c
--- a/arch/sh/lib/old-checksum.c	Wed Oct 16 01:51:58 2002
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,17 +0,0 @@
-/*
- * FIXME: old compatibility stuff, will be removed soon.
- */
-
-#include <net/checksum.h>
-
-unsigned int csum_partial_copy( const char *src, char *dst, int len, int sum)
-{
-	int src_err=0, dst_err=0;
-
-	sum = csum_partial_copy_generic ( src, dst, len, sum, &src_err, &dst_err);
-
-	if (src_err || dst_err)
-		printk("old csum_partial_copy_fromuser(), tell mingo to convert me.\n");
-
-	return sum;
-}


ChangeSet@1.847, 2002-10-15 14:06:27-07:00, kuznet@ms2.inr.ac.ru
  [TCP]: Handle passive resets correctly in SYN-RECV.

diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	Wed Oct 16 01:52:00 2002
+++ b/net/ipv4/tcp_minisocks.c	Wed Oct 16 01:52:00 2002
@@ -902,13 +902,13 @@
 	 *                  and the incoming segment acknowledges something not yet
 	 *                  sent (the segment carries an unaccaptable ACK) ...
 	 *                  a reset is sent."
+	 *
+	 * Invalid ACK: reset will be sent by listening socket
 	 */
-	if (!(flg & TCP_FLAG_ACK))
-		return NULL;
-
-	/* Invalid ACK: reset will be sent by listening socket */
-	if (TCP_SKB_CB(skb)->ack_seq != req->snt_isn+1)
+	if ((flg & TCP_FLAG_ACK) &&
+	    (TCP_SKB_CB(skb)->ack_seq != req->snt_isn+1))
 		return sk;
+
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
 	 * is essentially ACK extension and too early or too late values
 	 * should cause reset in unsynchronized states.


ChangeSet@1.848, 2002-10-15 16:08:26-07:00, maxk@qualcomm.com
  [NET]: Export sockfd_lookup.

diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Wed Oct 16 01:52:02 2002
+++ b/include/linux/net.h	Wed Oct 16 01:52:02 2002
@@ -144,6 +144,9 @@
 				  const struct iovec * iov, long count, long size);
 extern int 	sock_map_fd(struct socket *sock);
 
+extern struct socket *sockfd_lookup(int fd, int *err);
+#define         sockfd_put(sock) fput(sock->file)
+
 extern int	net_ratelimit(void);
 extern unsigned long net_random(void);
 extern void net_srandom(unsigned long);
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Wed Oct 16 01:52:02 2002
+++ b/net/netsyms.c	Wed Oct 16 01:52:02 2002
@@ -161,6 +161,7 @@
 EXPORT_SYMBOL(sock_kmalloc);
 EXPORT_SYMBOL(sock_kfree_s);
 EXPORT_SYMBOL(sock_map_fd);
+EXPORT_SYMBOL(sockfd_lookup);
 
 #ifdef CONFIG_FILTER
 EXPORT_SYMBOL(sk_run_filter);
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Wed Oct 16 01:52:02 2002
+++ b/net/socket.c	Wed Oct 16 01:52:02 2002
@@ -447,11 +447,6 @@
 	return sock;
 }
 
-extern __inline__ void sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 /**
  *	sock_alloc	-	allocate a socket
  *	


ChangeSet@1.849, 2002-10-15 19:01:33-07:00, kuznet@mops.inr.ac.ru
  [NET]: Prepare for zerocopy NFS and IPSEC.
  - Import va10-hwchecksum-2.5.36.patch
  - Import va11-udpsendfile-2.5.36.patch
  - Implement new encapsulation friendly ipv4 output path.

diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	Wed Oct 16 01:52:03 2002
+++ b/include/linux/ip.h	Wed Oct 16 01:52:03 2002
@@ -137,7 +137,23 @@
 	int			mc_index;	/* Multicast device index */
 	__u32			mc_addr;
 	struct ip_mc_socklist	*mc_list;	/* Group array */
+	struct page		*sndmsg_page;	/* Cached page for sendmsg */
+	u32			sndmsg_off;	/* Cached offset for sendmsg */
+	/*
+	 * Following members are used to retain the infomation to build
+	 * an ip header on each ip fragmentation while the socket is corked.
+	 */
+	struct {
+		unsigned int		flags;
+		unsigned int		fragsize;
+		struct ip_options	*opt;
+		struct rtable		*rt;
+		int			length; /* Total length of all frames */
+		u32			addr;
+	} cork;
 };
+
+#define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
 
 struct ipv6_pinfo;
 
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	Wed Oct 16 01:52:04 2002
+++ b/include/linux/skbuff.h	Wed Oct 16 01:52:04 2002
@@ -765,6 +765,15 @@
 	return skb->len - skb->data_len;
 }
 
+static inline int skb_pagelen(const struct sk_buff *skb)
+{
+	int i, len = 0;
+
+	for (i = (int)skb_shinfo(skb)->nr_frags - 1; i >= 0; i--)
+		len += skb_shinfo(skb)->frags[i].size;
+	return len + skb_headlen(skb);
+}
+
 #define SKB_PAGE_ASSERT(skb) do { if (skb_shinfo(skb)->nr_frags) \
 					BUG(); } while (0)
 #define SKB_FRAG_ASSERT(skb) do { if (skb_shinfo(skb)->frag_list) \
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	Wed Oct 16 01:52:04 2002
+++ b/include/linux/tcp.h	Wed Oct 16 01:52:04 2002
@@ -285,8 +285,6 @@
 
 	struct tcp_func		*af_specific;	/* Operations which are AF_INET{4,6} specific	*/
 	struct sk_buff		*send_head;	/* Front of stuff to transmit			*/
-	struct page		*sndmsg_page;	/* Cached page for sendmsg			*/
-	u32			sndmsg_off;	/* Cached offset for sendmsg			*/
 
  	__u32	rcv_wnd;	/* Current receiver window		*/
 	__u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
diff -Nru a/include/linux/udp.h b/include/linux/udp.h
--- a/include/linux/udp.h	Wed Oct 16 01:52:03 2002
+++ b/include/linux/udp.h	Wed Oct 16 01:52:03 2002
@@ -17,6 +17,9 @@
 #ifndef _LINUX_UDP_H
 #define _LINUX_UDP_H
 
+#include <asm/byteorder.h>
+#include <net/sock.h>
+#include <linux/ip.h>
 
 struct udphdr {
 	__u16	source;
@@ -25,5 +28,33 @@
 	__u16	check;
 };
 
+/* UDP socket options */
+#define UDP_CORK	1	/* Never send partially complete segments */
+
+struct udp_opt {
+	int		pending;	/* Any pending frames ? */
+	unsigned int	corkflag;	/* Cork is required */
+	/*
+	 * Following members retains the infomation to create a UDP header
+	 * when the socket is uncorked.
+	 */
+	u32		saddr;		/* source address */
+	u32		daddr;		/* destination address */
+	__u16		sport;		/* source port */
+	__u16		dport;		/* destination port */
+	__u16		len;		/* total length of pending frames */
+};
+
+/* WARNING: don't change the layout of the members in udp_sock! */
+struct udp_sock {
+	struct sock	  sk;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct ipv6_pinfo *pinet6;
+#endif
+	struct inet_opt	  inet;
+	struct udp_opt	  udp;
+};
+
+#define udp_sk(__sk) (&((struct udp_sock *)__sk)->udp)
 
 #endif	/* _LINUX_UDP_H */
diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	Wed Oct 16 01:52:04 2002
+++ b/include/net/dst.h	Wed Oct 16 01:52:04 2002
@@ -29,6 +29,7 @@
 	struct dst_entry        *next;
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
+	struct dst_entry	*child;
 	struct net_device       *dev;
 	int			obsolete;
 	int			flags;
@@ -36,6 +37,8 @@
 	unsigned long		lastuse;
 	unsigned long		expires;
 
+	unsigned		header_len;	/* more space at head required */
+
 	unsigned		mxlock;
 	unsigned		pmtu;
 	unsigned		window;
@@ -108,18 +111,30 @@
 		atomic_dec(&dst->__refcnt);
 }
 
+/* Children define the path of the packet through the
+ * Linux networking.  Thus, destinations are stackable.
+ */
+
+static inline struct dst_entry *dst_pop(struct dst_entry *dst)
+{
+	struct dst_entry *child = dst_clone(dst->child);
+
+	dst_release(dst);
+	return child;
+}
+
 extern void * dst_alloc(struct dst_ops * ops);
 extern void __dst_free(struct dst_entry * dst);
-extern void dst_destroy(struct dst_entry * dst);
+extern struct dst_entry *dst_destroy(struct dst_entry * dst);
 
-static inline
-void dst_free(struct dst_entry * dst)
+static inline void dst_free(struct dst_entry * dst)
 {
 	if (dst->obsolete > 1)
 		return;
 	if (!atomic_read(&dst->__refcnt)) {
-		dst_destroy(dst);
-		return;
+		dst = dst_destroy(dst);
+		if (!dst)
+			return;
 	}
 	__dst_free(dst);
 }
@@ -153,6 +168,37 @@
 
 	if (dst->expires == 0 || (long)(dst->expires - expires) > 0)
 		dst->expires = expires;
+}
+
+/* Output packet to network from transport.  */
+static inline int dst_output(struct sk_buff *skb)
+{
+	int err;
+
+	for (;;) {
+		err = skb->dst->output(skb);
+
+		if (likely(err == 0))
+			return err;
+		if (unlikely(err != NET_XMIT_BYPASS))
+			return err;
+	}
+}
+
+/* Input packet from network to transport.  */
+static inline int dst_input(struct sk_buff *skb)
+{
+	int err;
+
+	for (;;) {
+		err = skb->dst->input(skb);
+
+		if (likely(err == 0))
+			return err;
+		/* Oh, Jamal... Seems, I will not forgive you this mess. :-) */
+		if (unlikely(err != NET_XMIT_BYPASS))
+			return err;
+	}
 }
 
 extern void		dst_init(void);
diff -Nru a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h	Wed Oct 16 01:52:04 2002
+++ b/include/net/ip.h	Wed Oct 16 01:52:04 2002
@@ -102,12 +102,26 @@
 				      int getfrag (const void *,
 						   char *,
 						   unsigned int,
-						   unsigned int),
+						   unsigned int,
+						   struct sk_buff *),
 				      const void *frag,
 				      unsigned length,
 				      struct ipcm_cookie *ipc,
 				      struct rtable *rt,
 				      int flags);
+extern int		ip_append_data(struct sock *sk,
+				       int getfrag(void *from, char *to, int offset, int len,
+						   int odd, struct sk_buff *skb),
+				void *from, int len, int protolen,
+				struct ipcm_cookie *ipc,
+				struct rtable *rt,
+				unsigned int flags);
+extern int		generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb);
+extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
+				int offset, size_t size, int flags);
+extern int		ip_push_pending_frames(struct sock *sk);
+extern void		ip_flush_pending_frames(struct sock *sk);
+
 
 /*
  *	Map a multicast IP onto multicast MAC for type Token Ring.
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Wed Oct 16 01:52:04 2002
+++ b/include/net/sock.h	Wed Oct 16 01:52:04 2002
@@ -249,6 +249,8 @@
 					   struct msghdr *msg,
 					int len, int noblock, int flags, 
 					int *addr_len);
+	int			(*sendpage)(struct sock *sk, struct page *page,
+					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk, 
 					struct sockaddr *uaddr, int addr_len);
 
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Wed Oct 16 01:52:03 2002
+++ b/include/net/tcp.h	Wed Oct 16 01:52:03 2002
@@ -1851,7 +1851,7 @@
 {
 	sk->route_caps = dst->dev->features;
 	if (sk->route_caps & NETIF_F_TSO) {
-		if (sk->no_largesend)
+		if (sk->no_largesend || dst->header_len)
 			sk->route_caps &= ~NETIF_F_TSO;
 	}
 }
diff -Nru a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h	Wed Oct 16 01:52:04 2002
+++ b/include/net/udp.h	Wed Oct 16 01:52:04 2002
@@ -76,6 +76,4 @@
 #define UDP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(udp_statistics, field)
 #define UDP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(udp_statistics, field)
 
-#define udp_sock inet_sock
-
 #endif	/* _UDP_H */
diff -Nru a/net/core/dst.c b/net/core/dst.c
--- a/net/core/dst.c	Wed Oct 16 01:52:04 2002
+++ b/net/core/dst.c	Wed Oct 16 01:52:04 2002
@@ -40,7 +40,6 @@
 static struct timer_list dst_gc_timer =
 	{ data: DST_GC_MIN, function: dst_run_gc };
 
-
 static void dst_run_gc(unsigned long dummy)
 {
 	int    delayed = 0;
@@ -60,7 +59,11 @@
 			delayed++;
 			continue;
 		}
-		*dstp = dst->next;
+		if (dst->child) {
+			dst->child->next = dst->next;
+			*dstp = dst->child;
+		} else
+			*dstp = dst->next;
 		dst_destroy(dst);
 	}
 	if (!dst_garbage_list) {
@@ -141,10 +144,16 @@
 	spin_unlock_bh(&dst_lock);
 }
 
-void dst_destroy(struct dst_entry * dst)
+struct dst_entry *dst_destroy(struct dst_entry * dst)
 {
-	struct neighbour *neigh = dst->neighbour;
-	struct hh_cache *hh = dst->hh;
+	struct dst_entry *child;
+	struct neighbour *neigh;
+	struct hh_cache *hh;
+
+again:
+	neigh = dst->neighbour;
+	hh = dst->hh;
+	child = dst->child;
 
 	dst->hh = NULL;
 	if (hh && atomic_dec_and_test(&hh->hh_refcnt))
@@ -165,6 +174,12 @@
 	atomic_dec(&dst_total);
 #endif
 	kmem_cache_free(dst->ops->kmem_cachep, dst);
+
+	dst = child;
+	if (dst && !atomic_read(&dst->__refcnt))
+		goto again;
+
+	return dst;
 }
 
 static int dst_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Wed Oct 16 01:52:03 2002
+++ b/net/ipv4/af_inet.c	Wed Oct 16 01:52:03 2002
@@ -774,6 +774,21 @@
 	return sk->prot->sendmsg(iocb, sk, msg, size);
 }
 
+
+ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+
+	/* We may need to bind the socket. */
+	if (!inet_sk(sk)->num && inet_autobind(sk))
+		return -EAGAIN;
+
+	if (sk->prot->sendpage)
+		return sk->prot->sendpage(sk, page, offset, size, flags);
+	return sock_no_sendpage(sock, page, offset, size, flags);
+}
+
+
 int inet_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
@@ -977,7 +992,7 @@
 	.sendmsg =	inet_sendmsg,
 	.recvmsg =	inet_recvmsg,
 	.mmap =		sock_no_mmap,
-	.sendpage =	sock_no_sendpage,
+	.sendpage =	inet_sendpage,
 };
 
 struct net_proto_family inet_family_ops = {
diff -Nru a/net/ipv4/icmp.c b/net/ipv4/icmp.c
--- a/net/ipv4/icmp.c	Wed Oct 16 01:52:04 2002
+++ b/net/ipv4/icmp.c	Wed Oct 16 01:52:04 2002
@@ -357,11 +357,13 @@
  *	checksum.
  */
 static int icmp_glue_bits(const void *p, char *to, unsigned int offset,
-			  unsigned int fraglen)
+			  unsigned int fraglen, struct sk_buff *skb)
 {
 	struct icmp_bxm *icmp_param = (struct icmp_bxm *)p;
 	struct icmphdr *icmph;
 	unsigned int csum;
+
+	skb->ip_summed = CHECKSUM_NONE;
 
 	if (offset) {
 		icmp_param->csum =
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Wed Oct 16 01:52:04 2002
+++ b/net/ipv4/ip_output.c	Wed Oct 16 01:52:04 2002
@@ -15,6 +15,7 @@
  *		Stefan Becker, <stefanb@yello.ping.de>
  *		Jorge Cwik, <jorge@laser.satlink.net>
  *		Arnt Gulbrandsen, <agulbra@nvg.unit.no>
+ *		Hirokazu Takahashi, <taka@valinux.co.jp>
  *
  *	See ip_input.c for original log
  *
@@ -38,6 +39,9 @@
  *		Marc Boucher	:	When call_out_firewall returns FW_QUEUE,
  *					silently drop skb instead of failing with -EPERM.
  *		Detlev Wengorz	:	Copy protocol for fragments.
+ *		Hirokazu Takahashi:	HW checksumming for outgoing UDP
+ *					datagrams.
+ *		Hirokazu Takahashi:	sendfile() on UDP works now.
  */
 
 #include <asm/uaccess.h>
@@ -108,16 +112,9 @@
 	return 0;
 }
 
-/* Don't just hand NF_HOOK skb->dst->output, in case netfilter hook
-   changes route */
-static inline int
-output_maybe_reroute(struct sk_buff *skb)
-{
-	return skb->dst->output(skb);
-}
-
 /* 
  *		Add an ip header to a skbuff and send it out.
+ *
  */
 int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 			  u32 saddr, u32 daddr, struct ip_options *opt)
@@ -153,15 +150,34 @@
 	}
 	ip_send_check(iph);
 
+	skb->priority = sk->priority;
+
 	/* Send it out. */
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       output_maybe_reroute);
+		       dst_output);
 }
 
 static inline int ip_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct hh_cache *hh = dst->hh;
+	struct net_device *dev = dst->dev;
+
+	/* Be paranoid, rather than too clever. */
+	if (unlikely(skb_headroom(skb) < dev->hard_header_len
+		     && dev->hard_header)) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_realloc_headroom(skb, (dev->hard_header_len&~15) + 16);
+		if (skb2 == NULL) {
+			kfree_skb(skb);
+			return -ENOMEM;
+		}
+		if (skb->sk)
+			skb_set_owner_w(skb2, skb->sk);
+		kfree_skb(skb);
+		skb = skb2;
+	}
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	nf_debug_ip_finish_output2(skb);
@@ -203,10 +219,6 @@
 	 *	If the indicated interface is up and running, send the packet.
 	 */
 	IP_INC_STATS(IpOutRequests);
-#ifdef CONFIG_IP_ROUTE_NAT
-	if (rt->rt_flags & RTCF_NAT)
-		ip_do_nat(skb);
-#endif
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -251,100 +263,21 @@
 				newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	return ip_finish_output(skb);
+	if (skb->len > dev->mtu || skb_shinfo(skb)->frag_list)
+		return ip_fragment(skb, ip_finish_output);
+	else
+		return ip_finish_output(skb);
 }
 
 int ip_output(struct sk_buff *skb)
 {
-#ifdef CONFIG_IP_ROUTE_NAT
-	struct rtable *rt = (struct rtable*)skb->dst;
-#endif
-
 	IP_INC_STATS(IpOutRequests);
 
-#ifdef CONFIG_IP_ROUTE_NAT
-	if (rt->rt_flags&RTCF_NAT)
-		ip_do_nat(skb);
-#endif
-
-	return ip_finish_output(skb);
-}
-
-/* Queues a packet to be sent, and starts the transmitter if necessary.  
- * This routine also needs to put in the total length and compute the 
- * checksum.  We use to do this in two stages, ip_build_header() then
- * this, but that scheme created a mess when routes disappeared etc.
- * So we do it all here, and the TCP send engine has been changed to
- * match. (No more unroutable FIN disasters, etc. wheee...)  This will
- * most likely make other reliable transport layers above IP easier
- * to implement under Linux.
- */
-static inline int ip_queue_xmit2(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-	struct rtable *rt = (struct rtable *)skb->dst;
-	struct net_device *dev;
-	struct iphdr *iph = skb->nh.iph;
-
-	dev = rt->u.dst.dev;
-
-	/* This can happen when the transport layer has segments queued
-	 * with a cached route, and by the time we get here things are
-	 * re-routed to a device with a different MTU than the original
-	 * device.  Sick, but we must cover it.
-	 */
-	if (skb_headroom(skb) < dev->hard_header_len && dev->hard_header) {
-		struct sk_buff *skb2;
-
-		skb2 = skb_realloc_headroom(skb, (dev->hard_header_len + 15) & ~15);
-		kfree_skb(skb);
-		if (skb2 == NULL)
-			return -ENOMEM;
-		if (sk)
-			skb_set_owner_w(skb2, sk);
-		skb = skb2;
-		iph = skb->nh.iph;
-	}
-
-	if (skb->len > rt->u.dst.pmtu) {
-		unsigned int hlen;
-		if (!(sk->route_caps&NETIF_F_TSO))
-			goto fragment;
-
-		/* Hack zone: all this must be done by TCP. */
-		hlen = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
-		skb_shinfo(skb)->tso_size = rt->u.dst.pmtu - hlen;
-		skb_shinfo(skb)->tso_segs =
-			(skb->len - hlen + skb_shinfo(skb)->tso_size - 1)/
-				skb_shinfo(skb)->tso_size - 1;
-	}
-
-	ip_select_ident_more(iph, &rt->u.dst, sk, skb_shinfo(skb)->tso_segs);
-
-	/* Add an IP checksum. */
-	ip_send_check(iph);
-
-	skb->priority = sk->priority;
-	return skb->dst->output(skb);
-
-fragment:
-	if (ip_dont_fragment(sk, &rt->u.dst)) {
-		/* Reject packet ONLY if TCP might fragment
-		 * it itself, if were careful enough.
-		 */
-		NETDEBUG(printk(KERN_DEBUG "sending pkt_too_big (len[%u] pmtu[%u]) to self\n",
-				skb->len, rt->u.dst.pmtu));
-
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(rt->u.dst.pmtu));
-		kfree_skb(skb);
-		return -EMSGSIZE;
-	}
-	ip_select_ident(iph, &rt->u.dst, sk);
-	if (skb->ip_summed == CHECKSUM_HW &&
-	    (skb = skb_checksum_help(skb)) == NULL)
-		return -ENOMEM;
-	return ip_fragment(skb, skb->dst->output);
+	if ((skb->len > skb->dst->dev->mtu || skb_shinfo(skb)->frag_list) &&
+	    !skb_shinfo(skb)->tso_size)
+		return ip_fragment(skb, ip_finish_output);
+	else
+		return ip_finish_output(skb);
 }
 
 int ip_queue_xmit(struct sk_buff *skb)
@@ -415,8 +348,26 @@
 		ip_options_build(skb, opt, inet->daddr, rt, 0);
 	}
 
+	if (skb->len > rt->u.dst.pmtu && (sk->route_caps&NETIF_F_TSO)) {
+		unsigned int hlen;
+
+		/* Hack zone: all this must be done by TCP. */
+		hlen = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
+		skb_shinfo(skb)->tso_size = rt->u.dst.pmtu - hlen;
+		skb_shinfo(skb)->tso_segs =
+			(skb->len - hlen + skb_shinfo(skb)->tso_size - 1)/
+				skb_shinfo(skb)->tso_size - 1;
+	}
+
+	ip_select_ident_more(iph, &rt->u.dst, sk, skb_shinfo(skb)->tso_segs);
+
+	/* Add an IP checksum. */
+	ip_send_check(iph);
+
+	skb->priority = sk->priority;
+
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       ip_queue_xmit2);
+		       dst_output);
 
 no_route:
 	IP_INC_STATS(IpOutNoRoutes);
@@ -424,7 +375,8 @@
 	return -EHOSTUNREACH;
 }
 
-/*
+/* _Dead beaf_
+ *
  *	Build and send a packet, with as little as one copy
  *
  *	Doesn't care much about ip options... option length can be
@@ -448,7 +400,8 @@
 		  int getfrag (const void *,
 			       char *,
 			       unsigned int,	
-			       unsigned int),
+			       unsigned int,
+			       struct sk_buff *),
 		  const void *frag,
 		  unsigned length,
 		  struct ipcm_cookie *ipc,
@@ -462,10 +415,11 @@
 	int mtu;
 	u16 id;
 
-	int hh_len = (rt->u.dst.dev->hard_header_len + 15)&~15;
+	int hh_len = (rt->u.dst.dev->hard_header_len&~15) + 16;
 	int nfrags=0;
 	struct ip_options *opt = ipc->opt;
 	int df = 0;
+	int csumselect = CHECKSUM_NONE;
 
 	mtu = rt->u.dst.pmtu;
 	if (ip_dont_fragment(sk, &rt->u.dst))
@@ -527,6 +481,13 @@
 		goto out;
 
 	/*
+	 *	Give the upper layer a chance to decide whether to use HW
+	 *	checksumming or not.
+	 */
+	if (offset == 0 && rt->u.dst.dev->features & (NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM))
+		csumselect = CHECKSUM_HW;
+
+	/*
 	 *	Begin outputting the bytes.
 	 */
 
@@ -560,6 +521,7 @@
 
 		skb->priority = sk->priority;
 		skb->dst = dst_clone(&rt->u.dst);
+		skb->ip_summed = csumselect;
 		skb_reserve(skb, hh_len);
 
 		/*
@@ -607,18 +569,18 @@
 			else
 				iph->ttl = inet->ttl;
 			iph->protocol = sk->protocol;
-			iph->check = 0;
 			iph->saddr = rt->rt_src;
 			iph->daddr = rt->rt_dst;
-			iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+			ip_send_check(iph);
 			data += iph->ihl*4;
+			skb->h.raw = data;
 		}
 
 		/*
 		 *	User data callback
 		 */
 
-		if (getfrag(frag, data, offset, fraglen-fragheaderlen)) {
+		if (getfrag(frag, data, offset, fraglen-fragheaderlen, skb)) {
 			err = -EFAULT;
 			kfree_skb(skb);
 			goto error;
@@ -630,7 +592,7 @@
 		nfrags++;
 
 		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
-			      skb->dst->dev, output_maybe_reroute);
+			      skb->dst->dev, dst_output);
 		if (err) {
 			if (err > 0)
 				err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -658,7 +620,8 @@
 		  int getfrag (const void *,
 			       char *,
 			       unsigned int,	
-			       unsigned int),
+			       unsigned int,
+			       struct sk_buff *),
 		  const void *frag,
 		  unsigned length,
 		  struct ipcm_cookie *ipc,
@@ -705,7 +668,7 @@
 	 *	Fast path for unfragmented frames without options. 
 	 */ 
 	{
-	int hh_len = (rt->u.dst.dev->hard_header_len + 15)&~15;
+	int hh_len = (rt->u.dst.dev->hard_header_len&~15) + 16;
 
 	skb = sock_alloc_send_skb(sk, length+hh_len+15,
 				  flags&MSG_DONTWAIT, &err);
@@ -719,6 +682,13 @@
 
 	skb->nh.iph = iph = (struct iphdr *)skb_put(skb, length);
 
+	/*
+	 *	Give the upper layer a chance to decide whether to use HW
+	 *	checksumming or not.
+	 */
+	if (rt->u.dst.dev->features & (NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM))
+		skb->ip_summed = CHECKSUM_HW;
+
 	if (!inet->hdrincl) {
 		iph->version=4;
 		iph->ihl=5;
@@ -732,18 +702,20 @@
 		iph->protocol=sk->protocol;
 		iph->saddr=rt->rt_src;
 		iph->daddr=rt->rt_dst;
-		iph->check=0;
-		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-		err = getfrag(frag, ((char *)iph)+iph->ihl*4,0, length-iph->ihl*4);
+		ip_send_check(iph);
+		skb->h.raw = skb->nh.raw + iph->ihl*4;
+		err = getfrag(frag, ((char *)iph)+iph->ihl*4,0, length-iph->ihl*4, skb);
+	}
+	else {
+		skb->h.raw = skb->nh.raw;
+		err = getfrag(frag, (void *)iph, 0, length, skb);
 	}
-	else
-		err = getfrag(frag, (void *)iph, 0, length);
 
 	if (err)
 		goto error_fault;
 
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      output_maybe_reroute);
+		      dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
 	if (err)
@@ -759,13 +731,37 @@
 	return err; 
 }
 
+static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
+{
+	to->pkt_type = from->pkt_type;
+	to->priority = from->priority;
+	to->protocol = from->protocol;
+	to->security = from->security;
+	to->dst = dst_clone(from->dst);
+	to->dev = from->dev;
+
+	/* Copy the flags to each fragment. */
+	IPCB(to)->flags = IPCB(from)->flags;
+
+#ifdef CONFIG_NET_SCHED
+	to->tc_index = from->tc_index;
+#endif
+#ifdef CONFIG_NETFILTER
+	to->nfmark = from->nfmark;
+	/* Connection association is same as pre-frag packet */
+	to->nfct = from->nfct;
+	nf_conntrack_get(to->nfct);
+#ifdef CONFIG_NETFILTER_DEBUG
+	to->nf_debug = from->nf_debug;
+#endif
+#endif
+}
+
 /*
  *	This IP datagram is too large to be sent in one piece.  Break it up into
  *	smaller pieces (each of size equal to IP header plus
  *	a block of the data of the original IP data part) that will yet fit in a
  *	single device frame, and queue such a frame for sending.
- *
- *	Yes this is inefficient, feel free to submit a quicker one.
  */
 
 int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
@@ -789,13 +785,111 @@
 
 	iph = skb->nh.iph;
 
+	if (unlikely(iph->frag_off & htons(IP_DF))) {
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+			  htonl(rt->u.dst.pmtu));
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+
 	/*
 	 *	Setup starting values.
 	 */
 
 	hlen = iph->ihl * 4;
-	left = skb->len - hlen;		/* Space per frame */
 	mtu = rt->u.dst.pmtu - hlen;	/* Size of data space */
+
+	/* When frag_list is given, use it. First, check its validity:
+	 * some transformers could create wrong frag_list or break existing
+	 * one, it is not prohibited. In this case fall back to copying.
+	 *
+	 * LATER: this step can be merged to real generation of fragments,
+	 * we can switch to copy when see the first bad fragment.
+	 */
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *frag;
+		int first_len = skb_pagelen(skb);
+
+		if (first_len - hlen > mtu ||
+		    ((first_len - hlen) & 7) ||
+		    (iph->frag_off & htons(IP_MF|IP_OFFSET)) ||
+		    skb_cloned(skb))
+			goto slow_path;
+
+		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+			/* Correct geometry. */
+			if (frag->len > mtu ||
+			    ((frag->len & 7) && frag->next) ||
+			    skb_headroom(frag) < hlen)
+			    goto slow_path;
+
+			/* Correct socket ownership. */
+			if (frag->sk == NULL)
+				goto slow_path;
+
+			/* Partially cloned skb? */
+			if (skb_shared(frag))
+				goto slow_path;
+		}
+
+		/* Everything is OK. Generate! */
+
+		err = 0;
+		offset = 0;
+		frag = skb_shinfo(skb)->frag_list;
+		skb_shinfo(skb)->frag_list = 0;
+		skb->data_len = first_len - skb_headlen(skb);
+		skb->len = first_len;
+		iph->tot_len = htons(first_len);
+		iph->frag_off |= htons(IP_MF);
+		ip_send_check(iph);
+
+		for (;;) {
+			/* Prepare header of the next frame,
+			 * before previous one went down. */
+			if (frag) {
+				frag->h.raw = frag->data;
+				frag->nh.raw = __skb_push(frag, hlen);
+				memcpy(frag->nh.raw, iph, hlen);
+				iph = frag->nh.iph;
+				iph->tot_len = htons(frag->len);
+				ip_copy_metadata(frag, skb);
+				if (offset == 0)
+					ip_options_fragment(frag);
+				offset += skb->len - hlen;
+				iph->frag_off = htons(offset>>3);
+				if (frag->next != NULL)
+					iph->frag_off |= htons(IP_MF);
+				/* Ready, complete checksum */
+				ip_send_check(iph);
+			}
+
+			err = output(skb);
+
+			if (err || !frag)
+				break;
+
+			skb = frag;
+			frag = skb->next;
+			skb->next = NULL;
+		}
+
+		if (err == 0) {
+			IP_INC_STATS(IpFragOKs);
+			return 0;
+		}
+
+		while (frag) {
+			skb = frag->next;
+			kfree_skb(frag);
+			frag = skb;
+		}
+		IP_INC_STATS(IpFragFails);
+		return err;
+	}
+
+slow_path:
+	left = skb->len - hlen;		/* Space per frame */
 	ptr = raw + hlen;		/* Where to start from */
 
 	/*
@@ -823,7 +917,7 @@
 		 *	Allocate buffer.
 		 */
 
-		if ((skb2 = alloc_skb(len+hlen+dev->hard_header_len+15,GFP_ATOMIC)) == NULL) {
+		if ((skb2 = alloc_skb(len+hlen+rt->u.dst.dev->hard_header_len+16,GFP_ATOMIC)) == NULL) {
 			NETDEBUG(printk(KERN_INFO "IP: frag: no memory for new fragment!\n"));
 			err = -ENOMEM;
 			goto fail;
@@ -833,14 +927,11 @@
 		 *	Set up data on packet
 		 */
 
-		skb2->pkt_type = skb->pkt_type;
-		skb2->priority = skb->priority;
-		skb_reserve(skb2, (dev->hard_header_len+15)&~15);
+		ip_copy_metadata(skb2, skb);
+		skb_reserve(skb2, (rt->u.dst.dev->hard_header_len&~15)+16);
 		skb_put(skb2, len + hlen);
 		skb2->nh.raw = skb2->data;
 		skb2->h.raw = skb2->data + hlen;
-		skb2->protocol = skb->protocol;
-		skb2->security = skb->security;
 
 		/*
 		 *	Charge the memory for the fragment to any owner
@@ -849,8 +940,6 @@
 
 		if (skb->sk)
 			skb_set_owner_w(skb2, skb->sk);
-		skb2->dst = dst_clone(skb->dst);
-		skb2->dev = skb->dev;
 
 		/*
 		 *	Copy the packet header into the new buffer.
@@ -880,9 +969,6 @@
 		if (offset == 0)
 			ip_options_fragment(skb);
 
-		/* Copy the flags to each fragment. */
-		IPCB(skb2)->flags = IPCB(skb)->flags;
-
 		/*
 		 *	Added AC : If we are fragmenting a fragment that's not the
 		 *		   last fragment then keep MF on each bit
@@ -892,19 +978,6 @@
 		ptr += len;
 		offset += len;
 
-#ifdef CONFIG_NET_SCHED
-		skb2->tc_index = skb->tc_index;
-#endif
-#ifdef CONFIG_NETFILTER
-		skb2->nfmark = skb->nfmark;
-		/* Connection association is same as pre-frag packet */
-		skb2->nfct = skb->nfct;
-		nf_conntrack_get(skb2->nfct);
-#ifdef CONFIG_NETFILTER_DEBUG
-		skb2->nf_debug = skb->nf_debug;
-#endif
-#endif
-
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
@@ -929,11 +1002,524 @@
 	return err;
 }
 
+int
+generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
+{
+	struct iovec *iov = from;
+
+	if (skb->ip_summed == CHECKSUM_HW) {
+		if (memcpy_fromiovecend(to, iov, offset, len) < 0)
+			return -EFAULT;
+	} else {
+		unsigned int csum = 0;
+		if (csum_partial_copy_fromiovecend(to, iov, offset, len, &csum) < 0)
+			return -EFAULT;
+		skb->csum = csum_block_add(skb->csum, csum, odd);
+	}
+	return 0;
+}
+
+static inline int
+skb_can_coalesce(struct sk_buff *skb, int i, struct page *page, int off)
+{
+	if (i) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
+		return page == frag->page &&
+			off == frag->page_offset+frag->size;
+	}
+	return 0;
+}
+
+static inline void
+skb_fill_page_desc(struct sk_buff *skb, int i, struct page *page, int off, int size)
+{
+	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+	frag->page = page;
+	frag->page_offset = off;
+	frag->size = size;
+	skb_shinfo(skb)->nr_frags = i+1;
+}
+
+static inline unsigned int
+csum_page(struct page *page, int offset, int copy)
+{
+	char *kaddr;
+	unsigned int csum;
+	kaddr = kmap(page);
+	csum = csum_partial(kaddr + offset, copy, 0);
+	kunmap(page);
+	return csum;
+}
+
+/*
+ *	ip_append_data() and ip_append_page() can make one large IP datagram
+ *	from many pieces of data. Each pieces will be holded on the socket
+ *	until ip_push_pending_frames() is called. Eache pieces can be a page
+ *	or non-page data.
+ *	
+ *	Not only UDP, other transport protocols - e.g. raw sockets - can use
+ *	this interface potentially.
+ *
+ *	LATER: length must be adjusted by pad at tail, when it is required.
+ */
+int ip_append_data(struct sock *sk,
+		   int getfrag(void *from, char *to, int offset, int len,
+			       int odd, struct sk_buff *skb),
+		   void *from, int length, int transhdrlen,
+		   struct ipcm_cookie *ipc, struct rtable *rt,
+		   unsigned int flags)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	struct sk_buff *skb;
+
+	struct ip_options *opt = NULL;
+	int hh_len;
+	int exthdrlen;
+	int mtu;
+	int copy;
+	int err;
+	int offset = 0;
+	unsigned int maxfraglen, fragheaderlen;
+	int csummode = CHECKSUM_NONE;
+
+	if (inet->hdrincl)
+		return -EPERM;
+
+	if (flags&MSG_PROBE)
+		return 0;
+
+	if (skb_queue_empty(&sk->write_queue)) {
+		/*
+		 * setup for corking.
+		 */
+		opt = ipc->opt;
+		if (opt) {
+			if (inet->cork.opt == NULL)
+				inet->cork.opt = kmalloc(sizeof(struct ip_options)+40, GFP_KERNEL);
+			memcpy(inet->cork.opt, opt, sizeof(struct ip_options)+opt->optlen);
+			inet->cork.flags |= IPCORK_OPT;
+			inet->cork.addr = ipc->addr;
+		}
+		dst_hold(&rt->u.dst);
+		inet->cork.fragsize = mtu = rt->u.dst.pmtu;
+		inet->cork.rt = rt;
+		inet->cork.length = 0;
+		inet->sndmsg_page = NULL;
+		inet->sndmsg_off = 0;
+		if ((exthdrlen = rt->u.dst.header_len) != 0) {
+			length += exthdrlen;
+			transhdrlen += exthdrlen;
+		}
+	} else {
+		rt = inet->cork.rt;
+		if (inet->cork.flags & IPCORK_OPT)
+			opt = inet->cork.opt;
+
+		transhdrlen = 0;
+		exthdrlen = 0;
+		mtu = inet->cork.fragsize;
+	}
+	hh_len = (rt->u.dst.dev->hard_header_len&~15) + 16;
+
+	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+	maxfraglen = ((mtu-fragheaderlen) & ~7) + fragheaderlen;
+
+	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
+		return -EMSGSIZE;
+	}
+
+#if 0 /* Not now */
+	/*
+	 * transhdrlen > 0 means that this is the first fragment and we wish
+	 * it won't be fragmented in the future.
+	 */
+	if (transhdrlen &&
+	    length + fragheaderlen <= maxfraglen &&
+	    rt->u.dst.dev->features&(NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM) &&
+	    !exthdrlen)
+		csummode = CHECKSUM_HW;
+#endif
+
+	inet->cork.length += length;
+
+	if ((skb = skb_peek_tail(&sk->write_queue)) == NULL)
+		goto alloc_new_skb;
+
+	while (length > 0) {
+		if ((copy = maxfraglen - skb->len) <= 0) {
+			char *data;
+			unsigned int datalen;
+			unsigned int fraglen;
+			BUG_TRAP(copy == 0);
+
+alloc_new_skb:
+			datalen = maxfraglen - fragheaderlen;
+			if (datalen > length)
+				datalen = length;
+
+			fraglen = datalen + fragheaderlen;
+			if (!(flags & MSG_DONTWAIT) || transhdrlen) {
+				skb = sock_alloc_send_skb(sk, fraglen + hh_len + 15,
+							  (flags & MSG_DONTWAIT), &err);
+			} else {
+				skb = sock_wmalloc(sk, fraglen + hh_len + 15, 1,
+						   sk->allocation);
+				if (unlikely(skb == NULL))
+					err = -ENOBUFS;
+			}
+			if (skb == NULL)
+				goto error;
+
+			/*
+			 *	Fill in the control structures
+			 */
+			skb->ip_summed = csummode;
+			skb->csum = 0;
+			skb_reserve(skb, hh_len);
+
+			/*
+			 *	Find where to start putting bytes.
+			 */
+			data = skb_put(skb, fraglen);
+			skb->nh.raw = __skb_pull(skb, exthdrlen);
+			data += fragheaderlen;
+			skb->h.raw = data + exthdrlen;
+
+			copy = datalen - transhdrlen;
+			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, 0, skb) < 0) {
+				err = -EFAULT;
+				kfree_skb(skb);
+				goto error;
+			}
+
+			offset += copy;
+			length -= datalen;
+			transhdrlen = 0;
+			exthdrlen = 0;
+			csummode = CHECKSUM_NONE;
+
+			/*
+			 * Put the packet on the pending queue.
+			 */
+			__skb_queue_tail(&sk->write_queue, skb);
+			continue;
+		}
+
+		if (!(rt->u.dst.dev->features&NETIF_F_SG)) {
+			int off;
+			if (!((skb->len - fragheaderlen) & 7))
+				goto alloc_new_skb;
+
+			/* 
+			 * Align the start address of the next IP fragment
+			 * on 8 byte boundary.
+			 */
+			copy = 8 - ((skb->len - fragheaderlen) & 7);
+			off = skb->len;
+			if (copy > length)
+				copy = length;
+			if (getfrag(from, skb_put(skb, copy), offset, copy, off, skb) < 0) {
+				__skb_trim(skb, off);
+				err = -EFAULT;
+				goto error;
+			}
+		} else {
+			int i = skb_shinfo(skb)->nr_frags;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
+			struct page *page = inet->sndmsg_page;
+			int off = inet->sndmsg_off;
+			unsigned int left;
+
+			if (copy > length)
+				copy = length;
+
+			if (page && (left = PAGE_SIZE - off) > 0) {
+				if (copy >= left)
+					copy = left;
+				if (page != frag->page) {
+					if (i == MAX_SKB_FRAGS) {
+						err = -EMSGSIZE;
+						goto error;
+					}
+					get_page(page);
+	 				skb_fill_page_desc(skb, i, page, inet->sndmsg_off, 0);
+					frag = &skb_shinfo(skb)->frags[i];
+				}
+			} else if (i < MAX_SKB_FRAGS) {
+				if (copy > PAGE_SIZE)
+					copy = PAGE_SIZE;
+				page = alloc_pages(sk->allocation, 0);
+				if (page == NULL)  {
+					err = -ENOMEM;
+					goto error;
+				}
+				inet->sndmsg_page = page;
+				inet->sndmsg_off = 0;
+
+				skb_fill_page_desc(skb, i, page, 0, 0);
+				frag = &skb_shinfo(skb)->frags[i];
+				skb->truesize += PAGE_SIZE;
+				atomic_add(PAGE_SIZE, &sk->wmem_alloc);
+			} else {
+				err = -EMSGSIZE;
+				goto error;
+			}
+			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+				err = -EFAULT;
+				goto error;
+			}
+			inet->sndmsg_off += copy;
+			frag->size += copy;
+			skb->len += copy;
+			skb->data_len += copy;
+		}
+		offset += copy;
+		length -= copy;
+	}
+
+	return 0;
+
+error:
+	inet->cork.length -= length;
+	IP_INC_STATS(IpOutDiscards);
+	return err; 
+}
+
+ssize_t	ip_append_page(struct sock *sk, struct page *page,
+		       int offset, size_t size, int flags)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	struct sk_buff *skb;
+	struct rtable *rt;
+	struct ip_options *opt = NULL;
+	int hh_len;
+	int mtu;
+	int len;
+	int err;
+	unsigned int maxfraglen, fragheaderlen;
+
+	if (inet->hdrincl)
+		return -EPERM;
+
+	if (flags&MSG_PROBE)
+		return 0;
+
+	if (skb_queue_empty(&sk->write_queue))
+		return -EINVAL;
+
+	rt = inet->cork.rt;
+	if (inet->cork.flags & IPCORK_OPT)
+		opt = inet->cork.opt;
+
+	if (!(rt->u.dst.dev->features&NETIF_F_SG))
+		return -EOPNOTSUPP;
+
+	hh_len = (rt->u.dst.dev->hard_header_len&~15)+16;
+	mtu = inet->cork.fragsize;
+
+	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+	maxfraglen = ((mtu-fragheaderlen) & ~7) + fragheaderlen;
+
+	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
+		return -EMSGSIZE;
+	}
+
+	if ((skb = skb_peek_tail(&sk->write_queue)) == NULL)
+		return -EINVAL;
+
+	inet->cork.length += size;
+
+	while (size > 0) {
+		int i;
+		if ((len = maxfraglen - skb->len) <= 0) {
+			char *data;
+			struct iphdr *iph;
+			BUG_TRAP(len == 0);
+
+			skb = sock_wmalloc(sk, fragheaderlen + hh_len + 15, 1,
+					   sk->allocation);
+			if (unlikely(!skb)) {
+				err = -ENOBUFS;
+				goto error;
+			}
+
+			/*
+			 *	Fill in the control structures
+			 */
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->csum = 0;
+			skb_reserve(skb, hh_len);
+
+			/*
+			 *	Find where to start putting bytes.
+			 */
+			data = skb_put(skb, fragheaderlen);
+			skb->nh.iph = iph = (struct iphdr *)data;
+			data += fragheaderlen;
+			skb->h.raw = data;
+
+			/*
+			 * Put the packet on the pending queue.
+			 */
+			__skb_queue_tail(&sk->write_queue, skb);
+			continue;
+		}
+
+		i = skb_shinfo(skb)->nr_frags;
+		if (len > size)
+			len = size;
+		if (skb_can_coalesce(skb, i, page, offset)) {
+			skb_shinfo(skb)->frags[i-1].size += len;
+		} else if (i < MAX_SKB_FRAGS) {
+			get_page(page);
+			skb_fill_page_desc(skb, i, page, offset, len);
+		} else {
+			err = -EMSGSIZE;
+			goto error;
+		}
+
+		if (skb->ip_summed == CHECKSUM_NONE) {
+			unsigned int csum;
+			csum = csum_page(page, offset, len);
+			skb->csum = csum_block_add(skb->csum, csum, skb->len);
+		}
+
+		skb->len += len;
+		skb->data_len += len;
+		offset += len;
+		size -= len;
+	}
+	return 0;
+
+error:
+	inet->cork.length -= size;
+	IP_INC_STATS(IpOutDiscards);
+	return err;
+}
+
+/*
+ *	Combined all pending IP fragments on the socket as one IP datagram
+ *	and push them out.
+ */
+int ip_push_pending_frames(struct sock *sk)
+{
+	struct sk_buff *skb, *tmp_skb;
+	struct sk_buff **tail_skb;
+	struct inet_opt *inet = inet_sk(sk);
+	struct ip_options *opt = NULL;
+	struct rtable *rt = inet->cork.rt;
+	struct iphdr *iph;
+	int df = 0;
+	__u8 ttl;
+	int err = 0;
+
+	if ((skb = __skb_dequeue(&sk->write_queue)) == NULL)
+		goto out;
+	tail_skb = &(skb_shinfo(skb)->frag_list);
+
+	while ((tmp_skb = __skb_dequeue(&sk->write_queue)) != NULL) {
+		__skb_pull(tmp_skb, skb->h.raw - skb->nh.raw);
+		*tail_skb = tmp_skb;
+		tail_skb = &(tmp_skb->next);
+		skb->len += tmp_skb->len;
+		skb->data_len += tmp_skb->len;
+#if 0 /* Logically correct, but useless work, ip_fragment() will have to undo */
+		skb->truesize += tmp_skb->truesize;
+		__sock_put(tmp_skb->sk);
+		tmp_skb->destructor = NULL;
+		tmp_skb->sk = NULL;
+#endif
+	}
+
+	if (inet->pmtudisc == IP_PMTUDISC_DO ||
+	    (!skb_shinfo(skb)->frag_list && ip_dont_fragment(sk, &rt->u.dst)))
+		df = htons(IP_DF);
+
+	if (inet->cork.flags & IPCORK_OPT)
+		opt = inet->cork.opt;
+
+	if (rt->rt_type == RTN_MULTICAST)
+		ttl = inet->mc_ttl;
+	else
+		ttl = inet->ttl;
+
+	iph = (struct iphdr *)skb->data;
+	iph->version = 4;
+	iph->ihl = 5;
+	if (opt) {
+		iph->ihl += opt->optlen>>2;
+		ip_options_build(skb, opt, inet->cork.addr, rt, 0);
+	}
+	iph->tos = inet->tos;
+	iph->tot_len = htons(skb->len);
+	iph->frag_off = df;
+	if (!df) {
+		__ip_select_ident(iph, &rt->u.dst, 0);
+	} else {
+		iph->id = htons(inet->id++);
+	}
+	iph->ttl = ttl;
+	iph->protocol = sk->protocol;
+	iph->saddr = rt->rt_src;
+	iph->daddr = rt->rt_dst;
+	ip_send_check(iph);
+
+	skb->priority = sk->priority;
+	skb->dst = dst_clone(&rt->u.dst);
+
+	/* Netfilter gets whole the not fragmented skb. */
+	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
+		      skb->dst->dev, dst_output);
+	if (err) {
+		if (err > 0)
+			err = inet->recverr ? net_xmit_errno(err) : 0;
+		if (err)
+			goto error;
+	}
+
+out:
+	inet->cork.flags &= ~IPCORK_OPT;
+	if (inet->cork.rt) {
+		ip_rt_put(inet->cork.rt);
+		inet->cork.rt = NULL;
+	}
+	return err;
+
+error:
+	IP_INC_STATS(IpOutDiscards);
+	goto out;
+}
+
+/*
+ *	Throw away all pending data on the socket.
+ */
+void ip_flush_pending_frames(struct sock *sk)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue_tail(&sk->write_queue)) != NULL)
+		kfree_skb(skb);
+
+	inet->cork.flags &= ~IPCORK_OPT;
+	if (inet->cork.opt) {
+		kfree(inet->cork.opt);
+		inet->cork.opt = NULL;
+	}
+	if (inet->cork.rt) {
+		ip_rt_put(inet->cork.rt);
+		inet->cork.rt = NULL;
+	}
+}
+
+
 /*
  *	Fetch data from kernel space and fill in checksum if needed.
  */
 static int ip_reply_glue_bits(const void *dptr, char *to, unsigned int offset, 
-			      unsigned int fraglen)
+			      unsigned int fraglen, struct sk_buff *skb)
 {
         struct ip_reply_arg *dp = (struct ip_reply_arg*)dptr;
 	u16 *pktp = (u16 *)to;
@@ -962,6 +1548,8 @@
 
 	if (hdrflag && dp->csumoffset)
 		*(pktp + dp->csumoffset) = csum_fold(dp->csum); /* fill in checksum */
+	skb->ip_summed = CHECKSUM_NONE;
+
 	return 0;	       
 }
 
@@ -971,6 +1559,8 @@
  *
  *	Should run single threaded per socket because it uses the sock 
  *     	structure to pass arguments.
+ *
+ *	LATER: switch from ip_build_xmit to ip_append_*
  */
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
 		   unsigned int len)
diff -Nru a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
--- a/net/ipv4/ip_sockglue.c	Wed Oct 16 01:52:03 2002
+++ b/net/ipv4/ip_sockglue.c	Wed Oct 16 01:52:04 2002
@@ -437,8 +437,10 @@
 				    (!((1<<sk->state)&(TCPF_LISTEN|TCPF_CLOSE))
 				     && inet->daddr != LOOPBACK4_IPV6)) {
 #endif
+					if (inet->opt)
+						tp->ext_header_len -= inet->opt->optlen;
 					if (opt)
-						tp->ext_header_len = opt->optlen;
+						tp->ext_header_len += opt->optlen;
 					tcp_sync_mss(sk, tp->pmtu_cookie);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 				}
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	Wed Oct 16 01:52:03 2002
+++ b/net/ipv4/raw.c	Wed Oct 16 01:52:03 2002
@@ -259,9 +259,10 @@
  */
   
 static int raw_getfrag(const void *p, char *to, unsigned int offset,
-			unsigned int fraglen)
+			unsigned int fraglen, struct sk_buff *skb)
 {
 	struct rawfakehdr *rfh = (struct rawfakehdr *) p;
+	skb->ip_summed = CHECKSUM_NONE; /* Is there any good place to set it? */
 	return memcpy_fromiovecend(to, rfh->iov, offset, fraglen);
 }
 
@@ -270,9 +271,11 @@
  */
  
 static int raw_getrawfrag(const void *p, char *to, unsigned int offset,
-				unsigned int fraglen)
+				unsigned int fraglen, struct sk_buff *skb)
 {
 	struct rawfakehdr *rfh = (struct rawfakehdr *) p;
+
+	skb->ip_summed = CHECKSUM_NONE; /* Is there any good place to set it? */
 
 	if (memcpy_fromiovecend(to, rfh->iov, offset, fraglen))
 		return -EFAULT;
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Wed Oct 16 01:52:03 2002
+++ b/net/ipv4/tcp.c	Wed Oct 16 01:52:03 2002
@@ -204,6 +204,8 @@
  *		Andi Kleen 	:	Make poll agree with SIGIO
  *	Salvatore Sanfilippo	:	Support SO_LINGER with linger == 1 and
  *					lingertime == 0 (RFC 793 ABORT Call)
+ *	Hirokazu Takahashi	:	Use copy_from_user() instead of
+ *					csum_and_copy_from_user() if possible.
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -958,8 +960,8 @@
 	return res;
 }
 
-#define TCP_PAGE(sk)	(tcp_sk(sk)->sndmsg_page)
-#define TCP_OFF(sk)	(tcp_sk(sk)->sndmsg_off)
+#define TCP_PAGE(sk)	(inet_sk(sk)->sndmsg_page)
+#define TCP_OFF(sk)	(inet_sk(sk)->sndmsg_off)
 
 static inline int tcp_copy_to_page(struct sock *sk, char *from,
 				   struct sk_buff *skb, struct page *page,
@@ -968,18 +970,22 @@
 	int err = 0;
 	unsigned int csum;
 
-	csum = csum_and_copy_from_user(from, page_address(page) + off,
+	if (skb->ip_summed == CHECKSUM_NONE) {
+		csum = csum_and_copy_from_user(from, page_address(page) + off,
 				       copy, 0, &err);
-	if (!err) {
-		if (skb->ip_summed == CHECKSUM_NONE)
-			skb->csum = csum_block_add(skb->csum, csum, skb->len);
-		skb->len += copy;
-		skb->data_len += copy;
-		skb->truesize += copy;
-		sk->wmem_queued += copy;
-		sk->forward_alloc -= copy;
+		if (err) return err;
+		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+	} else {
+		if (copy_from_user(page_address(page) + off, from, copy))
+			return -EFAULT;
 	}
-	return err;
+
+	skb->len += copy;
+	skb->data_len += copy;
+	skb->truesize += copy;
+	sk->wmem_queued += copy;
+	sk->forward_alloc -= copy;
+	return 0;
 }
 
 static inline int skb_add_data(struct sk_buff *skb, char *from, int copy)
@@ -988,11 +994,16 @@
 	unsigned int csum;
 	int off = skb->len;
 
-	csum = csum_and_copy_from_user(from, skb_put(skb, copy),
+	if (skb->ip_summed == CHECKSUM_NONE) {
+		csum = csum_and_copy_from_user(from, skb_put(skb, copy),
 				       copy, 0, &err);
-	if (!err) {
-		skb->csum = csum_block_add(skb->csum, csum, off);
-		return 0;
+		if (!err) {
+			skb->csum = csum_block_add(skb->csum, csum, off);
+			return 0;
+		}
+	} else {
+		if (!copy_from_user(skb_put(skb, copy), from, copy))
+			return 0;
 	}
 
 	__skb_trim(skb, off);
@@ -1074,6 +1085,12 @@
 						     0, sk->allocation);
 				if (!skb)
 					goto wait_for_memory;
+
+				/*
+				 * Check whether we can use HW checksum.
+				 */
+				if (sk->route_caps & (NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM))
+					skb->ip_summed = CHECKSUM_HW;
 
 				skb_entail(sk, tp, skb);
 				copy = mss_now;
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	Wed Oct 16 01:52:04 2002
+++ b/net/ipv4/tcp_ipv4.c	Wed Oct 16 01:52:04 2002
@@ -781,6 +781,7 @@
 
 	__sk_dst_set(sk, &rt->u.dst);
 	tcp_v4_setup_caps(sk, &rt->u.dst);
+	tp->ext_header_len += rt->u.dst.header_len;
 
 	if (!inet->opt || !inet->opt->srr)
 		daddr = rt->rt_dst;
@@ -1577,6 +1578,7 @@
 	newtp->ext_header_len = 0;
 	if (newinet->opt)
 		newtp->ext_header_len = newinet->opt->optlen;
+	newtp->ext_header_len += dst->header_len;
 	newinet->id = newtp->write_seq ^ jiffies;
 
 	tcp_sync_mss(newsk, dst->pmtu);
@@ -2087,8 +2089,8 @@
 		tcp_put_port(sk);
 
 	/* If sendmsg cached page exists, toss it. */
-	if (tp->sndmsg_page)
-		__free_page(tp->sndmsg_page);
+	if (inet_sk(sk)->sndmsg_page)
+		__free_page(inet_sk(sk)->sndmsg_page);
 
 	atomic_dec(&tcp_sockets_allocated);
 
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	Wed Oct 16 01:52:03 2002
+++ b/net/ipv4/udp.c	Wed Oct 16 01:52:03 2002
@@ -11,6 +11,7 @@
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Arnt Gulbrandsen, <agulbra@nvg.unit.no>
  *		Alan Cox, <Alan.Cox@linux.org>
+ *		Hirokazu Takahashi, <taka@valinux.co.jp>
  *
  * Fixes:
  *		Alan Cox	:	verify_area() calls
@@ -62,6 +63,9 @@
  *		Janos Farkas	:	don't deliver multi/broadcasts to a different
  *					bound-to-device socket
  *		Arnaldo C. Melo :	move proc routines to ip_proc.c.
+ *	Hirokazu Takahashi	:	HW checksumming for outgoing UDP
+ *					datagrams.
+ *	Hirokazu Takahashi	:	sendfile() on UDP works now.
  *
  *
  *		This program is free software; you can redistribute it and/or
@@ -365,6 +369,95 @@
 	sock_put(sk);
 }
 
+/*
+ * Throw away all pending data and cancel the corking. Socket is locked.
+ */
+static void udp_flush_pending_frames(struct sock *sk)
+{
+	struct udp_opt *up = udp_sk(sk);
+
+	if (up->pending) {
+		up->pending = 0;
+		ip_flush_pending_frames(sk);
+	}
+}
+
+/*
+ * Push out all pending data as one UDP datagram. Socket is locked.
+ */
+static int udp_push_pending_frames(struct sock *sk, struct udp_opt *up)
+{
+	struct sk_buff *skb;
+	struct udphdr *uh;
+	int err = 0;
+
+	/* Grab the skbuff where UDP header space exists. */
+	if ((skb = skb_peek(&sk->write_queue)) == NULL)
+		goto out;
+
+	/*
+	 * Create a UDP header
+	 */
+	uh = skb->h.uh;
+	uh->source = up->sport;
+	uh->dest = up->dport;
+	uh->len = htons(up->len);
+	uh->check = 0;
+
+	if (sk->no_check == UDP_CSUM_NOXMIT) {
+		skb->ip_summed = CHECKSUM_NONE;
+		goto send;
+	}
+
+	if (skb_queue_len(&sk->write_queue) == 1) {
+		/*
+		 * Only one fragment on the socket.
+		 */
+		if (skb->ip_summed == CHECKSUM_HW) {
+			skb->csum = offsetof(struct udphdr, check);
+			uh->check = ~csum_tcpudp_magic(up->saddr, up->daddr,
+					up->len, IPPROTO_UDP, 0);
+		} else {
+			skb->csum = csum_partial((char *)uh,
+					sizeof(struct udphdr), skb->csum);
+			uh->check = csum_tcpudp_magic(up->saddr, up->daddr,
+					up->len, IPPROTO_UDP, skb->csum);
+			if (uh->check == 0)
+				uh->check = -1;
+		}
+	} else {
+		unsigned int csum = 0;
+		/*
+		 * HW-checksum won't work as there are two or more 
+		 * fragments on the socket so that all csums of sk_buffs
+		 * should be together.
+		 */
+		if (skb->ip_summed == CHECKSUM_HW) {
+			int offset = (unsigned char *)uh - skb->data;
+			skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+			skb->ip_summed = CHECKSUM_NONE;
+		} else {
+			skb->csum = csum_partial((char *)uh,
+					sizeof(struct udphdr), skb->csum);
+		}
+
+		skb_queue_walk(&sk->write_queue, skb) {
+			csum = csum_add(csum, skb->csum);
+		}
+		uh->check = csum_tcpudp_magic(up->saddr, up->daddr,
+				up->len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = -1;
+	}
+send:
+	err = ip_push_pending_frames(sk);
+out:
+	up->len = 0;
+	up->pending = 0;
+	return err;
+}
+
 
 static unsigned short udp_check(struct udphdr *uh, int len, unsigned long saddr, unsigned long daddr, unsigned long base)
 {
@@ -384,10 +477,19 @@
  *	Copy and checksum a UDP packet from user space into a buffer.
  */
  
-static int udp_getfrag(const void *p, char * to, unsigned int offset, unsigned int fraglen) 
+static int udp_getfrag(const void *p, char * to, unsigned int offset, unsigned int fraglen, struct sk_buff *skb) 
 {
 	struct udpfakehdr *ufh = (struct udpfakehdr *)p;
 	if (offset==0) {
+		if (skb->ip_summed == CHECKSUM_HW) {
+			skb->csum = offsetof(struct udphdr, check);
+			ufh->uh.check = ~csum_tcpudp_magic(ufh->saddr, ufh->daddr, 
+					  ntohs(ufh->uh.len), IPPROTO_UDP, ufh->wcheck);
+			memcpy(to, ufh, sizeof(struct udphdr));
+			return memcpy_fromiovecend(to+sizeof(struct udphdr), ufh->iov, offset,
+					   fraglen-sizeof(struct udphdr));
+		}
+
 		if (csum_partial_copy_fromiovecend(to+sizeof(struct udphdr), ufh->iov, offset,
 						   fraglen-sizeof(struct udphdr), &ufh->wcheck))
 			return -EFAULT;
@@ -411,10 +513,11 @@
  *	Copy a UDP packet from user space into a buffer without checksumming.
  */
  
-static int udp_getfrag_nosum(const void *p, char * to, unsigned int offset, unsigned int fraglen) 
+static int udp_getfrag_nosum(const void *p, char * to, unsigned int offset, unsigned int fraglen, struct sk_buff *skb) 
 {
 	struct udpfakehdr *ufh = (struct udpfakehdr *)p;
 
+	skb->ip_summed = CHECKSUM_NONE;
 	if (offset==0) {
 		memcpy(to, ufh, sizeof(struct udphdr));
 		return memcpy_fromiovecend(to+sizeof(struct udphdr), ufh->iov, offset,
@@ -428,7 +531,8 @@
 		int len)
 {
 	struct inet_opt *inet = inet_sk(sk);
-	int ulen = len + sizeof(struct udphdr);
+	struct udp_opt *up = udp_sk(sk);
+	int ulen = len;
 	struct ipcm_cookie ipc;
 	struct udpfakehdr ufh;
 	struct rtable *rt = NULL;
@@ -437,6 +541,7 @@
 	u32 daddr;
 	u8  tos;
 	int err;
+	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 
 	/* This check is ONLY to check for arithmetic overflow
 	   on integer(!) len. Not more! Real check will be made
@@ -459,10 +564,26 @@
 	if (msg->msg_flags&MSG_OOB)	/* Mirror BSD error message compatibility */
 		return -EOPNOTSUPP;
 
+	ipc.opt = NULL;
+
+	if (up->pending) {
+		/*
+		 * There are pending frames.
+	 	 * The socket lock must be held while it's corked.
+		 */
+		lock_sock(sk);
+		if (likely(up->pending))
+ 			goto do_append_data;
+		release_sock(sk);
+
+		NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "udp cork app bug 1\n"));
+		return -EINVAL;
+	}
+	ulen += sizeof(struct udphdr);
+
 	/*
 	 *	Get and verify the address. 
 	 */
-	 
 	if (msg->msg_name) {
 		struct sockaddr_in * usin = (struct sockaddr_in*)msg->msg_name;
 		if (msg->msg_namelen < sizeof(*usin))
@@ -489,7 +610,6 @@
 	ipc.addr = inet->saddr;
 	ufh.uh.source = inet->sport;
 
-	ipc.opt = NULL;
 	ipc.oif = sk->bound_dev_if;
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(msg, &ipc);
@@ -558,6 +678,29 @@
 	ufh.iov = msg->msg_iov;
 	ufh.wcheck = 0;
 
+	/* 0x80000000 is temporary hook for testing new output path */
+	if (corkreq || rt->u.dst.header_len || (msg->msg_flags&0x80000000)) {
+		lock_sock(sk);
+		if (unlikely(up->pending)) {
+			/* The socket is already corked while preparing it. */
+			/* ... which is an evident application bug. --ANK */
+			release_sock(sk);
+
+			NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "udp cork app bug 2\n"));
+			err = -EINVAL;
+			goto out;
+		}
+		/*
+		 *	Now cork the socket to pend data.
+		 */
+		up->daddr = ufh.daddr;
+		up->dport = ufh.uh.dest;
+		up->saddr = ufh.saddr;
+		up->sport = ufh.uh.source;
+		up->pending = 1;
+		goto do_append_data;
+	}
+
 	/* RFC1122: OK.  Provides the checksumming facility (MUST) as per */
 	/* 4.1.3.4. It's configurable by the application via setsockopt() */
 	/* (MAY) and it defaults to on (MUST). */
@@ -584,6 +727,62 @@
 		goto back_from_confirm;
 	err = 0;
 	goto out;
+
+do_append_data:
+	up->len += ulen;
+	err = ip_append_data(sk, generic_getfrag, msg->msg_iov, ulen, sizeof(struct udphdr), &ipc, rt, msg->msg_flags);
+	if (err)
+		udp_flush_pending_frames(sk);
+	else if (!corkreq)
+		err = udp_push_pending_frames(sk, up);
+	release_sock(sk);
+	goto out;
+}
+
+ssize_t udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size, int flags)
+{
+	struct udp_opt *up = udp_sk(sk);
+	int ret;
+
+	if (!up->pending) {
+		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };
+
+		/* Call udp_sendmsg to specify destination address which
+		 * sendpage interface can't pass.
+		 * This will succeed only when the socket is connected.
+		 */
+		ret = udp_sendmsg(NULL, sk, &msg, 0);
+		if (ret < 0)
+			return ret;
+	}
+
+	lock_sock(sk);
+
+	if (unlikely(!up->pending)) {
+		release_sock(sk);
+
+		NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "udp cork app bug 3\n"));
+		return -EINVAL;
+	}
+
+	ret = ip_append_page(sk, page, offset, size, flags);
+	if (ret == -EOPNOTSUPP) {
+		release_sock(sk);
+		return sock_no_sendpage(sk->socket, page, offset, size, flags);
+	}
+	if (ret < 0) {
+		udp_flush_pending_frames(sk);
+		goto out;
+	}
+
+	up->len += size;
+	if (!(up->corkflag || (flags&MSG_MORE)))
+		ret = udp_push_pending_frames(sk, up);
+	if (!ret)
+		ret = size;
+out:
+	release_sock(sk);
+	return ret;
 }
 
 /*
@@ -985,16 +1184,99 @@
 	return(0);
 }
 
+static int udp_destroy_sock(struct sock *sk)
+{
+	lock_sock(sk);
+	udp_flush_pending_frames(sk);
+	release_sock(sk);
+	return 0;
+}
+
+/*
+ *	Socket option code for UDP
+ */
+static int udp_setsockopt(struct sock *sk, int level, int optname, 
+			  char *optval, int optlen)
+{
+	struct udp_opt *up = udp_sk(sk);
+	int val;
+	int err = 0;
+
+	if (level != SOL_UDP)
+		return ip_setsockopt(sk, level, optname, optval, optlen);
+
+	if(optlen<sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int *)optval))
+		return -EFAULT;
+
+	switch(optname) {
+	case UDP_CORK:
+		if (val != 0) {
+			up->corkflag = 1;
+		} else {
+			up->corkflag = 0;
+			lock_sock(sk);
+			udp_push_pending_frames(sk, up);
+			release_sock(sk);
+		}
+		break;
+		
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	};
+
+	return err;
+}
+
+static int udp_getsockopt(struct sock *sk, int level, int optname, 
+			  char *optval, int *optlen)
+{
+	struct udp_opt *up = udp_sk(sk);
+	int val, len;
+
+	if (level != SOL_UDP)
+		return ip_getsockopt(sk, level, optname, optval, optlen);
+
+	if(get_user(len,optlen))
+		return -EFAULT;
+
+	len = min_t(unsigned int, len, sizeof(int));
+	
+	if(len < 0)
+		return -EINVAL;
+
+	switch(optname) {
+	case UDP_CORK:
+		val = up->corkflag;
+		break;
+
+	default:
+		return -ENOPROTOOPT;
+	};
+
+  	if(put_user(len, optlen))
+  		return -EFAULT;
+	if(copy_to_user(optval, &val,len))
+		return -EFAULT;
+  	return 0;
+}
+
+
 struct proto udp_prot = {
  	.name =		"UDP",
 	.close =	udp_close,
 	.connect =	udp_connect,
 	.disconnect =	udp_disconnect,
 	.ioctl =	udp_ioctl,
-	.setsockopt =	ip_setsockopt,
-	.getsockopt =	ip_getsockopt,
+	.destroy =	udp_destroy_sock,
+	.setsockopt =	udp_setsockopt,
+	.getsockopt =	udp_getsockopt,
 	.sendmsg =	udp_sendmsg,
 	.recvmsg =	udp_recvmsg,
+	.sendpage =	udp_sendpage,
 	.backlog_rcv =	udp_queue_rcv_skb,
 	.hash =		udp_v4_hash,
 	.unhash =	udp_v4_unhash,
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Wed Oct 16 01:52:04 2002
+++ b/net/ipv6/tcp_ipv6.c	Wed Oct 16 01:52:04 2002
@@ -1876,6 +1876,7 @@
 static int tcp_v6_destroy_sock(struct sock *sk)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
+	struct inet_opt *inet = inet_sk(sk);
 
 	tcp_clear_xmit_timers(sk);
 
@@ -1893,8 +1894,8 @@
 		tcp_put_port(sk);
 
 	/* If sendmsg cached page exists, toss it. */
-	if (tp->sndmsg_page != NULL)
-		__free_page(tp->sndmsg_page);
+	if (inet->sndmsg_page != NULL)
+		__free_page(inet->sndmsg_page);
 
 	atomic_dec(&tcp_sockets_allocated);
 


ChangeSet@1.850, 2002-10-15 19:31:15-07:00, davem@nuts.ninka.net
  [NET]: Cleanup now that sockfd_lookup/sockfd_put are exported.
  - Delete redefinitions of sockfd_{lookup,put}
  - Fix socket fd leaks in route ioctl32 code.

diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/ia64/ia32/sys_ia32.c	Wed Oct 16 01:52:06 2002
@@ -1664,20 +1664,11 @@
 	kmsg->msg_control = (void *) orig_cmsg_uptr;
 }
 
-static inline void
-sockfd_put (struct socket *sock)
-{
-	fput(sock->file);
-}
-
 /* XXX This really belongs in some header file... -DaveM */
 #define MAX_SOCK_ADDR	128		/* 108 for Unix domain -
 					   16 for IP, 16 for IPX,
 					   24 for IPv6,
 					   about 80 for AX.25 */
-
-extern struct socket *sockfd_lookup (int fd, int *err);
-
 /*
  *	BSD sendmsg interface
  */
diff -Nru a/arch/mips64/kernel/linux32.c b/arch/mips64/kernel/linux32.c
--- a/arch/mips64/kernel/linux32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/mips64/kernel/linux32.c	Wed Oct 16 01:52:06 2002
@@ -2084,19 +2084,11 @@
 	return err;
 }
 
-extern __inline__ void
-sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 /* XXX This really belongs in some header file... -DaveM */
 #define MAX_SOCK_ADDR	128		/* 108 for Unix domain - 
 					   16 for IP, 16 for IPX,
 					   24 for IPv6,
 					   about 80 for AX.25 */
-
-extern struct socket *sockfd_lookup(int fd, int *err);
 
 /*
  *	BSD sendmsg interface
diff -Nru a/arch/ppc64/kernel/ioctl32.c b/arch/ppc64/kernel/ioctl32.c
--- a/arch/ppc64/kernel/ioctl32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/ppc64/kernel/ioctl32.c	Wed Oct 16 01:52:06 2002
@@ -754,8 +754,6 @@
 	s32			rtmsg_ifindex;
 };
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
 static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	int ret;
@@ -803,6 +801,9 @@
 	set_fs (KERNEL_DS);
 	ret = sys_ioctl (fd, cmd, (long) r);
 	set_fs (old_fs);
+
+	if (mysock)
+		sockfd_put(mysock);
 
 	return ret;
 }
diff -Nru a/arch/ppc64/kernel/sys_ppc32.c b/arch/ppc64/kernel/sys_ppc32.c
--- a/arch/ppc64/kernel/sys_ppc32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/ppc64/kernel/sys_ppc32.c	Wed Oct 16 01:52:06 2002
@@ -2891,13 +2891,6 @@
 			       __cmsg, __cmsg_len);
 }
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
-extern __inline__ void sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 static inline int msghdr_from_user32_to_kern(struct msghdr *kmsg, struct msghdr32 *umsg)
 {
 	u32 tmp1, tmp2, tmp3;
diff -Nru a/arch/s390x/kernel/linux32.c b/arch/s390x/kernel/linux32.c
--- a/arch/s390x/kernel/linux32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/s390x/kernel/linux32.c	Wed Oct 16 01:52:06 2002
@@ -2129,14 +2129,6 @@
 					   24 for IPv6,
 					   about 80 for AX.25 */
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
-/* XXX This as well... */
-extern __inline__ void sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 struct msghdr32 {
         u32               msg_name;
         int               msg_namelen;
diff -Nru a/arch/sparc64/kernel/ioctl32.c b/arch/sparc64/kernel/ioctl32.c
--- a/arch/sparc64/kernel/ioctl32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/sparc64/kernel/ioctl32.c	Wed Oct 16 01:52:06 2002
@@ -797,8 +797,6 @@
 	s32			rtmsg_ifindex;
 };
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
 static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	int ret;
@@ -846,6 +844,9 @@
 	set_fs (KERNEL_DS);
 	ret = sys_ioctl (fd, cmd, (long) r);
 	set_fs (old_fs);
+
+	if (mysock)
+		sockfd_put(mysock);
 
 	return ret;
 }
diff -Nru a/arch/sparc64/kernel/sys_sparc32.c b/arch/sparc64/kernel/sys_sparc32.c
--- a/arch/sparc64/kernel/sys_sparc32.c	Wed Oct 16 01:52:06 2002
+++ b/arch/sparc64/kernel/sys_sparc32.c	Wed Oct 16 01:52:06 2002
@@ -2133,14 +2133,6 @@
 					   24 for IPv6,
 					   about 80 for AX.25 */
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
-/* XXX This as well... */
-extern __inline__ void sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 struct msghdr32 {
         u32               msg_name;
         int               msg_namelen;
diff -Nru a/arch/x86_64/ia32/ia32_ioctl.c b/arch/x86_64/ia32/ia32_ioctl.c
--- a/arch/x86_64/ia32/ia32_ioctl.c	Wed Oct 16 01:52:06 2002
+++ b/arch/x86_64/ia32/ia32_ioctl.c	Wed Oct 16 01:52:06 2002
@@ -715,8 +715,6 @@
 	s32			rtmsg_ifindex;
 };
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
 static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	int ret;
@@ -764,6 +762,9 @@
 	set_fs (KERNEL_DS);
 	ret = sys_ioctl (fd, cmd, (long) r);
 	set_fs (old_fs);
+
+	if (mysock)
+		sockfd_put(mysock);
 
 	return ret;
 }
diff -Nru a/include/asm-x86_64/socket32.h b/include/asm-x86_64/socket32.h
--- a/include/asm-x86_64/socket32.h	Wed Oct 16 01:52:06 2002
+++ b/include/asm-x86_64/socket32.h	Wed Oct 16 01:52:06 2002
@@ -7,14 +7,6 @@
 					   24 for IPv6,
 					   about 80 for AX.25 */
 
-extern struct socket *sockfd_lookup(int fd, int *err);
-
-/* XXX This as well... */
-extern __inline__ void sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 struct msghdr32 {
         u32               msg_name;
         int               msg_namelen;


ChangeSet@1.851, 2002-10-15 19:46:59-07:00, davem@nuts.ninka.net
  arch/sparc64/solaris/socket.c: Kill more sockfd_{lookup,put} redefinitions.

diff -Nru a/arch/sparc64/solaris/socket.c b/arch/sparc64/solaris/socket.c
--- a/arch/sparc64/solaris/socket.c	Wed Oct 16 01:52:08 2002
+++ b/arch/sparc64/solaris/socket.c	Wed Oct 16 01:52:08 2002
@@ -248,31 +248,6 @@
 					   24 for IPv6,
 					   about 80 for AX.25 */
 
-extern __inline__ struct socket *sockfd_lookup(int fd, int *err)
-{
-	struct file *file;
-	struct inode *inode;
-
-	if (!(file = fget(fd))) {
-		*err = -EBADF;
-		return NULL;
-	}
-
-	inode = file->f_dentry->d_inode;
-	if (!inode->i_sock) {
-		*err = -ENOTSOCK;
-		fput(file);
-		return NULL;
-	}
-
-	return SOCKET_I(inode);
-}
-
-extern __inline__ void sockfd_put(struct socket *sock)
-{
-	fput(sock->file);
-}
-
 struct sol_nmsghdr {
 	u32		msg_name;
 	int		msg_namelen;


ChangeSet@1.852, 2002-10-15 20:02:30-07:00, davem@nuts.ninka.net
  net/ipv4/udp.c: proto sendpage returns int not size_t.

diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	Wed Oct 16 01:52:09 2002
+++ b/net/ipv4/udp.c	Wed Oct 16 01:52:09 2002
@@ -739,7 +739,7 @@
 	goto out;
 }
 
-ssize_t udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size, int flags)
+int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size, int flags)
 {
 	struct udp_opt *up = udp_sk(sk);
 	int ret;


ChangeSet@1.853, 2002-10-15 21:30:57-07:00, davem@nuts.ninka.net
  net/bluetooth/bnep/sock.c: Kill another sockfd_lookup re-implementation.

diff -Nru a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c	Wed Oct 16 01:52:11 2002
+++ b/net/bluetooth/bnep/sock.c	Wed Oct 16 01:52:11 2002
@@ -55,31 +55,6 @@
 #define BT_DBG( A... )
 #endif
 
-static struct socket *sockfd_lookup(int fd, int *err)
-{
-	struct file *file;
-	struct inode *inode;
-	struct socket *sock;
-
-	if (!(file = fget(fd))) {
-		*err = -EBADF;
-		return NULL;
-	}
-
-	inode = file->f_dentry->d_inode;
-	if (!inode->i_sock || !(sock = SOCKET_I(inode))) {
-		*err = -ENOTSOCK;
-		fput(file);
-		return NULL;
-	}
-
-	if (sock->file != file) {
-		printk(KERN_ERR "socki_lookup: socket file changed!\n");
-		sock->file = file;
-	}
-	return sock;
-}
- 
 static int bnep_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;


ChangeSet@1.854, 2002-10-15 21:41:35-07:00, davem@nuts.ninka.net
  Merge nuts.ninka.net:/home/davem/src/BK/network-2.5
  into nuts.ninka.net:/home/davem/src/BK/net-2.5

diff -Nru a/arch/sparc64/kernel/sys_sparc32.c b/arch/sparc64/kernel/sys_sparc32.c
--- a/arch/sparc64/kernel/sys_sparc32.c	Wed Oct 16 01:52:13 2002
+++ b/arch/sparc64/kernel/sys_sparc32.c	Wed Oct 16 01:52:13 2002
@@ -273,7 +273,7 @@
     struct timeval32 it_value;
 };
 
-static inline long get_tv32(struct timeval *o, struct timeval32 *i)
+static long get_tv32(struct timeval *o, struct timeval32 *i)
 {
 	return (!access_ok(VERIFY_READ, tv32, sizeof(*tv32)) ||
 		(__get_user(o->tv_sec, &i->tv_sec) |
@@ -296,7 +296,7 @@
 		 __get_user(o->it_value.tv_usec, &i->it_value.tv_usec)));
 }
 
-static inline long put_it32(struct itimerval32 *o, struct itimerval *i)
+static long put_it32(struct itimerval32 *o, struct itimerval *i)
 {
 	return (!access_ok(VERIFY_WRITE, i32, sizeof(*i32)) ||
 		(__put_user(i->it_interval.tv_sec, &o->it_interval.tv_sec) |
@@ -890,7 +890,7 @@
 	return sys32_fcntl(fd, cmd, arg);
 }
 
-static inline int put_statfs (struct statfs32 *ubuf, struct statfs *kbuf)
+static int put_statfs (struct statfs32 *ubuf, struct statfs *kbuf)
 {
 	int err;
 	
@@ -1272,8 +1272,7 @@
  * 64-bit unsigned longs.
  */
 
-static inline int
-get_fd_set32(unsigned long n, unsigned long *fdset, u32 *ufdset)
+static int get_fd_set32(unsigned long n, unsigned long *fdset, u32 *ufdset)
 {
 	if (ufdset) {
 		unsigned long odd;
@@ -1303,8 +1302,7 @@
 	return 0;
 }
 
-static inline void
-set_fd_set32(unsigned long n, u32 *ufdset, unsigned long *fdset)
+static void set_fd_set32(unsigned long n, u32 *ufdset, unsigned long *fdset)
 {
 	unsigned long odd;
 
@@ -2209,8 +2207,8 @@
 	return tot_len;
 }
 
-static inline int msghdr_from_user32_to_kern(struct msghdr *kmsg,
-					     struct msghdr32 *umsg)
+static int msghdr_from_user32_to_kern(struct msghdr *kmsg,
+				      struct msghdr32 *umsg)
 {
 	u32 tmp1, tmp2, tmp3;
 	int err;
diff -Nru a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c	Wed Oct 16 01:52:13 2002
+++ b/net/bluetooth/bnep/sock.c	Wed Oct 16 01:52:13 2002
@@ -50,7 +50,7 @@
 
 #include "bnep.h"
 
-#ifndef CONFIG_BLUEZ_BNEP_DEBUG
+#ifndef CONFIG_BT_BNEP_DEBUG
 #undef  BT_DBG
 #define BT_DBG( A... )
 #endif
@@ -173,7 +173,7 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = bluez_sock_alloc(sock, PF_BLUETOOTH, 0, GFP_KERNEL)))
+	if (!(sk = bt_sock_alloc(sock, PF_BLUETOOTH, 0, GFP_KERNEL)))
 		return -ENOMEM;
 	sock->ops = &bnep_sock_ops;
 
@@ -194,13 +194,13 @@
 
 int bnep_sock_init(void)
 {
-	bluez_sock_register(BTPROTO_BNEP, &bnep_sock_family_ops);
+	bt_sock_register(BTPROTO_BNEP, &bnep_sock_family_ops);
 	return 0;
 }
 
 int bnep_sock_cleanup(void)
 {
-	if (bluez_sock_unregister(BTPROTO_BNEP))
+	if (bt_sock_unregister(BTPROTO_BNEP))
 		BT_ERR("Can't unregister BNEP socket");
 	return 0;
 }


ChangeSet@1.844.1.14, 2002-10-16 03:11:34-03:00, acme@conectiva.com.br
  o ipv4: udp seq_file support: produce only one record per seq_show

diff -Nru a/net/ipv4/ip_proc.c b/net/ipv4/ip_proc.c
--- a/net/ipv4/ip_proc.c	Wed Oct 16 01:52:15 2002
+++ b/net/ipv4/ip_proc.c	Wed Oct 16 01:52:15 2002
@@ -198,16 +198,64 @@
 
 /* ------------------------------------------------------------------------ */
 
+#define UDP_HASH_POS_BITS (sizeof(loff_t) * 8 - 8)
+#define UDP_HASH_BITS (((loff_t)127) << UDP_HASH_POS_BITS)
+#define UDP_HASH_BUCKET(p) ((p & UDP_HASH_BITS) >> UDP_HASH_POS_BITS)
+
+static __inline__ struct sock *udp_get_bucket(struct seq_file *seq, loff_t *pos)
+{
+	struct sock *sk = NULL;
+	loff_t ppos = *pos & ~UDP_HASH_BITS, l = ppos;
+	loff_t bucket = UDP_HASH_BUCKET(*pos);
+
+	for (; bucket < UDP_HTABLE_SIZE; ++bucket)
+		for (sk = udp_hash[bucket]; sk; sk = sk->next) {
+			if (sk->family != PF_INET)
+				continue;
+			if (l--)
+				continue;
+			*pos = (bucket << UDP_HASH_POS_BITS) | ppos;
+			/*
+			 * temporary HACK till we have a solution to
+			 * get more state passed to seq_show -acme
+			 */
+			seq->private = (void *)(int)bucket;
+			goto out;
+		}
+out:
+	return sk;
+}
+
 static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&udp_hash_lock);
-	return (void *)(unsigned long)++*pos;
+	return *pos ? udp_get_bucket(seq, pos) : (void *)1;
 }
 
 static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	return (void *)(unsigned long)((++*pos) >=
-				       (UDP_HTABLE_SIZE - 1) ? 0 : *pos);
+	int next_bucket;
+	struct sock *sk;
+
+	if (v == (void *)1) {
+		sk = udp_get_bucket(seq, pos);
+		goto out;
+	}
+
+	sk = v;
+	sk = sk->next;
+	if (sk) 
+		goto out;
+
+	next_bucket = UDP_HASH_BUCKET(*pos) + 1;
+	if (next_bucket >= UDP_HTABLE_SIZE) 
+		goto out;
+
+	*pos = (loff_t)next_bucket << UDP_HASH_POS_BITS;
+	sk = udp_get_bucket(seq, pos);
+out:
+	++*pos;
+	return sk;
 }
 
 static void udp_seq_stop(struct seq_file *seq, void *v)
@@ -215,7 +263,7 @@
 	read_unlock(&udp_hash_lock);
 }
 
-static void udp_format_sock(struct sock *sp, char *tmpbuf, int i)
+static void udp_format_sock(struct sock *sp, char *tmpbuf, int bucket)
 {
 	struct inet_opt *inet = inet_sk(sp);
 	unsigned int dest = inet->daddr;
@@ -225,7 +273,7 @@
 
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p",
-		i, src, srcp, dest, destp, sp->state, 
+		bucket, src, srcp, dest, destp, sp->state, 
 		atomic_read(&sp->wmem_alloc), atomic_read(&sp->rmem_alloc),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->refcnt), sp);
@@ -233,19 +281,15 @@
 
 static int udp_seq_show(struct seq_file *seq, void *v)
 {
-	char tmpbuf[129];
-	struct sock *sk;
-	unsigned long l = (unsigned long)v - 1;
-
-	if (!l)
+	if (v == (void *)1)
 		seq_printf(seq, "%-127s\n",
 			   "  sl  local_address rem_address   st tx_queue "
-			   "rx_queue tr tm->when retrnsmt   uid  timeout inode");
+			   "rx_queue tr tm->when retrnsmt   uid  timeout "
+			   "inode");
+	else {
+		char tmpbuf[129];
 
-	for (sk = udp_hash[l]; sk; sk = sk->next) {
-		if (sk->family != PF_INET)
-			continue;
-		udp_format_sock(sk, tmpbuf, l);
+		udp_format_sock(v, tmpbuf, (int)seq->private);
 		seq_printf(seq, "%-127s\n", tmpbuf);
 	}
 	return 0;


ChangeSet@1.856, 2002-10-15 23:44:37-07:00, davem@nuts.ninka.net
  net/ipv4/ip_proc.c: Fix 64-bit warnings.

diff -Nru a/net/ipv4/ip_proc.c b/net/ipv4/ip_proc.c
--- a/net/ipv4/ip_proc.c	Wed Oct 16 01:52:17 2002
+++ b/net/ipv4/ip_proc.c	Wed Oct 16 01:52:17 2002
@@ -219,7 +219,7 @@
 			 * temporary HACK till we have a solution to
 			 * get more state passed to seq_show -acme
 			 */
-			seq->private = (void *)(int)bucket;
+			seq->private = (void *)(long)bucket;
 			goto out;
 		}
 out:
@@ -289,7 +289,7 @@
 	else {
 		char tmpbuf[129];
 
-		udp_format_sock(v, tmpbuf, (int)seq->private);
+		udp_format_sock(v, tmpbuf, (long)seq->private);
 		seq_printf(seq, "%-127s\n", tmpbuf);
 	}
 	return 0;


ChangeSet@1.857, 2002-10-16 01:43:12-07:00, davem@nuts.ninka.net
  [NET]: Apply missed parts of csum_partial_copy killing patch.

diff -Nru a/arch/alpha/kernel/alpha_ksyms.c b/arch/alpha/kernel/alpha_ksyms.c
--- a/arch/alpha/kernel/alpha_ksyms.c	Wed Oct 16 01:52:19 2002
+++ b/arch/alpha/kernel/alpha_ksyms.c	Wed Oct 16 01:52:19 2002
@@ -167,7 +167,6 @@
 EXPORT_SYMBOL(csum_tcpudp_magic);
 EXPORT_SYMBOL(ip_compute_csum);
 EXPORT_SYMBOL(ip_fast_csum);
-EXPORT_SYMBOL(csum_partial_copy);
 EXPORT_SYMBOL(csum_partial_copy_nocheck);
 EXPORT_SYMBOL(csum_partial_copy_from_user);
 EXPORT_SYMBOL(csum_ipv6_magic);
diff -Nru a/arch/alpha/lib/csum_partial_copy.c b/arch/alpha/lib/csum_partial_copy.c
--- a/arch/alpha/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
+++ b/arch/alpha/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
@@ -385,16 +385,3 @@
 {
 	return do_csum_partial_copy_from_user(src, dst, len, sum, NULL);
 }
-
-unsigned int
-csum_partial_copy (const char *src, char *dst, int len, unsigned int sum)
-{
-	unsigned int ret;
-	int error = 0;
-
-	ret = do_csum_partial_copy_from_user(src, dst, len, sum, &error);
-	if (error)
-		printk("csum_partial_copy_old(): tell mingo to convert me!\n");
-
-	return ret;
-}
diff -Nru a/arch/cris/lib/old_checksum.c b/arch/cris/lib/old_checksum.c
--- a/arch/cris/lib/old_checksum.c	Wed Oct 16 01:52:19 2002
+++ b/arch/cris/lib/old_checksum.c	Wed Oct 16 01:52:19 2002
@@ -80,48 +80,3 @@
   BITOFF;
   return(sum);
 }
-
-#if 0
-
-/*
- * copy while checksumming, otherwise like csum_partial
- */
-
-unsigned int csum_partial_copy(const unsigned char *src, unsigned char *dst, 
-				  int len, unsigned int sum)
-{
-  const unsigned char *endMarker;
-  const unsigned char *marker;
-  printk("csum_partial_copy len %d.\n", len);
-#if 0
-  if((int)src & 0x3)
-    printk("unaligned src %p\n", src);
-  if((int)dst & 0x3)
-    printk("unaligned dst %p\n", dst);
-  __delay(1800); /* extra delay of 90 us to test performance hit */
-#endif
-  endMarker = src + len;
-  marker = endMarker - (len % 16);
-  CBITON;
-  while(src < marker) {
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-  }
-  marker = endMarker - (len % 2);
-  while(src < marker) {
-    sum += (*((unsigned short *)dst)++ = *((unsigned short *)src)++);
-  }
-  if(endMarker - src > 0) {
-    sum += (*dst = *src);                 /* add extra byte seperately */
-  }
-  CBITOFF;
-  return(sum);
-}
-
-#endif
diff -Nru a/arch/ia64/lib/csum_partial_copy.c b/arch/ia64/lib/csum_partial_copy.c
--- a/arch/ia64/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
+++ b/arch/ia64/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
@@ -146,16 +146,3 @@
 	return do_csum_partial_copy_from_user(src, dst, len, sum, NULL);
 }
 
-unsigned int
-csum_partial_copy (const char *src, char *dst, int len, unsigned int sum)
-{
-	unsigned int ret;
-	int error = 0;
-
-	ret = do_csum_partial_copy_from_user(src, dst, len, sum, &error);
-	if (error)
-		printk("csum_partial_copy_old(): tell mingo to convert me!\n");
-
-	return ret;
-}
-
diff -Nru a/arch/m68k/kernel/m68k_ksyms.c b/arch/m68k/kernel/m68k_ksyms.c
--- a/arch/m68k/kernel/m68k_ksyms.c	Wed Oct 16 01:52:19 2002
+++ b/arch/m68k/kernel/m68k_ksyms.c	Wed Oct 16 01:52:19 2002
@@ -61,9 +61,6 @@
 EXPORT_SYMBOL(vme_brdtype);
 #endif
 
-/* Networking helper routines. */
-EXPORT_SYMBOL(csum_partial_copy);
-
 /* The following are special because they're not called
    explicitly (the C compiler generates them).  Fortunately,
    their interface isn't gonna change any time soon now, so
diff -Nru a/arch/m68k/lib/checksum.c b/arch/m68k/lib/checksum.c
--- a/arch/m68k/lib/checksum.c	Wed Oct 16 01:52:19 2002
+++ b/arch/m68k/lib/checksum.c	Wed Oct 16 01:52:19 2002
@@ -318,103 +318,3 @@
 
 	return(sum);
 }
-
-/*
- * copy from kernel space while checksumming, otherwise like csum_partial
- */
-
-unsigned int
-csum_partial_copy(const char *src, char *dst, int len, int sum)
-{
-	unsigned long tmp1, tmp2;
-	__asm__("movel %2,%4\n\t"
-		"btst #1,%4\n\t"	/* Check alignment */
-		"jeq 2f\n\t"
-		"subql #2,%1\n\t"	/* buff%4==2: treat first word */
-		"jgt 1f\n\t"
-		"addql #2,%1\n\t"	/* len was == 2, treat only rest */
-		"jra 4f\n"
-	     "1:\t"
-		"movew %2@+,%4\n\t"	/* add first word to sum */
-		"addw %4,%0\n\t"
-		"movew %4,%3@+\n\t"
-		"clrl %4\n\t"
-		"addxl %4,%0\n"		/* add X bit */
-	     "2:\t"
-		/* unrolled loop for the main part: do 8 longs at once */
-		"movel %1,%4\n\t"	/* save len in tmp1 */
-		"lsrl #5,%1\n\t"	/* len/32 */
-		"jeq 2f\n\t"		/* not enough... */
-		"subql #1,%1\n"
-	     "1:\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"dbra %1,1b\n\t"
-		"clrl %5\n\t"
-		"addxl %5,%0\n\t"	/* add X bit */
-		"clrw %1\n\t"
-		"subql #1,%1\n\t"
-		"jcc 1b\n"
-	     "2:\t"
-		"movel %4,%1\n\t"	/* restore len from tmp1 */
-		"andw #0x1c,%4\n\t"	/* number of rest longs */
-		"jeq 4f\n\t"
-		"lsrw #2,%4\n\t"
-		"subqw #1,%4\n"
-	     "3:\t"
-		/* loop for rest longs */
-		"movel %2@+,%5\n\t"
-		"addxl %5,%0\n\t"
-		"movel %5,%3@+\n\t"
-		"dbra %4,3b\n\t"
-		"clrl %5\n\t"
-		"addxl %5,%0\n"		/* add X bit */
-	     "4:\t"
-		/* now check for rest bytes that do not fit into longs */
-		"andw #3,%1\n\t"
-		"jeq 7f\n\t"
-		"clrl %5\n\t"		/* clear tmp2 for rest bytes */
-		"subqw #2,%1\n\t"
-		"jlt 5f\n\t"
-		"movew %2@+,%5\n\t"	/* have rest >= 2: get word */
-		"movew %5,%3@+\n\t"
-		"swap %5\n\t"		/* into bits 16..31 */
-		"tstw %1\n\t"		/* another byte? */
-		"jeq 6f\n"
-	     "5:\t"
-		"moveb %2@,%5\n\t"	/* have odd rest: get byte */
-		"moveb %5,%3@+\n\t"
-		"lslw #8,%5\n"		/* into bits 8..15; 16..31 untouched */
-	     "6:\t"
-		"addl %5,%0\n\t"	/* now add rest long to sum */
-		"clrl %5\n\t"
-		"addxl %5,%0\n"		/* add X bit */
-	     "7:\t"
-		: "=d" (sum), "=d" (len), "=a" (src), "=a" (dst),
-		  "=&d" (tmp1), "=&d" (tmp2)
-		: "0" (sum), "1" (len), "2" (src), "3" (dst)
-	    );
-    return(sum);
-}
diff -Nru a/arch/mips/kernel/mips_ksyms.c b/arch/mips/kernel/mips_ksyms.c
--- a/arch/mips/kernel/mips_ksyms.c	Wed Oct 16 01:52:19 2002
+++ b/arch/mips/kernel/mips_ksyms.c	Wed Oct 16 01:52:19 2002
@@ -79,9 +79,6 @@
 EXPORT_SYMBOL_NOVERS(__strnlen_user_asm);
 
 
-/* Networking helper routines. */
-EXPORT_SYMBOL(csum_partial_copy);
-
 /*
  * Functions to control caches.
  */
diff -Nru a/arch/mips/lib/csum_partial_copy.c b/arch/mips/lib/csum_partial_copy.c
--- a/arch/mips/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
+++ b/arch/mips/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
@@ -25,8 +25,8 @@
 /*
  * copy while checksumming, otherwise like csum_partial
  */
-unsigned int csum_partial_copy(const char *src, char *dst, 
-                               int len, unsigned int sum)
+unsigned int csum_partial_copy_nocheck(const char *src, char *dst, 
+				       int len, unsigned int sum)
 {
 	/*
 	 * It's 2:30 am and I don't feel like doing it real ...
diff -Nru a/arch/mips64/kernel/mips64_ksyms.c b/arch/mips64/kernel/mips64_ksyms.c
--- a/arch/mips64/kernel/mips64_ksyms.c	Wed Oct 16 01:52:19 2002
+++ b/arch/mips64/kernel/mips64_ksyms.c	Wed Oct 16 01:52:19 2002
@@ -75,9 +75,6 @@
 EXPORT_SYMBOL_NOVERS(__strnlen_user_asm);
 
 
-/* Networking helper routines. */
-EXPORT_SYMBOL(csum_partial_copy);
-
 /*
  * Functions to control caches.
  */
diff -Nru a/arch/mips64/lib/csum_partial_copy.c b/arch/mips64/lib/csum_partial_copy.c
--- a/arch/mips64/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
+++ b/arch/mips64/lib/csum_partial_copy.c	Wed Oct 16 01:52:19 2002
@@ -16,8 +16,8 @@
 /*
  * copy while checksumming, otherwise like csum_partial
  */
-unsigned int csum_partial_copy(const char *src, char *dst, 
-                               int len, unsigned int sum)
+unsigned int csum_partial_copy_nocheck(const char *src, char *dst, 
+				       int len, unsigned int sum)
 {
 	/*
 	 * It's 2:30 am and I don't feel like doing it real ...
diff -Nru a/arch/parisc/lib/checksum.c b/arch/parisc/lib/checksum.c
--- a/arch/parisc/lib/checksum.c	Wed Oct 16 01:52:19 2002
+++ b/arch/parisc/lib/checksum.c	Wed Oct 16 01:52:19 2002
@@ -97,8 +97,8 @@
 /*
  * copy while checksumming, otherwise like csum_partial
  */
-unsigned int csum_partial_copy(const char *src, char *dst, 
-                               int len, unsigned int sum)
+unsigned int csum_partial_copy_nocheck(const char *src, char *dst, 
+				       int len, unsigned int sum)
 {
 	/*
 	 * It's 2:30 am and I don't feel like doing it real ...
diff -Nru a/arch/sh/kernel/sh_ksyms.c b/arch/sh/kernel/sh_ksyms.c
--- a/arch/sh/kernel/sh_ksyms.c	Wed Oct 16 01:52:19 2002
+++ b/arch/sh/kernel/sh_ksyms.c	Wed Oct 16 01:52:19 2002
@@ -36,9 +36,6 @@
 EXPORT_SYMBOL(irq_desc);
 EXPORT_SYMBOL(no_irq_type);
 
-/* Networking helper routines. */
-EXPORT_SYMBOL(csum_partial_copy);
-
 EXPORT_SYMBOL(strpbrk);
 EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(strlen);
diff -Nru a/include/asm-alpha/checksum.h b/include/asm-alpha/checksum.h
--- a/include/asm-alpha/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-alpha/checksum.h	Wed Oct 16 01:52:19 2002
@@ -42,14 +42,6 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
- *
- * this will go away soon.
- */
-unsigned int csum_partial_copy(const char *src, char *dst, int len, unsigned int sum);
-
-/*
- * this is a new version of the above that records errors it finds in *errp,
- * but continues and zeros the rest of the buffer.
  */
 unsigned int csum_partial_copy_from_user(const char *src, char *dst, int len, unsigned int sum, int *errp);
 
diff -Nru a/include/asm-i386/checksum.h b/include/asm-i386/checksum.h
--- a/include/asm-i386/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-i386/checksum.h	Wed Oct 16 01:52:19 2002
@@ -50,14 +50,6 @@
 }
 
 /*
- * This is the old (and unsafe) way of doing checksums, a warning message will
- * be printed if it is used and an exeption occurs.
- *
- * this function should go away after some time.
- */
-unsigned int csum_partial_copy( const char *src, char *dst, int len, int sum);
-
-/*
  *	This is a version of ip_compute_csum() optimized for IP headers,
  *	which always checksum on 4 octet boundaries.
  *
diff -Nru a/include/asm-ia64/checksum.h b/include/asm-ia64/checksum.h
--- a/include/asm-ia64/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-ia64/checksum.h	Wed Oct 16 01:52:19 2002
@@ -48,15 +48,6 @@
  *
  * Here it is even more important to align src and dst on a 32-bit (or
  * even better 64-bit) boundary.
- *
- * this will go away soon.
- */
-extern unsigned int csum_partial_copy (const char *src, char *dst, int len,
-				       unsigned int sum);
-
-/*
- * This is a new version of the above that records errors it finds in
- * *errp, but continues and zeros the rest of the buffer.
  */
 extern unsigned int csum_partial_copy_from_user (const char *src, char *dst,
 						 int len, unsigned int sum,
diff -Nru a/include/asm-m68k/checksum.h b/include/asm-m68k/checksum.h
--- a/include/asm-m68k/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-m68k/checksum.h	Wed Oct 16 01:52:19 2002
@@ -21,18 +21,6 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
- *
- * this will go away soon.
- */
-
-unsigned int csum_partial_copy(const char *src, char *dst, int len, int sum);
-
-
-/*
- * the same as csum_partial_copy, but copies from user space.
- *
- * here even more important to align src and dst on a 32-bit (or even
- * better 64-bit) boundary
  */
 
 extern unsigned int csum_partial_copy_from_user(const char *src, char *dst,
diff -Nru a/include/asm-mips/checksum.h b/include/asm-mips/checksum.h
--- a/include/asm-mips/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-mips/checksum.h	Wed Oct 16 01:52:19 2002
@@ -28,12 +28,6 @@
  * this is a new version of the above that records errors it finds in *errp,
  * but continues and zeros the rest of the buffer.
  */
-#define csum_partial_copy_nocheck csum_partial_copy
-
-/*
- * this is a new version of the above that records errors it finds in *errp,
- * but continues and zeros the rest of the buffer.
- */
 unsigned int csum_partial_copy_from_user(const char *src, char *dst, int len,
                                          unsigned int sum, int *errp);
 
@@ -58,11 +52,9 @@
 /*
  * the same as csum_partial, but copies from user space (but on MIPS
  * we have just one address space, so this is identical to the above)
- *
- * this is obsolete and will go away.
  */
-unsigned int csum_partial_copy(const char *src, char *dst, int len,
-			       unsigned int sum);
+unsigned int csum_partial_copy_nocheck(const char *src, char *dst, int len,
+				       unsigned int sum);
 
 /*
  *	Fold a partial checksum without adding pseudo headers
diff -Nru a/include/asm-mips64/checksum.h b/include/asm-mips64/checksum.h
--- a/include/asm-mips64/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-mips64/checksum.h	Wed Oct 16 01:52:19 2002
@@ -30,12 +30,6 @@
  * this is a new version of the above that records errors it finds in *errp,
  * but continues and zeros the rest of the buffer.
  */
-#define csum_partial_copy_nocheck csum_partial_copy
-
-/*
- * this is a new version of the above that records errors it finds in *errp,
- * but continues and zeros the rest of the buffer.
- */
 unsigned int csum_partial_copy_from_user(const char *src, char *dst, int len,
                                          unsigned int sum, int *errp);
 
@@ -60,11 +54,9 @@
 /*
  * the same as csum_partial, but copies from user space (but on MIPS
  * we have just one address space, so this is identical to the above)
- *
- * this is obsolete and will go away.
  */
-unsigned int csum_partial_copy(const char *src, char *dst, int len,
-			       unsigned int sum);
+unsigned int csum_partial_copy_nocheck(const char *src, char *dst, int len,
+				       unsigned int sum);
 
 /*
  *	Fold a partial checksum without adding pseudo headers
diff -Nru a/include/asm-parisc/checksum.h b/include/asm-parisc/checksum.h
--- a/include/asm-parisc/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-parisc/checksum.h	Wed Oct 16 01:52:19 2002
@@ -21,30 +21,14 @@
  *
  * here even more important to align src and dst on a 32-bit (or even
  * better 64-bit) boundary
- *
- * this will go away soon.
  */
-extern unsigned int csum_partial_copy(const char *, char *, int, unsigned int);
+extern unsigned int csum_partial_copy_nocheck(const char *, char *, int, unsigned int);
 
 /*
  * this is a new version of the above that records errors it finds in *errp,
  * but continues and zeros the rest of the buffer.
  */
 unsigned int csum_partial_copy_from_user(const char *src, char *dst, int len, unsigned int sum, int *errp);
-
-/*
- *	Note: when you get a NULL pointer exception here this means someone
- *	passed in an incorrect kernel address to one of these functions. 
- *	
- *	If you use these functions directly please don't forget the 
- *	verify_area().
- */
-extern __inline__
-unsigned int csum_partial_copy_nocheck (const char *src, char *dst,
-					int len, int sum)
-{
-	return csum_partial_copy (src, dst, len, sum);
-}
 
 /*
  *	Optimized for IP headers, which always checksum on 4 octet boundaries.
diff -Nru a/include/asm-ppc/checksum.h b/include/asm-ppc/checksum.h
--- a/include/asm-ppc/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-ppc/checksum.h	Wed Oct 16 01:52:19 2002
@@ -38,13 +38,6 @@
 /* FIXME: this needs to be written to really do no check -- Cort */
 #define csum_partial_copy_nocheck(src, dst, len, sum)	\
 	csum_partial_copy_generic((src), (dst), (len), (sum), 0, 0)     
-/*
- * Old version which ignore errors.
- * it will go away soon.
- */
-#define csum_partial_copy(src, dst, len, sum)	\
-	csum_partial_copy_generic((src), (dst), (len), (sum), 0, 0)
-
 
 /*
  * turns a 32-bit partial checksum (e.g. from csum_partial) into a
diff -Nru a/include/asm-ppc64/checksum.h b/include/asm-ppc64/checksum.h
--- a/include/asm-ppc64/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-ppc64/checksum.h	Wed Oct 16 01:52:19 2002
@@ -43,12 +43,7 @@
 /*
  * the same as csum_partial, but copies from src to dst while it
  * checksums
- *
- * csum_partial_copy will go away soon.
  */
-unsigned int csum_partial_copy(const char *src, char *dst, 
-			       int len, unsigned int sum);
-
 extern unsigned int csum_partial_copy_generic(const char *src, char *dst,
 					      int len, unsigned int sum,
 					      int *src_err, int *dst_err);
diff -Nru a/include/asm-s390/checksum.h b/include/asm-s390/checksum.h
--- a/include/asm-s390/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-s390/checksum.h	Wed Oct 16 01:52:19 2002
@@ -62,23 +62,6 @@
 }
 
 /*
- * the same as csum_partial, but copies from src while it
- * checksums
- *
- * here even more important to align src and dst on a 32-bit (or even
- * better 64-bit) boundary
- *
- * this will go away soon.
- */
-
-static inline unsigned int 
-csum_partial_copy(const char *src, char *dst, int len,unsigned int sum)
-{
-	memcpy(dst,src,len);
-        return csum_partial_inline(dst, len, sum);
-}
-
-/*
  * the same as csum_partial_copy, but copies from user space.
  *
  * here even more important to align src and dst on a 32-bit (or even
diff -Nru a/include/asm-s390x/checksum.h b/include/asm-s390x/checksum.h
--- a/include/asm-s390x/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-s390x/checksum.h	Wed Oct 16 01:52:19 2002
@@ -64,23 +64,6 @@
 }
 
 /*
- * the same as csum_partial, but copies from src while it
- * checksums
- *
- * here even more important to align src and dst on a 32-bit (or even
- * better 64-bit) boundary
- *
- * this will go away soon.
- */
-
-static inline unsigned int 
-csum_partial_copy(const char *src, char *dst, int len,unsigned int sum)
-{
-	memcpy(dst,src,len);
-        return csum_partial_inline(dst, len, sum);
-}
-
-/*
  * the same as csum_partial_copy, but copies from user space.
  *
  * here even more important to align src and dst on a 32-bit (or even
diff -Nru a/include/asm-sh/checksum.h b/include/asm-sh/checksum.h
--- a/include/asm-sh/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-sh/checksum.h	Wed Oct 16 01:52:19 2002
@@ -58,14 +58,6 @@
 }
 
 /*
- * This is the old (and unsafe) way of doing checksums, a warning message will
- * be printed if it is used and an exeption occurs.
- *
- * this function should go away after some time.
- */
-unsigned int csum_partial_copy( const char *src, char *dst, int len, int sum);
-
-/*
  *	Fold a partial checksum
  */
 
diff -Nru a/include/asm-sparc/checksum.h b/include/asm-sparc/checksum.h
--- a/include/asm-sparc/checksum.h	Wed Oct 16 01:52:19 2002
+++ b/include/asm-sparc/checksum.h	Wed Oct 16 01:52:19 2002
@@ -40,10 +40,6 @@
  * better 64-bit) boundary
  */
 
-/* FIXME: Remove this macro ASAP */
-#define csum_partial_copy(src, dst, len, sum) \
- 		       csum_partial_copy_nocheck(src,dst,len,sum)
-  
 extern unsigned int __csum_partial_copy_sparc_generic (const char *, char *);
 
 extern __inline__ unsigned int 


ChangeSet@1.858, 2002-10-16 01:51:25-07:00, davem@nuts.ninka.net
  arch/{i386,sh}/lib/Makefile: Kill old-checksum.o

diff -Nru a/arch/i386/lib/Makefile b/arch/i386/lib/Makefile
--- a/arch/i386/lib/Makefile	Wed Oct 16 01:52:21 2002
+++ b/arch/i386/lib/Makefile	Wed Oct 16 01:52:21 2002
@@ -4,7 +4,7 @@
 
 L_TARGET = lib.a
 
-obj-y = checksum.o old-checksum.o delay.o \
+obj-y = checksum.o delay.o \
 	usercopy.o getuser.o \
 	memcpy.o strstr.o
 
diff -Nru a/arch/sh/lib/Makefile b/arch/sh/lib/Makefile
--- a/arch/sh/lib/Makefile	Wed Oct 16 01:52:21 2002
+++ b/arch/sh/lib/Makefile	Wed Oct 16 01:52:21 2002
@@ -3,7 +3,7 @@
 #
 
 L_TARGET = lib.a
-obj-y  = delay.o memcpy.o memset.o memmove.o memchr.o old-checksum.o \
+obj-y  = delay.o memcpy.o memset.o memmove.o memchr.o \
 	 checksum.o strcasecmp.o strlen.o
 
 include $(TOPDIR)/Rules.make




-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
