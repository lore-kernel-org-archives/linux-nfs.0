From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 002 of 3] knfsd: Remove an unused variable from
	e_show()
Date: Thu, 06 Jul 2006 15:17:41 +1000
Message-ID: <1152163061.18333.364.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyMFH-0007kK-FS
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 22:17:47 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyMFH-0007W7-JD
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 22:17:47 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: Remove an unused variable from e_show().

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/export.c |    2 --
 1 files changed, 2 deletions(-)

Index: linus-git/fs/nfsd/export.c
===================================================================
--- linus-git.orig/fs/nfsd/export.c	2006-07-06 12:17:25.500087628 +1000
+++ linus-git/fs/nfsd/export.c	2006-07-06 12:47:49.949013131 +1000
@@ -1178,7 +1178,6 @@ static int e_show(struct seq_file *m, vo
 {
 	struct cache_head *cp = p;
 	struct svc_export *exp = container_of(cp, struct svc_export, h);
-	svc_client *clp;
 
 	if (p == (void *)1) {
 		seq_puts(m, "# Version 1.1\n");
@@ -1186,7 +1185,6 @@ static int e_show(struct seq_file *m, vo
 		return 0;
 	}
 
-	clp = exp->ex_client;
 	cache_get(&exp->h);
 	if (cache_check(&svc_export_cache, &exp->h, NULL))
 		return 0;


Greg
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
