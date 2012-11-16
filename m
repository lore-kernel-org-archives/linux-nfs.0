Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:64180 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab2KPXML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Nov 2012 18:12:11 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: Reduce stack use in encode_exchange_id()
Date: Fri, 16 Nov 2012 18:12:06 -0500
Message-Id: <1353107526-25460-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

encode_exchange_id() uses more stack space than necessary, giving a compile
time warning. Reduce the size of the static buffer for implementation name.

Signed-off-by: Jim Rees <rees@umich.edu>
Reviewed-by: "Adamson, Dros" <Weston.Adamson@netapp.com>
---
 fs/nfs/nfs4xdr.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 672d9b0..cc2f8a9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -270,6 +270,8 @@ static int nfs4_stat_to_errno(int);
 
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MACHINE_NAME_LEN (64)
+#define IMPL_NAME_LIMIT (sizeof(utsname()->sysname) + sizeof(utsname()->release) + \
+			 sizeof(utsname()->version) + sizeof(utsname()->machine) + 8)
 
 #define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
 				encode_verifier_maxsz + \
@@ -282,7 +284,7 @@ static int nfs4_stat_to_errno(int);
 				1 /* nii_domain */ + \
 				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
 				1 /* nii_name */ + \
-				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
+				XDR_QUADLEN(IMPL_NAME_LIMIT) + \
 				3 /* nii_date */)
 #define decode_exchange_id_maxsz (op_decode_hdr_maxsz + \
 				2 /* eir_clientid */ + \
@@ -1711,7 +1713,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 			       struct compound_hdr *hdr)
 {
 	__be32 *p;
-	char impl_name[NFS4_OPAQUE_LIMIT];
+	char impl_name[IMPL_NAME_LIMIT];
 	int len = 0;
 
 	encode_op_hdr(xdr, OP_EXCHANGE_ID, decode_exchange_id_maxsz, hdr);
@@ -1726,7 +1728,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
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

