From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 6 of 6] nfsd: remove pg_authenticate field
Date: Thu, 16 Sep 2004 19:16:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095375544.839c1c96.6@fieldses.org>
References: <1095375544.839c1c96.5@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85Ub-00015Y-S7
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:45 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C85Ub-0006im-6v
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:45 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1095375544.839c1c96.5@fieldses.org>
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


The pg_authenticate callback was only being used by the nfs4 client callback
code to circumvent the svcauth_unix code's insistence on checking all requests
against the export table.  With that problem solved, we no longer need
pg_authenticate.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.9-rc2-bfields/include/linux/sunrpc/svc.h |    1 -
 linux-2.6.9-rc2-bfields/net/sunrpc/svc.c           |    5 +----
 2 files changed, 1 insertion(+), 5 deletions(-)

diff -puN net/sunrpc/svc.c~nfsd_remove_pg_authenticate net/sunrpc/svc.c
--- linux-2.6.9-rc2/net/sunrpc/svc.c~nfsd_remove_pg_authenticate	2004-09-16 16:29:22.000000000 -0400
+++ linux-2.6.9-rc2-bfields/net/sunrpc/svc.c	2004-09-16 16:29:22.000000000 -0400
@@ -311,10 +311,7 @@ svc_process(struct svc_serv *serv, struc
 	 * We do this before anything else in order to get a decent
 	 * auth verifier.
 	 */
-	if (progp->pg_authenticate != NULL)
-		auth_res = progp->pg_authenticate(rqstp, &auth_stat);
-	else
-		auth_res = svc_authenticate(rqstp, &auth_stat);
+	auth_res = svc_authenticate(rqstp, &auth_stat);
 	switch (auth_res) {
 	case SVC_OK:
 		break;
diff -puN include/linux/sunrpc/svc.h~nfsd_remove_pg_authenticate include/linux/sunrpc/svc.h
--- linux-2.6.9-rc2/include/linux/sunrpc/svc.h~nfsd_remove_pg_authenticate	2004-09-16 16:29:22.000000000 -0400
+++ linux-2.6.9-rc2-bfields/include/linux/sunrpc/svc.h	2004-09-16 16:29:22.000000000 -0400
@@ -252,7 +252,6 @@ struct svc_program {
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
 	/* Override authentication. NULL means use default */
-	int			(*pg_authenticate)(struct svc_rqst *, u32 *);
 	int			(*pg_set_client)(struct svc_rqst *);
 };
 
_


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
