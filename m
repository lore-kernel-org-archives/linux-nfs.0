Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34371 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbcFGXfT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 19:35:19 -0400
Received: by mail-pf0-f175.google.com with SMTP id 62so82344970pfd.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2016 16:35:18 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC 1/2] nfs: Encoding a netaddr is common to client and server
Date: Tue,  7 Jun 2016 16:34:45 -0700
Message-Id: <1465342486-21750-2-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
References: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 93 +-------------------------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  5 +-
 include/linux/nfs4_ff.h                | 96 ++++++++++++++++++++++++++++++++++
 3 files changed, 99 insertions(+), 95 deletions(-)
 create mode 100644 include/linux/nfs4_ff.h

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0e8018b..1973aea 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -9,6 +9,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/module.h>
+#include <linux/nfs4_ff.h>
 
 #include <linux/sunrpc/metrics.h>
 
@@ -2024,96 +2025,6 @@ ff_layout_encode_layoutreturn(struct pnfs_layout_hdr *lo,
 	dprintk("%s: Return\n", __func__);
 }
 
-static int
-ff_layout_ntop4(const struct sockaddr *sap, char *buf, const size_t buflen)
-{
-	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-
-	return snprintf(buf, buflen, "%pI4", &sin->sin_addr);
-}
-
-static size_t
-ff_layout_ntop6_noscopeid(const struct sockaddr *sap, char *buf,
-			  const int buflen)
-{
-	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-	const struct in6_addr *addr = &sin6->sin6_addr;
-
-	/*
-	 * RFC 4291, Section 2.2.2
-	 *
-	 * Shorthanded ANY address
-	 */
-	if (ipv6_addr_any(addr))
-		return snprintf(buf, buflen, "::");
-
-	/*
-	 * RFC 4291, Section 2.2.2
-	 *
-	 * Shorthanded loopback address
-	 */
-	if (ipv6_addr_loopback(addr))
-		return snprintf(buf, buflen, "::1");
-
-	/*
-	 * RFC 4291, Section 2.2.3
-	 *
-	 * Special presentation address format for mapped v4
-	 * addresses.
-	 */
-	if (ipv6_addr_v4mapped(addr))
-		return snprintf(buf, buflen, "::ffff:%pI4",
-					&addr->s6_addr32[3]);
-
-	/*
-	 * RFC 4291, Section 2.2.1
-	 */
-	return snprintf(buf, buflen, "%pI6c", addr);
-}
-
-/* Derived from rpc_sockaddr2uaddr */
-static void
-ff_layout_encode_netaddr(struct xdr_stream *xdr, struct nfs4_pnfs_ds_addr *da)
-{
-	struct sockaddr *sap = (struct sockaddr *)&da->da_addr;
-	char portbuf[RPCBIND_MAXUADDRPLEN];
-	char addrbuf[RPCBIND_MAXUADDRLEN];
-	char *netid;
-	unsigned short port;
-	int len, netid_len;
-	__be32 *p;
-
-	switch (sap->sa_family) {
-	case AF_INET:
-		if (ff_layout_ntop4(sap, addrbuf, sizeof(addrbuf)) == 0)
-			return;
-		port = ntohs(((struct sockaddr_in *)sap)->sin_port);
-		netid = "tcp";
-		netid_len = 3;
-		break;
-	case AF_INET6:
-		if (ff_layout_ntop6_noscopeid(sap, addrbuf, sizeof(addrbuf)) == 0)
-			return;
-		port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
-		netid = "tcp6";
-		netid_len = 4;
-		break;
-	default:
-		/* we only support tcp and tcp6 */
-		WARN_ON_ONCE(1);
-		return;
-	}
-
-	snprintf(portbuf, sizeof(portbuf), ".%u.%u", port >> 8, port & 0xff);
-	len = strlcat(addrbuf, portbuf, sizeof(addrbuf));
-
-	p = xdr_reserve_space(xdr, 4 + netid_len);
-	xdr_encode_opaque(p, netid, netid_len);
-
-	p = xdr_reserve_space(xdr, 4 + len);
-	xdr_encode_opaque(p, addrbuf, len);
-}
-
 static void
 ff_layout_encode_nfstime(struct xdr_stream *xdr,
 			 ktime_t t)
