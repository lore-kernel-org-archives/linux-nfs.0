From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1 of 6] svcrpc: auth_null fixes
Date: Thu, 16 Sep 2004 19:16:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095375544.839c1c96.1@fieldses.org>
References: <20040916230735.GB13415@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85UF-00010c-1u
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:23 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C85UE-0002gh-Gs
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:22 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <20040916230735.GB13415@fieldses.org>
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
---

 linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c |   30 +++++++++++++---------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff -puN net/sunrpc/svcauth_unix.c~svcrpc_auth_null_fixes net/sunrpc/svcauth_unix.c
--- linux-2.6.9-rc2/net/sunrpc/svcauth_unix.c~svcrpc_auth_null_fixes	2004-09-16 15:40:33.000000000 -0400
+++ linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c	2004-09-16 16:38:26.000000000 -0400
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
_


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
