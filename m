From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 12] nfsd: remove pg_authenticate field
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006Ve-DK@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLis-0006vF-87
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLir-0004G8-Na
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
To: Andrew Morton <akpm@osdl.org>
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



The pg_authenticate (now pg_authenticate_obsolete) callback was only being used
by the nfs4 client callback code to circumvent the svcauth_unix code's
insistence on checking all requests against the export table.  With that
problem solved, we no longer need it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./include/linux/sunrpc/svc.h |    2 --
 ./net/sunrpc/svc.c           |    5 +----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2005-02-07 15:04:35.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2005-02-07 15:05:03.000000000 +1100
@@ -273,8 +273,6 @@ struct svc_program {
 	char *			pg_name;	/* service name */
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
-	/* Override authentication. NULL means use default */
-	int			(*pg_authenticate_obsolete)(struct svc_rqst *, u32 *);
 	int			(*pg_authenticate)(struct svc_rqst *);
 };
 

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2005-02-07 15:04:35.000000000 +1100
+++ ./net/sunrpc/svc.c	2005-02-07 15:05:03.000000000 +1100
@@ -317,10 +317,7 @@ svc_process(struct svc_serv *serv, struc
 	 * We do this before anything else in order to get a decent
 	 * auth verifier.
 	 */
-	if (progp->pg_authenticate_obsolete != NULL)
-		auth_res = progp->pg_authenticate_obsolete(rqstp, &auth_stat);
-	else
-		auth_res = svc_authenticate(rqstp, &auth_stat);
+	auth_res = svc_authenticate(rqstp, &auth_stat);
 	/* Also give the program a chance to reject this call: */
 	if (auth_res == SVC_OK) {
 		auth_stat = rpc_autherr_badcred;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
