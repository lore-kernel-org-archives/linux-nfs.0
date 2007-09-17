From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] mountd: fix memory leak and error handling in
	nfsd_fh
Date: Mon, 17 Sep 2007 08:51:54 -0400
Message-ID: <200709171251.l8HCpsXU025375@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXG5B-00016S-QQ
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 05:52:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXG5G-0003Ty-Cp
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 05:52:14 -0700
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
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
