From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Fix umount.nfs exit status
Date: Sat, 14 Jul 2007 11:18:48 +0200
Message-ID: <20070714091848.GA23409@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9dm7-0000Fh-Kd
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 02:18:51 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9dmA-0002bU-1B
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 02:18:55 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1I9dm4-00087y-U5
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 11:18:49 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1I9dm4-000662-00
	for <nfs@lists.sourceforge.net>; Sat, 14 Jul 2007 11:18:48 +0200
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

As per a bug report from a user:

mount.c seems to assume that nfsumount() uses standard C true/false
return values, and inverts them for the exit status (where 0 is
traditionally considered success). However, nfsumount() consistently
seems to use 0 for success, and thus a success gets returned as exit
status 1 and a failure as exit status 0. This confuses at least
the GNOME drive manager applet, and probably others as well.

Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

Index: nfs-utils-1.1.0/utils/mount/mount.c
===================================================================
--- nfs-utils-1.1.0.orig/utils/mount/mount.c
+++ nfs-utils-1.1.0/utils/mount/mount.c
@@ -371,7 +371,7 @@ int main(int argc, char *argv[])
                        umount_usage();
                        exit(1);
                }
-               exit(nfsumount(argc, argv) ? 0 : 1);
+               exit(nfsumount(argc, argv));
        }

        if(argv[1] && argv[1][0] == '-') {

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
