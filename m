From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 5 of 6] lockd: don't try to match callback requests against export table
Date: Thu, 16 Sep 2004 19:16:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095375544.839c1c96.5@fieldses.org>
References: <1095375544.839c1c96.4@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85UX-00014M-0O
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:41 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C85UW-0006iH-FB
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:40 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1095375544.839c1c96.4@fieldses.org>
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


On lockd callbacks, we're a client, and the source address is that of a server,
so we shouldn't be trying to match the source address of the callback request
against our export table.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.9-rc2-bfields/fs/lockd/svc.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff -puN fs/lockd/svc.c~lockd_fix_authentication fs/lockd/svc.c
--- linux-2.6.9-rc2/fs/lockd/svc.c~lockd_fix_authentication	2004-09-16 16:23:55.000000000 -0400
+++ linux-2.6.9-rc2-bfields/fs/lockd/svc.c	2004-09-16 16:23:55.000000000 -0400
@@ -398,12 +398,29 @@ static int param_set_##name(const char *
 	return 0;							\
 }
 
+static inline int is_callback(u32 proc)
+{
+	/* XXX: correct list?  Add field to proc? */
+	/* XXX: SMPROC_NOTIFY may be a special case. */
+	/* XXX: double-check: make sure the procedure numbers make sense
+	 * across all nlm versions.  Check NOTIFY in particular. */
+	return proc == NLMPROC_GRANTED
+		|| proc == NLMPROC_TEST_RES
+		|| proc == NLMPROC_LOCK_RES
+		|| proc == NLMPROC_CANCEL_RES
+		|| proc == NLMPROC_UNLOCK_RES
+		|| proc == NLMPROC_GRANTED_RES;
+}
+
 static int lockd_set_client(struct svc_rqst *rqstp)
 {
 	rqstp->rq_client = NULL;
-	if (rqstp->rq_proc == 0) /* XXX not quite right. */
+	if (is_callback(rqstp->rq_proc)) {
+		/* XXX: how do I authenticate callbacks?
+		 * Call nlmsvc_lookup_host(rqstp), or just leave that
+		 * to the individual procedures? */
 		return SVC_OK;
-	else
+	} else
 		return svcauth_unix_set_client(rqstp);
 }
 
_


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
