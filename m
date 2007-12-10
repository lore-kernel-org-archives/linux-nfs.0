From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/27] NFS: Ensure NFSv4 SETCLIENTID send buffer is large
	enough
Date: Mon, 10 Dec 2007 14:56:54 -0500
Message-ID: <20071210195654.2823.4985.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:39761 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127AbXLJUEs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:48 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the RPC buffer size specified for NFSv4 SETCLIENTID procedures
matches what we are encoding into the buffer.  See the definition of
struct nfs4_setclientid {} and the encode_setclientid() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c        |   10 ++++++----
 include/linux/nfs_xdr.h |   13 +++++++------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index eae46f0..db1ed9c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -116,10 +116,12 @@ static int nfs4_stat_to_errno(int);
 #define decode_renew_maxsz	(op_decode_hdr_maxsz)
 #define encode_setclientid_maxsz \
 				(op_encode_hdr_maxsz + \
-				4 /*server->ip_addr*/ + \
-				1 /*Netid*/ + \
-				6 /*uaddr*/ + \
-				6 + (NFS4_VERIFIER_SIZE >> 2))
+				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
+				XDR_QUADLEN(NFS4_SETCLIENTID_NAMELEN) + \
+				1 /* sc_prog */ + \
+				XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
+				XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
+				1) /* sc_cb_ident */
 #define decode_setclientid_maxsz \
 				(op_decode_hdr_maxsz + \
 				2 + \
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 58751f3..d740dfa 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -666,16 +666,17 @@ struct nfs4_rename_res {
 	struct nfs_fattr *		new_fattr;
 };
 
+#define NFS4_SETCLIENTID_NAMELEN	(48)
 struct nfs4_setclientid {
-	const nfs4_verifier *		sc_verifier;      /* request */
+	const nfs4_verifier *		sc_verifier;
 	unsigned int			sc_name_len;
-	char				sc_name[48];	  /* request */
-	u32				sc_prog;          /* request */
+	char				sc_name[NFS4_SETCLIENTID_NAMELEN];
+	u32				sc_prog;
 	unsigned int			sc_netid_len;
-	char				sc_netid[4];	  /* request */
+	char				sc_netid[RPCBIND_MAXNETIDLEN];
 	unsigned int			sc_uaddr_len;
-	char				sc_uaddr[24];     /* request */
-	u32				sc_cb_ident;      /* request */
+	char				sc_uaddr[RPCBIND_MAXUADDRLEN];
+	u32				sc_cb_ident;
 };
 
 struct nfs4_statfs_arg {

