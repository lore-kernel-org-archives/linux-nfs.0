From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 6 - Lock client list while detaching locks
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004Ux-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZJ-00027S-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZI-0002Hk-Sm
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:55 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


From: Mark Hemment <markhe@veritas.com>

The 'client' list should always be protected by the export table lock,
but it isn't here!


diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-09-04 11:33:07.000000000 +1000
+++ ./fs/nfsd/export.c	2003-09-04 11:44:35.000000000 +1000
@@ -903,8 +903,10 @@ exp_nlmdetach(void)
 {
 	struct svc_client	*clp;
 
+	exp_readlock();
 	for (clp = clients; clp; clp = clp->cl_next)
 		nfsd_lockd_unexport(clp);
+	exp_unlock();
 }
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
