From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Address buffer overrun in rpc_uaddr2sockaddr()
Date: Wed, 11 Nov 2009 13:22:59 -0500
Message-ID: <20091111182117.3206.6594.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45728
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758378AbZKKSXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 13:23:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The size of buf[] must account for the string termination needed for
the first strict_strtoul() call.

=46=C3=A1bio Oliv=C3=A9 Leite points out that strict_strtoul() requires=
 _either_
'\n\0' _or_ '\0' termination, so use the simpler '\0' here instead.

See http://bugzilla.kernel.org/show_bug.cgi?id=3D14546 .

Reported-by: argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: F=C3=A1bio Oliv=C3=A9 Leite <fleite@redhat.com>
---

Would you please test this fix to see if it addresses the problem?

 net/sunrpc/addr.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 22e8fd8..c7450c8 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -306,24 +306,25 @@ EXPORT_SYMBOL_GPL(rpc_sockaddr2uaddr);
  * @sap: buffer into which to plant socket address
  * @salen: size of buffer
  *
+ * @uaddr does not have to be '\0'-terminated, but strict_strtoul() an=
d
+ * rpc_pton() require proper string termination to be successful.
+ *
  * Returns the size of the socket address if successful; otherwise
  * zero is returned.
  */
 size_t rpc_uaddr2sockaddr(const char *uaddr, const size_t uaddr_len,
 			  struct sockaddr *sap, const size_t salen)
 {
-	char *c, buf[RPCBIND_MAXUADDRLEN];
+	char *c, buf[RPCBIND_MAXUADDRLEN + sizeof('\0')];
 	unsigned long portlo, porthi;
 	unsigned short port;
=20
-	if (uaddr_len > sizeof(buf))
+	if (uaddr_len > RPCBIND_MAXUADDRLEN)
 		return 0;
=20
 	memcpy(buf, uaddr, uaddr_len);
=20
-	buf[uaddr_len] =3D '\n';
-	buf[uaddr_len + 1] =3D '\0';
-
+	buf[uaddr_len] =3D '\0';
 	c =3D strrchr(buf, '.');
 	if (unlikely(c =3D=3D NULL))
 		return 0;
@@ -332,9 +333,7 @@ size_t rpc_uaddr2sockaddr(const char *uaddr, const =
size_t uaddr_len,
 	if (unlikely(portlo > 255))
 		return 0;
=20
-	c[0] =3D '\n';
-	c[1] =3D '\0';
-
+	*c =3D '\0';
 	c =3D strrchr(buf, '.');
 	if (unlikely(c =3D=3D NULL))
 		return 0;
@@ -345,8 +344,7 @@ size_t rpc_uaddr2sockaddr(const char *uaddr, const =
size_t uaddr_len,
=20
 	port =3D (unsigned short)((porthi << 8) | portlo);
=20
-	c[0] =3D '\0';
-
+	*c =3D '\0';
 	if (rpc_pton(buf, strlen(buf), sap, salen) =3D=3D 0)
 		return 0;
=20

