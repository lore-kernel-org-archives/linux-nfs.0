From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 056/112] NFS: Ensure NFSv4 SETCLIENTID send buffer is large
	enough
Date: Fri, 25 Jan 2008 11:37:42 -0500
Message-ID: <20080125163741.31887.55309.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbYAYRCE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:04 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0WPZ020490
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:49 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Ensure that the RPC buffer size specified for NFSv4 SETCLIENTID procedures
matches what we are encoding into the buffer.  See the definition of
struct nfs4_setclientid {} and the encode_setclientid() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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
index 6b213a6..d8e395d 100644
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
