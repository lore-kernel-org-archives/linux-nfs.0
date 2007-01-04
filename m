From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: [PATCH] fix rpc.gssd -d
Date: Thu, 4 Jan 2007 20:46:25 +0100
Message-ID: <20070104194625.GA3000@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2YXB-0004Xj-Cm
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 11:45:53 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2YX7-0000uM-Ob
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 11:45:55 -0800
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1H2YX1-0005hr-U5
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 20:45:44 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1H2YXh-0000n3-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jan 2007 20:46:25 +0100
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

Fix an off-by-one in the handling of the -d option to rpc.gssd; this makes
the option usable again (it would complain that the string was too long).
This patch is originally by Liam Bedford, and extracted from

  https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/76409

--- nfs-utils-1.0.10.orig/utils/gssd/gssd.c
+++ nfs-utils-1.0.10/utils/gssd/gssd.c
@@ -118,7 +118,7 @@ main(int argc, char *argv[])
                                break;
                        case 'd':
                                strncpy(ccachedir, optarg, sizeof(ccachedir));
-                               if (ccachedir[sizeof(ccachedir-1)] != '\0')
+                               if (ccachedir[sizeof(ccachedir)-1] != '\0')
                                        errx(1, "ccachedir path name too long");
                                break;
                        default:

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
