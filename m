From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2 of 6] svcrpc: rename pg_authenticate
Date: Thu, 09 Dec 2004 17:28:37 -0500
Message-ID: <1102628809.16c39937.2@fieldses.org>
References: <1102628809.16c39937.1@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWls-0005GT-FN
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:24 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CcWlh-0006Q0-6t
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:24 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1102628809.16c39937.1@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Later patches remove pg_authenticate and use the name for a different purpose;
so rename it to pg_authenticate_obsolete for now.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.10-rc3-bfields/fs/nfs/callback.c          |    2 +-
 linux-2.6.10-rc3-bfields/include/linux/sunrpc/svc.h |    2 +-
 linux-2.6.10-rc3-bfields/net/sunrpc/svc.c           |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff -puN fs/nfs/callback.c~svcrpc_rename_pg_authenticate fs/nfs/callback.c
--- linux-2.6.10-rc3/fs/nfs/callback.c~svcrpc_rename_pg_authenticate	2004-12-08 15:12:10.000000000 -0500
+++ linux-2.6.10-rc3-bfields/fs/nfs/callback.c	2004-12-08 15:12:10.000000000 -0500
@@ -321,5 +321,5 @@ static struct svc_program nfs4_callback_
 	.pg_name = "NFSv4 callback",			/* service name */
 	.pg_class = "nfs",				/* authentication class */
 	.pg_stats = &nfs4_callback_stats,
-	.pg_authenticate = nfs_callback_auth,
+	.pg_authenticate_obsolete = nfs_callback_auth,
 };
diff -puN include/linux/sunrpc/svc.h~svcrpc_rename_pg_authenticate include/linux/sunrpc/svc.h
--- linux-2.6.10-rc3/include/linux/sunrpc/svc.h~svcrpc_rename_pg_authenticate	2004-12-08 15:12:10.000000000 -0500
+++ linux-2.6.10-rc3-bfields/include/linux/sunrpc/svc.h	2004-12-08 15:12:10.000000000 -0500
@@ -252,7 +252,7 @@ struct svc_program {
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
 	/* Override authentication. NULL means use default */
-	int			(*pg_authenticate)(struct svc_rqst *, u32 *);
+	int			(*pg_authenticate_obsolete)(struct svc_rqst *, u32 *);
 };
 
 /*
diff -puN net/sunrpc/svc.c~svcrpc_rename_pg_authenticate net/sunrpc/svc.c
--- linux-2.6.10-rc3/net/sunrpc/svc.c~svcrpc_rename_pg_authenticate	2004-12-08 15:12:10.000000000 -0500
+++ linux-2.6.10-rc3-bfields/net/sunrpc/svc.c	2004-12-08 15:12:10.000000000 -0500
@@ -311,8 +311,8 @@ svc_process(struct svc_serv *serv, struc
 	 * We do this before anything else in order to get a decent
 	 * auth verifier.
 	 */
-	if (progp->pg_authenticate != NULL)
-		auth_res = progp->pg_authenticate(rqstp, &auth_stat);
+	if (progp->pg_authenticate_obsolete != NULL)
+		auth_res = progp->pg_authenticate_obsolete(rqstp, &auth_stat);
 	else
 		auth_res = svc_authenticate(rqstp, &auth_stat);
 	switch (auth_res) {
_


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
