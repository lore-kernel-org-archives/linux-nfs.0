From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 6] knfsd: Separate out some parts of nfsd_svc,
	which start nfs servers.
Date: Mon, 3 Jul 2006 16:19:30 +1000
Message-ID: <1060703061930.7137@suse.de>
References: <20060703161408.7009.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxHmV-0004jT-Lc
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 23:19:39 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxHmT-0003pN-W5
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 23:19:40 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 0E94B1EBDB
	for <nfs@lists.sourceforge.net>; Mon,  3 Jul 2006 08:19:36 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


Sparate out the code for creating a new service, and for creating
initial sockets.

Some of these new functions will have multiple callers soon.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |   79 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 55 insertions(+), 24 deletions(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-03 14:50:11.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-03 15:16:40.000000000 +1000
@@ -195,6 +195,52 @@ void nfsd_reset_versions(void)
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
+	nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE, nfsd_last_thread);
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
@@ -216,31 +262,16 @@ nfsd_svc(unsigned short port, int nrserv
 	error = nfs4_state_start();
 	if (error<0)
 		goto out;
-	if (!nfsd_serv) {
-		nfsd_reset_versions();
 
-		atomic_set(&nfsd_busy, 0);
-		error = -ENOMEM;
-		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE, nfsd_last_thread);
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
+	if (error)
+		goto out;
+	error = nfsd_init_socks(port);
+	if (error)
+		goto failure;
+
 	nrservs -= (nfsd_serv->sv_nrthreads-1);
 	while (nrservs > 0) {
 		nrservs--;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
