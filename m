From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] mountd: fix memory leak in nfsd_fh
Date: Fri, 17 Aug 2007 21:51:58 -0400
Message-ID: <20070817215158.17c470fa.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IMDTx-0006Vr-Dw
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 18:52:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IMDU1-0003K5-Gz
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 18:52:09 -0700
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

This should apply cleanly on top of the "use_ipaddr" patch that I recently
posted:

---------------------

nfsd_fh() uses strdup and doesn't check the return value. It also doesn't
free this memory when the function returns. Change it to use xstrdup,
and free found_path on exit.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mountd/cache.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 25248b8..c582f67 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -462,7 +462,7 @@ void nfsd_fh(FILE *f)
 			/* It's a match !! */
 			if (!found) {
 				found = &exp->m_export;
-				found_path = strdup(path);
+				found_path = xstrdup(path);
 			} else if (strcmp(found->e_path, exp->m_export.e_path)!= 0)
 			{
 				xlog(L_WARNING, "%s and %s have same filehandle for %s, using first",
@@ -510,9 +510,10 @@ void nfsd_fh(FILE *f)
 		qword_print(f, found->e_path);
 	qword_eol(f);
  out:
-	if (he)
-		free(he);
+	if (he) free(he);
+	if (found_path) free(found_path);
 	free(dom);
+	
 	return;		
 }
 
-- 
1.5.2.2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
