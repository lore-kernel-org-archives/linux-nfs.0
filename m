From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 5 of 6] lockd: don't try to match callback requests against export table
Date: Tue, 18 Jan 2005 13:06:35 -0500
Message-ID: <1106070956.b175e53d.5@fieldses.org>
References: <1106070956.b175e53d.4@fieldses.org>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CqxkH-0003lU-ML
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 10:06:25 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CqxkG-00068n-8Q
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 10:06:25 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1106070956.b175e53d.4@fieldses.org>
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


On lockd callbacks, we're a client, and the source address is that of a server,
so we shouldn't be trying to match the source address of the callback request
against our export table.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.10-rc3-bfields/fs/lockd/svc.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+)

diff -puN fs/lockd/svc.c~lockd_fix_authentication fs/lockd/svc.c
--- linux-2.6.10-rc3/fs/lockd/svc.c~lockd_fix_authentication	2004-12-08 15:12:13.000000000 -0500
+++ linux-2.6.10-rc3-bfields/fs/lockd/svc.c	2004-12-09 14:46:46.000000000 -0500
@@ -403,6 +403,18 @@ static int param_set_##name(const char *
 	return 0;							\
 }
 
+static inline int is_callback(u32 proc)
+{
+	return proc == NLMPROC_GRANTED
+		|| proc == NLMPROC_GRANTED_MSG
+		|| proc == NLMPROC_TEST_RES
+		|| proc == NLMPROC_LOCK_RES
+		|| proc == NLMPROC_CANCEL_RES
+		|| proc == NLMPROC_UNLOCK_RES
+		|| proc == NLMPROC_NSM_NOTIFY;
+}
+
+
 static int lockd_authenticate(struct svc_rqst *rqstp)
 {
 	rqstp->rq_client = NULL;
@@ -411,6 +423,12 @@ static int lockd_authenticate(struct svc
 		case RPC_AUTH_UNIX:
 			if (rqstp->rq_proc == 0)
 				return SVC_OK;
+			if (is_callback(rqstp->rq_proc)) {
+				/* Leave it to individual procedures to
+				 * call nlmsvc_lookup_host(rqstp)
+				 */
+				return SVC_OK;
+			}
 			return svc_set_client(rqstp);
 	}
 	return SVC_DENIED;
_


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
