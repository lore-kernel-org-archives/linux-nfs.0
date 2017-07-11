Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:20210 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934043AbdGKQoe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:34 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 16/42] NFS NFSD defining nl4_servers structure needed by both
Date: Tue, 11 Jul 2017 12:43:50 -0400
Message-ID: <20170711164416.1982-17-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These structures are needed by COPY_NOTIFY on the client and needed
by the nfsd as well

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 include/linux/nfs4.h | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7262908..4179c78 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -15,6 +15,7 @@
 #include <linux/list.h>
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
+#include <linux/sunrpc/msg_prot.h>
 
 enum nfs4_acl_whotype {
 	NFS4_ACL_WHO_NAMED = 0,
@@ -659,4 +660,36 @@ struct nfs4_op_map {
 	} u;
 };
 
+struct nfs42_netaddr {
+	unsigned int	na_netid_len;
+	char		na_netid[RPCBIND_MAXNETIDLEN + 1];
+	unsigned int	na_uaddr_len;
+	char		na_uaddr[RPCBIND_MAXUADDRLEN + 1];
+};
+
+enum netloc_type4 {
+	NL4_NAME		= 1,
+	NL4_URL			= 2,
+	NL4_NETADDR		= 3,
+};
+
+struct nl4_server {
+	enum netloc_type4	nl4_type;
+	union {
+		struct { /* NL4_NAME, NL4_URL */
+			int	nl4_str_sz;
+			char	nl4_str[NFS4_OPAQUE_LIMIT + 1];
+		};
+		struct nfs42_netaddr	nl4_addr; /* NL4_NETADDR */
+	} u;
+};
+
+/*  support 1 nl4_server for now */
+#define NFS42_MAX_SSC_SRC       1
+
+struct nl4_servers {
+	int			nl_nsvr;
+	struct nl4_server	*nl_svr;
+};
+
 #endif
-- 
1.8.3.1