@@ -2160,7 +2071,7 @@ ff_layout_encode_layoutstats(struct xdr_stream *xdr,
 	/* layoutupdate length */
 	start = xdr_reserve_space(xdr, 4);
 	/* netaddr4 */
-	ff_layout_encode_netaddr(xdr, da);
+	nfs4_encode_netaddr(xdr, (struct sockaddr *)&da->da_addr);
 	/* nfs_fh4 */
 	p = xdr_reserve_space(xdr, 4 + fh->size);
 	xdr_encode_opaque(p, fh->data, fh->size);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 1bcdb15..d71998e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -9,10 +9,7 @@
 #ifndef FS_NFS_NFS4FLEXFILELAYOUT_H
 #define FS_NFS_NFS4FLEXFILELAYOUT_H
 
-#define FF_FLAGS_NO_LAYOUTCOMMIT 1
-#define FF_FLAGS_NO_IO_THRU_MDS  2
-#define FF_FLAGS_NO_READ_IO      4
-
+#include <linux/nfs4_ff.h>
 #include "../pnfs.h"
 
 /* XXX: Let's filter out insanely large mirror count for now to avoid oom
diff --git a/include/linux/nfs4_ff.h b/include/linux/nfs4_ff.h
new file mode 100644
index 0000000..869eb1a
--- /dev/null
+++ b/include/linux/nfs4_ff.h
@@ -0,0 +1,96 @@
+#ifndef _LINUX_NFS4_FF_H
+#define _LINUX_NFS4_FF_H
+
+/* Flex file layout hints on I/O */
+#define FF_FLAGS_NO_LAYOUTCOMMIT	1
+#define FF_FLAGS_NO_IO_THRU_MDS		2
+#define FF_FLAGS_NO_READ_IO		4
+
+static inline size_t
+nfs4_ntop6_noscopeid(const struct sockaddr *sap, char *buf, const int buflen)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	const struct in6_addr *addr = &sin6->sin6_addr;
+
+	/*
+	 * RFC 4291, Section 2.2.2
+	 *
+	 * Shorthanded ANY address
+	 */
+	if (ipv6_addr_any(addr))
+		return snprintf(buf, buflen, "::");
+
+	/*
+	 * RFC 4291, Section 2.2.2
+	 *
+	 * Shorthanded loopback address
+	 */
+	if (ipv6_addr_loopback(addr))
+		return snprintf(buf, buflen, "::1");
+
+	/*
+	 * RFC 4291, Section 2.2.3
+	 *
+	 * Special presentation address format for mapped v4
+	 * addresses.
+	 */
+	if (ipv6_addr_v4mapped(addr))
+		return snprintf(buf, buflen, "::ffff:%pI4",
+					&addr->s6_addr32[3]);
+
+	/*
+	 * RFC 4291, Section 2.2.1
+	 */
+	return snprintf(buf, buflen, "%pI6c", addr);
+}
+
+static inline int
+nfs4_ntop4(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	return snprintf(buf, buflen, "%pI4", &sin->sin_addr);
+}
+
+/* Derived from rpc_sockaddr2uaddr */
+static inline void
+nfs4_encode_netaddr(struct xdr_stream *xdr, struct sockaddr *sap)
+{
+	char portbuf[RPCBIND_MAXUADDRPLEN];
+	char addrbuf[RPCBIND_MAXUADDRLEN];
+	char *netid;
+	unsigned short port;
+	int len, netid_len;
+	__be32 *p;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (nfs4_ntop4(sap, addrbuf, sizeof(addrbuf)) == 0)
+			return;
+		port = ntohs(((struct sockaddr_in *)sap)->sin_port);
+		netid = "tcp";
+		netid_len = 3;
+		break;
+	case AF_INET6:
+		if (nfs4_ntop6_noscopeid(sap, addrbuf, sizeof(addrbuf)) == 0)
+			return;
+		port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+		netid = "tcp6";
+		netid_len = 4;
+		break;
+	default:
+		/* we only support tcp and tcp6 */
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	snprintf(portbuf, sizeof(portbuf), ".%u.%u", port >> 8, port & 0xff);
+	len = strlcat(addrbuf, portbuf, sizeof(addrbuf));
+
+	p = xdr_reserve_space(xdr, 4 + netid_len);
+	xdr_encode_opaque(p, netid, netid_len);
+
+	p = xdr_reserve_space(xdr, 4 + len);
+	xdr_encode_opaque(p, addrbuf, len);
+}
+#endif
-- 
2.5.5

