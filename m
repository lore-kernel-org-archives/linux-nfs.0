Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35552 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbcFGXfT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 19:35:19 -0400
Received: by mail-pf0-f182.google.com with SMTP id c2so9624628pfa.2
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2016 16:35:19 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC 2/2] nfsd: Encode a netaddr correctly
Date: Tue,  7 Jun 2016 16:34:46 -0700
Message-Id: <1465342486-21750-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
References: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfsd/flexfilelayout.c    | 26 ++------------------------
 fs/nfsd/flexfilelayoutxdr.c | 34 ++++++++++++++--------------------
 fs/nfsd/flexfilelayoutxdr.h | 15 +--------------
 include/linux/nfs4_ff.h     |  4 ++++
 4 files changed, 21 insertions(+), 58 deletions(-)

diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index df880e9..9ba4d4f 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -11,6 +11,7 @@
 #include <linux/nfsd/debug.h>
 
 #include <linux/sunrpc/addr.h>
+#include <linux/nfs4_ff.h>
 
 #include "flexfilelayoutxdr.h"
 #include "pnfs.h"
@@ -81,9 +82,6 @@ nfsd4_ff_proc_getdeviceinfo(struct super_block *sb, struct svc_rqst *rqstp,
 {
 	struct pnfs_ff_device_addr *da;
 
-	u16 port;
-	char addr[INET6_ADDRSTRLEN];
-
 	da = kzalloc(sizeof(struct pnfs_ff_device_addr), GFP_KERNEL);
 	if (!da)
 		return nfserrno(-ENOMEM);
@@ -96,27 +94,7 @@ nfsd4_ff_proc_getdeviceinfo(struct super_block *sb, struct svc_rqst *rqstp,
 	da->rsize = svc_max_payload(rqstp);
 	da->wsize = da->rsize;
 
-	rpc_ntop((struct sockaddr *)&rqstp->rq_daddr,
-		 addr, INET6_ADDRSTRLEN);
-	if (rqstp->rq_daddr.ss_family == AF_INET) {
-		struct sockaddr_in *sin;
-
-		sin = (struct sockaddr_in *)&rqstp->rq_daddr;
-		port = ntohs(sin->sin_port);
-		snprintf(da->netaddr.netid, FF_NETID_LEN + 1, "tcp");
-		da->netaddr.netid_len = 3;
-	} else {
-		struct sockaddr_in6 *sin6;
-
-		sin6 = (struct sockaddr_in6 *)&rqstp->rq_daddr;
-		port = ntohs(sin6->sin6_port);
-		snprintf(da->netaddr.netid, FF_NETID_LEN + 1, "tcp6");
-		da->netaddr.netid_len = 4;
-	}
-
-	da->netaddr.addr_len =
-		snprintf(da->netaddr.addr, FF_ADDR_LEN + 1,
-			 "%s.%hhu.%hhu", addr, port >> 8, port & 0xff);
+	memcpy(&da->daddr, &rqstp->rq_daddr, rqstp->rq_daddrlen);
 
 	da->tightly_coupled = false;
 
diff --git a/fs/nfsd/flexfilelayoutxdr.c b/fs/nfsd/flexfilelayoutxdr.c
index a241f29..83a1a56 100644
--- a/fs/nfsd/flexfilelayoutxdr.c
+++ b/fs/nfsd/flexfilelayoutxdr.c
@@ -3,6 +3,7 @@
  */
 #include <linux/sunrpc/svc.h>
 #include <linux/nfs4.h>
+#include <linux/nfs4_ff.h>
 
 #include "nfsd.h"
 #include "flexfilelayoutxdr.h"
@@ -79,37 +80,30 @@ nfsd4_ff_encode_getdeviceinfo(struct xdr_stream *xdr,
 		struct nfsd4_getdeviceinfo *gdp)
 {
 	struct pnfs_ff_device_addr *da = gdp->gd_device;
-	int len;
-	int ver_len;
-	int addr_len;
-	__be32 *p;
-
-	/* len + padding for two strings */
-	addr_len = 16 + da->netaddr.netid_len + da->netaddr.addr_len;
-	ver_len = 20;
+	__be32 *p, *start;
 
-	len = 4 + ver_len + 4 + addr_len;
+	start = xdr_reserve_space(xdr, 4);
+	if (!start)
+		return nfserr_resource;
 
-	p = xdr_reserve_space(xdr, len + sizeof(__be32));
+	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		return nfserr_resource;
 
-	/*
-	 * Fill in the overall length and number of volumes at the beginning
-	 * of the layout.
-	 */
-	*p++ = cpu_to_be32(len);
-	*p++ = cpu_to_be32(1);			/* 1 netaddr */
-	p = xdr_encode_opaque(p, da->netaddr.netid, da->netaddr.netid_len);
-	p = xdr_encode_opaque(p, da->netaddr.addr, da->netaddr.addr_len);
-
-	*p++ = cpu_to_be32(1);			/* 1 versions */
+	/* We only send 1 netaddr */
+	*p++ = cpu_to_be32(1);
+	nfs4_encode_netaddr(xdr, (struct sockaddr *)&da->daddr);
 
+	/* We only send 1 version */
+	p = xdr_reserve_space(xdr, 24);
+	*p++ = cpu_to_be32(1);
 	*p++ = cpu_to_be32(da->version);
 	*p++ = cpu_to_be32(da->minor_version);
 	*p++ = cpu_to_be32(da->rsize);
 	*p++ = cpu_to_be32(da->wsize);
 	*p++ = cpu_to_be32(da->tightly_coupled);
 
+	*start = cpu_to_be32((xdr->p - start - 1) * 4);
+
 	return 0;
 }
diff --git a/fs/nfsd/flexfilelayoutxdr.h b/fs/nfsd/flexfilelayoutxdr.h
index 467defd..1fe2bb8 100644
--- a/fs/nfsd/flexfilelayoutxdr.h
+++ b/fs/nfsd/flexfilelayoutxdr.h
@@ -7,23 +7,10 @@
 #include <linux/inet.h>
 #include "xdr4.h"
 
-#define FF_FLAGS_NO_LAYOUTCOMMIT 1
-#define FF_FLAGS_NO_IO_THRU_MDS  2
-#define FF_FLAGS_NO_READ_IO      4
-
 struct xdr_stream;
 
-#define FF_NETID_LEN		(4)
-#define FF_ADDR_LEN		(INET6_ADDRSTRLEN + 8)
-struct pnfs_ff_netaddr {
-	char				netid[FF_NETID_LEN + 1];
-	char				addr[FF_ADDR_LEN + 1];
-	u32				netid_len;
-	u32				addr_len;
-};
-
 struct pnfs_ff_device_addr {
-	struct pnfs_ff_netaddr		netaddr;
+	struct sockaddr_storage		daddr;
 	u32				version;
 	u32				minor_version;
 	u32				rsize;
diff --git a/include/linux/nfs4_ff.h b/include/linux/nfs4_ff.h
index 869eb1a..634fbfa1 100644
--- a/include/linux/nfs4_ff.h
+++ b/include/linux/nfs4_ff.h
@@ -1,6 +1,10 @@
 #ifndef _LINUX_NFS4_FF_H
 #define _LINUX_NFS4_FF_H
 
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/auth.h>
+#include <linux/sunrpc/clnt.h>
+
 /* Flex file layout hints on I/O */
 #define FF_FLAGS_NO_LAYOUTCOMMIT	1
 #define FF_FLAGS_NO_IO_THRU_MDS		2
-- 
2.5.5

