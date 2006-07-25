From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 9] knfsd: Separate out some parts of nfsd_svc,
	which start nfs servers.
Date: Tue, 25 Jul 2006 11:54:57 +1000
Message-ID: <1060725015457.21981@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C94-0004d5-Vz
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:39 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C94-0005cb-Uw
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:39 -0700
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


Separate out the code for creating a new service, and for creating
initial sockets.

Some of these new functions will have multiple callers soon.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |   82 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 57 insertions(+), 25 deletions(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-24 15:17:36.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-24 15:20:39.000000000 +1000
@@ -195,6 +195,53 @@ void nfsd_reset_versions(void)
 	}
 }
 
+
+static inline int nfsd_create_serv(void)
+{
+	int err = 0;
+	lock_kernel();
+	if (nfsd_serv) {
+		nfsd_serv->sv_nrthreads++;
+		unlock_kernel();
+		return 0;
+	}
+
+	atomic_set(&nfsd_busy, 0);
+	nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE,
+			       nfsd_last_thread);
+	if (nfsd_serv == NULL)
+		err = -ENOMEM;
+	else
+		nfsd_serv->sv_nrthreads++;
+	unlock_kernel();
+	do_gettimeofday(&nfssvc_boot);		/* record boot time */
+	return err;
+}
+
+static inline int nfsd_init_socks(int port)
+{
+	int error;
+	if (!list_empty(&nfsd_serv->sv_permsocks))
+		return 0;
+
+	error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
+	if (error < 0)
+		return error;
+	error = lockd_up(IPPROTO_UDP);
+	if (error < 0)
+		return error;
+
+#ifdef CONFIG_NFSD_TCP
+	error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
+	if (error < 0)
+		return error;
+	error = lockd_up(IPPROTO_TCP);
+	if (error < 0)
+		return error;
+#endif
+	return 0;
+}
+
 int
 nfsd_svc(unsigned short port, int nrservs)
 {
@@ -216,32 +263,17 @@ nfsd_svc(unsigned short port, int nrserv
 	error = nfs4_state_start();
 	if (error<0)
 		goto out;
-	if (!nfsd_serv) {
-		nfsd_reset_versions();
 
-		atomic_set(&nfsd_busy, 0);
-		error = -ENOMEM;
-		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE,
-				       nfsd_last_thread);
-		if (nfsd_serv == NULL)
-			goto out;
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
-		if (error < 0)
-			goto failure;
-		error = lockd_up(IPPROTO_UDP);
-		if (error < 0)
-			goto failure;
-#ifdef CONFIG_NFSD_TCP
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
-		if (error < 0)
-			goto failure;
-		error = lockd_up(IPPROTO_TCP);
-		if (error < 0)
-			goto failure;
-#endif
-		do_gettimeofday(&nfssvc_boot);		/* record boot time */
-	} else
-		nfsd_serv->sv_nrthreads++;
+	nfsd_reset_versions();
+
+	error = nfsd_create_serv();
+
+	if (error)
+		goto out;
+	error = nfsd_init_socks(port);
+	if (error)
+		goto failure;
+
 	nrservs -= (nfsd_serv->sv_nrthreads-1);
 	while (nrservs > 0) {
 		nrservs--;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
