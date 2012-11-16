Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:59593 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753618Ab2KPVbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Nov 2012 16:31:23 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Reduce stack use in encode_exchange_id()
Date: Fri, 16 Nov 2012 16:31:15 -0500
Message-Id: <1353101475-11613-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

encode_exchange_id() uses more stack space than necessary, giving a compile
time warning. Reduce the size of the static buffer for implementation name.

Signed-off-by: Jim Rees <rees@umich.edu>
Reviewed-by: "Adamson, Dros" <Weston.Adamson@netapp.com>
---
 fs/nfs/nfs4xdr.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 672d9b0..e9c101d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1706,12 +1706,15 @@ static void encode_bind_conn_to_session(struct xdr_stream *xdr,
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
@@ -1726,7 +1729,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
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

