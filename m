From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] Fix mountd memory leak in nfsd_fh
Date: Thu, 6 Sep 2007 13:29:56 -0400
Message-ID: <200709061729.l86HTuee015462@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITLB2-0007Mp-7Y
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 10:30:01 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITLB6-0000Mz-C8
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 10:30:04 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l86HTvKJ028292
	for <nfs@lists.sourceforge.net>; Thu, 6 Sep 2007 13:29:57 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l86HTv3k010372
	for <nfs@lists.sourceforge.net>; Thu, 6 Sep 2007 13:29:57 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l86HTuf3001483
	for <nfs@lists.sourceforge.net>; Thu, 6 Sep 2007 13:29:56 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id l86HTuLS015463
	for <nfs@lists.sourceforge.net>; Thu, 6 Sep 2007 13:29:56 -0400
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

nfsd_fh() uses strdup for creating found_path and doesn't check the
return value. It also doesn't free this memory when the function
returns. Check the return value of strdup and return immediately
if it's NULL. Also, free found_path on exit.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 15100d4..fedc0bf 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -445,6 +445,8 @@ void nfsd_fh(FILE *f)
 			if (!found) {
 				found = &exp->m_export;
 				found_path = strdup(path);
+				if (found_path == NULL)
+					goto out;
 			} else if (strcmp(found->e_path, exp->m_export.e_path)!= 0)
 			{
 				xlog(L_WARNING, "%s and %s have same filehandle for %s, using first",
@@ -492,6 +494,7 @@ void nfsd_fh(FILE *f)
 		qword_print(f, found->e_path);
 	qword_eol(f);
  out:
+	free(found_path);
 	free(dom);
 	return;		
 }
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
