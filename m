From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] Fix mountd memory leak in nfsd_fh
Date: Mon, 27 Aug 2007 11:21:35 -0400
Message-ID: <200708271521.l7RFLZJN019407@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPgPM-0003U3-Cv
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 08:21:40 -0700
Received: from mx2.redhat.com ([66.187.237.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IPgPP-0002qb-MK
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 08:21:44 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx2.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFLbOD007852
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:37 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFLaX5016416
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:36 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFLaRY010232
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:36 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id l7RFLZNS019408
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:36 -0400
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
returns. Change it to use xstrdup, and free found_path on exit.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 15100d4..77fee01 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -444,7 +444,7 @@ void nfsd_fh(FILE *f)
 			/* It's a match !! */
 			if (!found) {
 				found = &exp->m_export;
-				found_path = strdup(path);
+				found_path = xstrdup(path);
 			} else if (strcmp(found->e_path, exp->m_export.e_path)!= 0)
 			{
 				xlog(L_WARNING, "%s and %s have same filehandle for %s, using first",
@@ -492,6 +492,8 @@ void nfsd_fh(FILE *f)
 		qword_print(f, found->e_path);
 	qword_eol(f);
  out:
+	if (found_path)
+		free(found_path);
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
