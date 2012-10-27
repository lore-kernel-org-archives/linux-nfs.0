Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:60724 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933342Ab2J0DGm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 23:06:42 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Reduce stack use in encode_exchange_id()
Date: Fri, 26 Oct 2012 23:06:35 -0400
Message-Id: <1351307195-4197-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For comment only. I have not tested this.

encode_exchange_id() uses more stack space than necessary, giving a compile
time warning. Reduce the size of the static buffer for implementation name.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/nfs4xdr.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8dba6bd..ccd1dde 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1700,12 +1700,15 @@ static void encode_bind_conn_to_session(struct xdr_stream *xdr,
 	*p = 0;	/* use_conn_in_rdma_mode = False */
 }
 
+#define IMPL_NAME_LIMIT (sizeof(utsname()->sysname) + sizeof(utsname()->release) + \
+			 sizeof(utsname()->version) + sizeof(utsname()->machine) + 8)
+
 static void encode_exchange_id(struct xdr_stream *xdr,
 			       struct nfs41_exchange_id_args *args,
 			       struct compound_hdr *hdr)
 {
 	__be32 *p;
-	char impl_name[NFS4_OPAQUE_LIMIT];
+	char impl_name[IMPL_NAME_LIMIT];
 	int len = 0;
 
 	encode_op_hdr(xdr, OP_EXCHANGE_ID, decode_exchange_id_maxsz, hdr);
@@ -1720,7 +1723,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	if (send_implementation_id &&
 	    sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN) > 1 &&
 	    sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN)
-		<= NFS4_OPAQUE_LIMIT + 1)
+		<= sizeof(impl_name) + 1)
 		len = snprintf(impl_name, sizeof(impl_name), "%s %s %s %s",
 			       utsname()->sysname, utsname()->release,
 			       utsname()->version, utsname()->machine);
-- 
1.7.9.5

