From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd in 2.5.14 - Two small changes to nfsd/nfssvc.c
Date: Tue, 7 May 2002 14:38:36 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15575.23116.412039.37510@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174wko-0004c7-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 21:39:10 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 7 May 2002 14:39:00 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



1/ Return correct error code if nfs server creation fails
2/ Increase limit on number of nfsd threads

   There is no real justification for stopping a sysadmin
   from running lots and lots of nfsd threads, so we raise the
   imposed limit from 128 to 8192... maybe it should just go away...


 ----------- Diffstat output ------------
 ./fs/nfsd/nfssvc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

--- ./fs/nfsd/nfssvc.c	2002/05/07 04:26:48	1.1
+++ ./fs/nfsd/nfssvc.c	2002/05/07 04:27:49	1.2
@@ -67,7 +67,7 @@
 /*
  * Maximum number of nfsd processes
  */
-#define	NFSD_MAXSERVS		128
+#define	NFSD_MAXSERVS		8192
 
 int
 nfsd_svc(unsigned short port, int nrservs)
@@ -90,6 +90,7 @@
 		goto out;
 	if (!nfsd_serv) {
 		atomic_set(&nfsd_busy, 0);
+		error = -ENOMEM;
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE, NFSSVC_XDRSIZE);
 		if (nfsd_serv == NULL)
 			goto out;

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
