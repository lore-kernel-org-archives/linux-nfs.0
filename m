From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 18] svcrpc: share code duplicated between auth_unix and auth_null
Date: Tue, 16 Nov 2004 15:50:49 +1100
Message-ID: <E1CTvIn-0004pW-OO@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF0-0005rQ-Sd
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:54 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvEx-0007H0-VQ
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



Call a helper function from svcauth_unix_accept() and svcauth_null_accept()
instead of duplicating code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |   88 ++++++++++++++++++--------------------------
 1 files changed, 36 insertions(+), 52 deletions(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-11-16 14:41:17.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2004-11-16 14:41:18.000000000 +1100
@@ -329,6 +329,38 @@ void svcauth_unix_purge(void)
 	cache_purge(&auth_domain_cache);
 }
 
+int
+svcauth_unix_set_client(struct svc_rqst *rqstp)
+{
+	struct ip_map key, *ipm;
+
+	rqstp->rq_client = NULL;
+	if (rqstp->rq_proc == 0)
+		return SVC_OK;
+
+	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
+	key.m_addr = rqstp->rq_addr.sin_addr;
+
+	ipm = ip_map_lookup(&key, 0);
+
+	if (ipm == NULL)
+		return SVC_DENIED;
+
+	switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
+		default:
+			BUG();
+		case -EAGAIN:
+			return SVC_DROP;
+		case -ENOENT:
+			return SVC_DENIED;
+		case 0:
+			rqstp->rq_client = &ipm->m_client->h;
+			cache_get(&rqstp->rq_client->h);
+			ip_map_put(&ipm->h, &ip_map_cache);
+			break;
+	}
+	return SVC_OK;
+}
 
 static int
 svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp)
@@ -337,7 +369,6 @@ svcauth_null_accept(struct svc_rqst *rqs
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
 	int		rv=0;
-	struct ip_map key, *ipm;
 
 	cred->cr_group_info = NULL;
 	rqstp->rq_client = NULL;
@@ -363,30 +394,8 @@ svcauth_null_accept(struct svc_rqst *rqs
 	if (cred->cr_group_info == NULL)
 		return SVC_DROP; /* kmalloc failure - client must retry */
 
-	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
-	key.m_addr = rqstp->rq_addr.sin_addr;
-
-	ipm = ip_map_lookup(&key, 0);
-
-	if (ipm)
-		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
-		case -EAGAIN:
-			rv = SVC_DROP;
-			break;
-		case -ENOENT:
-			rv = SVC_OK; /* rq_client is NULL */
-			break;
-		case 0:
-			rqstp->rq_client = &ipm->m_client->h;
-			cache_get(&rqstp->rq_client->h);
-			ip_map_put(&ipm->h, &ip_map_cache);
-			rv = SVC_OK;
-			break;
-		default: BUG();
-		}
-	else rv = SVC_DROP;
-
-	if (rv == SVC_OK && rqstp->rq_client == NULL && rqstp->rq_proc != 0)
+	rv = svcauth_unix_set_client(rqstp);
+	if (rv == SVC_DENIED)
 		goto badcred;
 
 	/* Put NULL verifier */
@@ -432,7 +441,6 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	u32		slen, i;
 	int		len   = argv->iov_len;
 	int		rv=0;
-	struct ip_map key, *ipm;
 
 	cred->cr_group_info = NULL;
 	rqstp->rq_client = NULL;
@@ -464,32 +472,8 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		return SVC_DENIED;
 	}
 
-
-	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
-	key.m_addr = rqstp->rq_addr.sin_addr;
-
-
-	ipm = ip_map_lookup(&key, 0);
-
-	if (ipm)
-		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
-		case -EAGAIN:
-			rv = SVC_DROP;
-			break;
-		case -ENOENT:
-			rv = SVC_OK; /* rq_client is NULL */
-			break;
-		case 0:
-			rqstp->rq_client = &ipm->m_client->h;
-			cache_get(&rqstp->rq_client->h);
-			ip_map_put(&ipm->h, &ip_map_cache);
-			rv = SVC_OK;
-			break;
-		default: BUG();
-		}
-	else rv = SVC_DROP;
-
-	if (rv  == SVC_OK && rqstp->rq_client == NULL && rqstp->rq_proc != 0)
+	rv = svcauth_unix_set_client(rqstp);
+	if (rv == SVC_DENIED)
 		goto badcred;
 
 	/* Put NULL verifier */


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
