From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 007 of 11] knfsd: add svc_get
Date: Tue, 25 Jul 2006 15:13:26 +1000
Message-ID: <1153804406.21040.17.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5FEZ-0003iR-C1
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:13:31 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5FEZ-0007JS-JB
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:13:31 -0700
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

knfsd: add svc_get() for those occasions when we need to temporarily
bump up svc_serv->sv_nrthreads as a pseudo refcount.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfssvc.c           |    2 +-
 include/linux/sunrpc/svc.h |   11 +++++++++++
 net/sunrpc/svc.c           |    2 +-
 3 files changed, 13 insertions(+), 2 deletions(-)

Index: linus-git/include/linux/sunrpc/svc.h
===================================================================
--- linus-git.orig/include/linux/sunrpc/svc.h	2006-07-24 20:45:16.151613263 +1000
+++ linus-git/include/linux/sunrpc/svc.h	2006-07-24 20:54:04.638635111 +1000
@@ -65,6 +65,17 @@ struct svc_serv {
 };
 
 /*
+ * We use sv_nrthreads as a reference count.  svc_destroy() drops
+ * this refcount, so we need to bump it up around operations that
+ * change the number of threads.  Horrible, but there it is.
+ * Should be called with the BKL held.
+ */
+static inline void svc_get(struct svc_serv *serv)
+{
+	serv->sv_nrthreads++;
+}
+
+/*
  * Maximum payload size supported by a kernel RPC server.
  * This is use to determine the max number of pages nfsd is
  * willing to return in a single READ operation.
Index: linus-git/fs/nfsd/nfssvc.c
===================================================================
--- linus-git.orig/fs/nfsd/nfssvc.c	2006-07-24 20:43:39.268278026 +1000
+++ linus-git/fs/nfsd/nfssvc.c	2006-07-24 20:54:04.790615277 +1000
@@ -211,7 +211,7 @@ nfsd_svc(unsigned short port, int nrserv
 #endif
 		do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	} else
-		nfsd_serv->sv_nrthreads++;
+		svc_get(nfsd_serv);
 	nrservs -= (nfsd_serv->sv_nrthreads-1);
 	while (nrservs > 0) {
 		nrservs--;
Index: linus-git/net/sunrpc/svc.c
===================================================================
--- linus-git.orig/net/sunrpc/svc.c	2006-07-24 20:48:07.629229576 +1000
+++ linus-git/net/sunrpc/svc.c	2006-07-24 20:54:04.874604317 +1000
@@ -88,7 +88,7 @@ svc_create(struct svc_program *prog, uns
 }
 
 /*
- * Destroy an RPC service
+ * Destroy an RPC service.  Should be called with the BKL held
  */
 void
 svc_destroy(struct svc_serv *serv)

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
