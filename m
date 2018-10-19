Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f194.google.com ([209.85.222.194]:34558 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726860AbeJSXfx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:35:53 -0400
Received: by mail-qk1-f194.google.com with SMTP id p6-v6so21260959qkg.1
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:17 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 06/13] NFSD fill-in netloc4 structure
Date: Fri, 19 Oct 2018 11:28:58 -0400
Message-Id: <20181019152905.32418-7-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

nfs.4 defines nfs42_netaddr structure that represents netloc4.

Populate needed fields from the sockaddr structure.

This will be used by flexfiles and 4.2 inter copy

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfsd.h | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 0668999..030fccb 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -18,7 +18,7 @@
 #include <linux/nfs4.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/msg_prot.h>
-
+#include <linux/sunrpc/addr.h>
 #include <uapi/linux/nfsd/debug.h>
 
 #include "stats.h"
@@ -366,6 +366,35 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 
 extern const u32 nfsd_suppattrs[3][3];
 
+static inline u32 nfsd4_set_netaddr(struct sockaddr *addr, struct nfs42_netaddr *netaddr)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)addr;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
+	unsigned int port;
+	size_t ret;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		port = ntohs(sin->sin_port);
+		sprintf(netaddr->netid, "tcp");
+		netaddr->netid_len = 3;
+		break;
+	case AF_INET6:
+		port = ntohs(sin6->sin6_port);
+		sprintf(netaddr->netid, "tcp6");
+		netaddr->netid_len = 4;
+		break;
+	default:
+		return nfserrno(-EINVAL);
+	}
+	ret = rpc_ntop(addr, netaddr->addr, sizeof(netaddr->addr));
+	netaddr->addr_len = ret + snprintf(netaddr->addr + ret,
+				     RPCBIND_MAXUADDRLEN + 1,
+				     ".%u.%u", port >> 8, port & 0xff);
+
+	return 0;
+}
+
 static inline bool bmval_is_subset(const u32 *bm1, const u32 *bm2)
 {
 	return !((bm1[0] & ~bm2[0]) ||
-- 
1.8.3.1
