From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/25] NFS: Ensure NFSv4 SETCLIENTID send buffer is
	large	enough
Date: Tue, 13 Nov 2007 13:31:11 -0500
Message-ID: <20071113183110.5087.22164.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Xz-0000NL-1P
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:39 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Y4-0005PZ-Qg
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:45 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Ensure that the RPC buffer size specified for NFSv4 SETCLIENTID procedures
matches what we are encoding into the buffer.  See the definition of
struct nfs4_setclientid {} and the encode_setclientid() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c        |   10 ++++++----
 include/linux/nfs_xdr.h |   13 +++++++------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index eae46f0..93e8ebf 100644
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
+				XDR_QUADLEN(48) /* sc_name */ + \
+				1 /* sc_prog */ + \
+				XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
+				XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
+				1 /* sc_cb_ident */ )
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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
