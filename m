From: Ian Kent <raven@themaw.net>
Subject: [PATCH] nfs-utils - mtab locking needed on add as well as
	update
Date: Thu, 14 Dec 2006 20:34:52 +0900
Message-ID: <1166096092.3324.8.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuorW-0006ml-8m
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 03:34:54 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuorX-0006WV-IT
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 03:34:55 -0800
Received: from out1.internal (unknown [10.202.2.149])
	by out1.messagingengine.com (Postfix) with ESMTP id BFB2C51334
	for <nfs@lists.sourceforge.net>; Thu, 14 Dec 2006 06:34:54 -0500 (EST)
Received: from [10.49.97.36] (203-59-152-254.dyn.iinet.net.au [203.59.152.254])
	by mail.messagingengine.com (Postfix) with ESMTP id AC7181C7D0
	for <nfs@lists.sourceforge.net>; Thu, 14 Dec 2006 06:34:53 -0500 (EST)
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


Hi all,

I noticed some mtab corruption the other day when doing some autofs
testing but thought nothing of it.

When investigating another issue I came across utils/mount.c:add_mtab
which looks like it adds an entry to /etc/mtab without performing
correct locking. Perhaps this is not needed when adding entries but I
think it is.

Comments please?

---
--- nfs-utils-1.0.9/utils/mount/mount.c.mtab-locking	2006-12-14 20:11:18.000000000 +0900
+++ nfs-utils-1.0.9/utils/mount/mount.c	2006-12-14 20:11:35.000000000 +0900
@@ -149,11 +149,7 @@
 	ment.mnt_freq = 0;
 	ment.mnt_passno= 0;
 
-	if ((fd = open(MOUNTED"~", O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)	{
-		fprintf(stderr, "Can't get "MOUNTED"~ lock file");
-		return 1;
-	}
-        close(fd);
+	lock_mtab();
 
         if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
 		fprintf(stderr, "Can't open " MOUNTED);
@@ -161,21 +157,22 @@
 	}
 
         if (addmntent(mtab, &ment) == 1) {
+		endmntent(mtab);
+		unlock_mtab();
 		fprintf(stderr, "Can't write mount entry");
 		return 1;
 	}
 
         if (fchmod(fileno(mtab), 0644) == -1) {
+		endmntent(mtab);
+		unlock_mtab();
 		fprintf(stderr, "Can't set perms on " MOUNTED);
 		return 1;
 	}
 
 	endmntent(mtab);
 
-	if (unlink(MOUNTED"~") == -1) {
-		fprintf(stderr, "Can't remove "MOUNTED"~");
-		return 1;
-	}
+	unlock_mtab();
 
 	return 0;
 }



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
