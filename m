From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/25] SUNRPC: Move universal address definitions to
	global	header
Date: Tue, 13 Nov 2007 13:31:05 -0500
Message-ID: <20071113183105.5087.38644.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Yu-0000WM-5z
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:36 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Yz-0005JE-RD
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:42 -0800
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

Universal addresses are defined in RFC 1833 and clarified in RFC 3530.  We
need to use them in several places in the NFS and RPC clients, so move the
relevant definition and block comment to an appropriate global include
file.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/msg_prot.h |   39 ++++++++++++++++++++++++++++++++++
 net/sunrpc/rpcb_clnt.c          |   45 +++------------------------------------
 2 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index c4beb57..70df4f1 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -152,5 +152,44 @@ typedef __be32	rpc_fraghdr;
  */
 #define RPCBIND_MAXNETIDLEN	(4u)
 
+/*
+ * Universal addresses are introduced in RFC 1833 and further spelled
+ * out in RFC 3530.  RPCBIND_MAXUADDRLEN defines a maximum byte length
+ * of a universal address for use in allocating buffers and character
+ * arrays.
+ *
+ * Quoting RFC 3530, section 2.2:
+ *
+ * For TCP over IPv4 and for UDP over IPv4, the format of r_addr is the
+ * US-ASCII string:
+ *
+ *	h1.h2.h3.h4.p1.p2
+ *
+ * The prefix, "h1.h2.h3.h4", is the standard textual form for
+ * representing an IPv4 address, which is always four octets long.
+ * Assuming big-endian ordering, h1, h2, h3, and h4, are respectively,
+ * the first through fourth octets each converted to ASCII-decimal.
+ * Assuming big-endian ordering, p1 and p2 are, respectively, the first
+ * and second octets each converted to ASCII-decimal.  For example, if a
+ * host, in big-endian order, has an address of 0x0A010307 and there is
+ * a service listening on, in big endian order, port 0x020F (decimal
+ * 527), then the complete universal address is "10.1.3.7.2.15".
+ *
+ * ...
+ *
+ * For TCP over IPv6 and for UDP over IPv6, the format of r_addr is the
+ * US-ASCII string:
+ *
+ *	x1:x2:x3:x4:x5:x6:x7:x8.p1.p2
+ *
+ * The suffix "p1.p2" is the service port, and is computed the same way
+ * as with universal addresses for TCP and UDP over IPv4.  The prefix,
+ * "x1:x2:x3:x4:x5:x6:x7:x8", is the standard textual form for
+ * representing an IPv6 address as defined in Section 2.2 of [RFC2373].
+ * Additionally, the two alternative forms specified in Section 2.2 of
+ * [RFC2373] are also acceptable.
+ */
+#define RPCBIND_MAXUADDRLEN	(56u)
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a05493a..593d1ad 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -55,45 +55,6 @@ enum {
 #define RPCB_HIGHPROC_4		RPCBPROC_GETSTAT
 
 /*
- * r_addr
- *
- * Quoting RFC 3530, section 2.2:
- *
- * For TCP over IPv4 and for UDP over IPv4, the format of r_addr is the
- * US-ASCII string:
- *
- *	h1.h2.h3.h4.p1.p2
- *
- * The prefix, "h1.h2.h3.h4", is the standard textual form for
- * representing an IPv4 address, which is always four octets long.
- * Assuming big-endian ordering, h1, h2, h3, and h4, are respectively,
- * the first through fourth octets each converted to ASCII-decimal.
- * Assuming big-endian ordering, p1 and p2 are, respectively, the first
- * and second octets each converted to ASCII-decimal.  For example, if a
- * host, in big-endian order, has an address of 0x0A010307 and there is
- * a service listening on, in big endian order, port 0x020F (decimal
- * 527), then the complete universal address is "10.1.3.7.2.15".
- *
- * ...
- *
- * For TCP over IPv6 and for UDP over IPv6, the format of r_addr is the
- * US-ASCII string:
- *
- *	x1:x2:x3:x4:x5:x6:x7:x8.p1.p2
- *
- * The suffix "p1.p2" is the service port, and is computed the same way
- * as with universal addresses for TCP and UDP over IPv4.  The prefix,
- * "x1:x2:x3:x4:x5:x6:x7:x8", is the standard textual form for
- * representing an IPv6 address as defined in Section 2.2 of [RFC2373].
- * Additionally, the two alternative forms specified in Section 2.2 of
- * [RFC2373] are also acceptable.
- *
- * XXX: Currently this implementation does not explicitly convert the
- *      stored address to US-ASCII on non-ASCII systems.
- */
-#define RPCB_MAXADDRLEN		(128u)
-
-/*
  * r_owner
  *
  * The "owner" is allowed to unset a service in the rpcbind database.
@@ -113,7 +74,7 @@ struct rpcbind_args {
 	u32			r_prot;
 	unsigned short		r_port;
 	char *			r_netid;
-	char			r_addr[RPCB_MAXADDRLEN];
+	char			r_addr[RPCBIND_MAXUADDRLEN];
 	char *			r_owner;
 };
 
@@ -518,7 +479,7 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
 	 * Simple sanity check.  The smallest possible universal
 	 * address is an IPv4 address string containing 11 bytes.
 	 */
-	if (addr_len < 11 || addr_len > RPCB_MAXADDRLEN)
+	if (addr_len < 11 || addr_len > RPCBIND_MAXUADDRLEN)
 		goto out_err;
 
 	/*
@@ -569,7 +530,7 @@ out_err:
 #define RPCB_boolean_sz		(1u)
 
 #define RPCB_netid_sz		(1+XDR_QUADLEN(RPCBIND_MAXNETIDLEN))
-#define RPCB_addr_sz		(1+XDR_QUADLEN(RPCB_MAXADDRLEN))
+#define RPCB_addr_sz		(1+XDR_QUADLEN(RPCBIND_MAXUADDRLEN))
 #define RPCB_ownerstring_sz	(1+XDR_QUADLEN(RPCB_MAXOWNERLEN))
 
 #define RPCB_mappingargs_sz	RPCB_program_sz+RPCB_version_sz+	\


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
