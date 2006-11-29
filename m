From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Do not leak memory in is_mountpoint()
Date: Wed, 29 Nov 2006 12:51:03 +0100
Message-ID: <20061129115103.GB18149@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfbrown@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpNy3-0004nL-6G
	for nfs@lists.sourceforge.net; Wed, 29 Nov 2006 03:51:11 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GpNy2-0005th-Ev
	for nfs@lists.sourceforge.net; Wed, 29 Nov 2006 03:51:11 -0800
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id AB616122BC
	for <nfs@lists.sourceforge.net>; Wed, 29 Nov 2006 12:51:03 +0100 (CET)
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


Not sure if this was discussed before. Anyway, I
stumbled across this today.

Cheers,
Olaf
------------------------------------------------------------------
From: Olaf Kirch <okir@suse.de>
Subject: Do not leak memory in is_mountpoint()

Kind of obvious when you look at the code :-)

Signed-off-by: Olaf Kirch <okir@suse.de>

 support/misc/mountpoint.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

Index: nfs-utils-1.0.8/support/misc/mountpoint.c
===================================================================
--- nfs-utils-1.0.8.orig/support/misc/mountpoint.c
+++ nfs-utils-1.0.8/support/misc/mountpoint.c
@@ -20,17 +20,20 @@ is_mountpoint(char *path)
 	 */
 	char *dotdot;
 	struct stat stb, pstb;
+	int rv = 0;
 
 	dotdot = malloc(strlen(path)+4);
 	strcat(strcpy(dotdot, path), "/..");
 	if (lstat(path, &stb) != 0 ||
 	    lstat(dotdot, &pstb) != 0)
-		return 0;
+		goto done;
 
 	if (stb.st_dev != pstb.st_dev
 	    || stb.st_ino == pstb.st_ino)
-		return 1;
-	return 0;
+		rv = 1;
+
+done:	free(dotdot);
+	return rv;
 }
 
 int
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
