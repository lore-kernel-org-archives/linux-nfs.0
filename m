From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 11] knfsd: add svc_get
Date: Mon, 31 Jul 2006 10:42:19 +1000
Message-ID: <1060731004219.29255@suse.de>
References: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7LrV-0003tl-1g
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:25 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7LrV-00076P-1b
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:25 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd: add svc_get() for those occasions when we need to temporarily
bump up svc_serv->sv_nrthreads as a pseudo refcount.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c           |    2 +-
 ./include/linux/sunrpc/svc.h |   11 +++++++++++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-28 15:01:38.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-31 10:20:49.000000000 +1000
@@ -200,7 +200,7 @@ int nfsd_create_serv(void)
 	int err = 0;
 	lock_kernel();
 	if (nfsd_serv) {
-		nfsd_serv->sv_nrthreads++;
+		svc_get(nfsd_serv);
 		unlock_kernel();
 		return 0;
 	}

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-07-31 10:14:54.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2006-07-31 10:20:49.000000000 +1000
@@ -71,6 +71,17 @@ struct svc_serv {
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

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
