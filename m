From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 18] svcrpc: auth_null fixes
Date: Tue, 16 Nov 2004 15:50:49 +1100
Message-ID: <E1CTvIn-0004pS-MS@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF0-0005rJ-D9
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:54 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvEx-0007Gv-VP
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:54 -0800
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



Fix some discrepencies between the server-side auth_null and auth_unix rpc
code: in particular, make sure we return an auth error in the auth_null case
instead of dropping when we fail to match an export entry, and make sure such
responses are encoded correctly.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-11-16 14:41:06.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2004-11-16 14:41:17.000000000 +1100
@@ -335,9 +335,13 @@ svcauth_null_accept(struct svc_rqst *rqs
 {
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
+	struct svc_cred	*cred = &rqstp->rq_cred;
 	int		rv=0;
 	struct ip_map key, *ipm;
 
+	cred->cr_group_info = NULL;
+	rqstp->rq_client = NULL;
+
 	if (argv->iov_len < 3*4)
 		return SVC_GARBAGE;
 
@@ -353,23 +357,17 @@ svcauth_null_accept(struct svc_rqst *rqs
 	}
 
 	/* Signal that mapping to nobody uid/gid is required */
-	rqstp->rq_cred.cr_uid = (uid_t) -1;
-	rqstp->rq_cred.cr_gid = (gid_t) -1;
-	rqstp->rq_cred.cr_group_info = groups_alloc(0);
-	if (rqstp->rq_cred.cr_group_info == NULL)
+	cred->cr_uid = (uid_t) -1;
+	cred->cr_gid = (gid_t) -1;
+	cred->cr_group_info = groups_alloc(0);
+	if (cred->cr_group_info == NULL)
 		return SVC_DROP; /* kmalloc failure - client must retry */
 
-	/* Put NULL verifier */
-	svc_putu32(resv, RPC_AUTH_NULL);
-	svc_putu32(resv, 0);
-
 	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
 	ipm = ip_map_lookup(&key, 0);
 
-	rqstp->rq_client = NULL;
-
 	if (ipm)
 		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
 		case -EAGAIN:
@@ -388,10 +386,18 @@ svcauth_null_accept(struct svc_rqst *rqs
 		}
 	else rv = SVC_DROP;
 
-	if (rqstp->rq_client == NULL && rqstp->rq_proc != 0)
-		*authp = rpc_autherr_badcred;
+	if (rv == SVC_OK && rqstp->rq_client == NULL && rqstp->rq_proc != 0)
+		goto badcred;
+
+	/* Put NULL verifier */
+	svc_putu32(resv, RPC_AUTH_NULL);
+	svc_putu32(resv, 0);
 
 	return rv;
+
+badcred:
+	*authp = rpc_autherr_badcred;
+	return SVC_DENIED;
 }
 
 static int


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
