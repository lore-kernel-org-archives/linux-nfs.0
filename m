From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2 of 6] svcrpc: share code duplicated between auth_unix and auth_null
Date: Thu, 16 Sep 2004 19:16:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095375544.839c1c96.2@fieldses.org>
References: <1095375544.839c1c96.1@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85UH-00010t-K1
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:25 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C85UG-0002h4-Un
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:25 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1095375544.839c1c96.1@fieldses.org>
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
---

 linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c |   89 +++++++++-------------
 1 files changed, 37 insertions(+), 52 deletions(-)

diff -puN net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_cleanup net/sunrpc/svcauth_unix.c
--- linux-2.6.9-rc2/net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_cleanup	2004-09-16 16:40:49.000000000 -0400
+++ linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c	2004-09-16 16:40:49.000000000 -0400
@@ -329,6 +329,39 @@ void svcauth_unix_purge(void)
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
+		case -EAGAIN:
+			return SVC_DROP;
+		case -ENOENT:
+			return SVC_DENIED;
+		case 0:
+			rqstp->rq_client = &ipm->m_client->h;
+			cache_get(&rqstp->rq_client->h);
+			ip_map_put(&ipm->h, &ip_map_cache);
+			return SVC_OK;
+		default:
+			BUG();
+	}
+	/* shut up gcc: */
+	return -1;
+}
 
 static int
 svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp)
@@ -337,7 +370,6 @@ svcauth_null_accept(struct svc_rqst *rqs
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
 	int		rv=0;
-	struct ip_map key, *ipm;
 
 	cred->cr_group_info = NULL;
 	rqstp->rq_client = NULL;
@@ -363,30 +395,8 @@ svcauth_null_accept(struct svc_rqst *rqs
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
@@ -432,7 +442,6 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	u32		slen, i;
 	int		len   = argv->iov_len;
 	int		rv=0;
-	struct ip_map key, *ipm;
 
 	cred->cr_group_info = NULL;
 	rqstp->rq_client = NULL;
@@ -464,32 +473,8 @@ svcauth_unix_accept(struct svc_rqst *rqs
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
_


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
