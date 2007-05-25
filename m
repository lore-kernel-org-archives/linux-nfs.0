From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] NFS: Fix up compiler warnings in super.c
Date: Fri, 25 May 2007 17:41:15 -0400
Message-ID: <20070525214115.28668.91905.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhXH-0003yZ-7F
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:23 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhXK-0003zd-2B
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:26 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ca20d3c..79a07b5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -263,11 +263,11 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
 		{ RPC_AUTH_GSS_SPKM, "spkm" },
 		{ RPC_AUTH_GSS_SPKMI, "spkmi" },
 		{ RPC_AUTH_GSS_SPKMP, "spkmp" },
-		{ -1, "unknown" }
+		{ UINT_MAX, "unknown" }
 	};
 	int i;
 
-	for (i=0; sec_flavours[i].flavour != -1; i++) {
+	for (i = 0; sec_flavours[i].flavour != UINT_MAX; i++) {
 		if (sec_flavours[i].flavour == flavour)
 			break;
 	}
@@ -355,7 +355,9 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 	int i, cpu;
 	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
 	struct rpc_auth *auth = nfss->client->cl_auth;
-	struct nfs_iostats totals = { };
+	struct nfs_iostats totals;
+
+	memset(&totals, 0, sizeof(struct nfs_iostats));
 
 	seq_printf(m, "statvers=%s", NFS_IOSTAT_VERS);
 
@@ -772,7 +774,7 @@ static void nfs4_fill_super(struct super_block *sb)
 	nfs_initialise_sb(sb);
 }
 
-static void *nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
+static void *nfs_copy_user_string(char *dst, struct nfs_string *src, size_t maxlen)
 {
 	void *p = NULL;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
