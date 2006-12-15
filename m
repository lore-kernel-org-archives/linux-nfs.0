From: Alan Feltz <alanf@quasar.phsx.ku.edu>
Subject: nfs-utils-1.0.10: Incorrect macro call argument in nfsd.c
Date: Fri, 15 Dec 2006 10:39:50 -0600
Message-ID: <4582cfd6.2gzodu+zmJqH3EJD%alanf@quasar.phsx.ku.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvG6f-0004es-HW
	for nfs@lists.sourceforge.net; Fri, 15 Dec 2006 08:40:21 -0800
Received: from quasar.phsx.ku.edu ([129.237.97.163])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GvG6e-0006wL-Q5
	for nfs@lists.sourceforge.net; Fri, 15 Dec 2006 08:40:23 -0800
Received: from quasar.phsx.ku.edu (localhost [127.0.0.1])
	by quasar.phsx.ku.edu (8.13.1/8.13.1) with ESMTP id kBFGdoUT019473
	for <nfs@lists.sourceforge.net>; Fri, 15 Dec 2006 10:39:50 -0600
Received: (from alanf@localhost)
	by quasar.phsx.ku.edu (8.13.1/8.13.1/Submit) id kBFGdoO3019472
	for nfs@lists.sourceforge.net; Fri, 15 Dec 2006 10:39:50 -0600
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


Hello,

In one of the sanity checks in nfsd.c, the macro  NFSCTL_TCPISSET  is
being called with an incorrect argument.  The current argument is
versbits .  It should be protobits .

Patch is below.


--- nfs-utils-1.0.10/utils/nfsd/nfsd.c.orig     2006-12-14 21:56:48.000000000 -0600
+++ nfs-utils-1.0.10/utils/nfsd/nfsd.c  2006-12-14 21:57:56.000000000 -0600
@@ -118,7 +118,7 @@ main(int argc, char **argv)
                fprintf(stderr, "no version specified\n");
                exit(1);
        }
-       if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(versbits)) {
+       if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
                fprintf(stderr, "version 4 requires the TCP protocol\n");
                exit(1);
        }


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
