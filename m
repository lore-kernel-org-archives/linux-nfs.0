From: Jolly Frederic <frederic.jolly@ext.bull.net>
Subject: new admin tool: exportfsvia
Date: Tue, 8 Jun 2004 17:58:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200406081758.44205.frederic.jolly@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXiz0-00078G-Qq
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 08:57:50 -0700
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BXiyz-00062c-06
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 08:57:49 -0700
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id RAA15574
	for <nfs@lists.sourceforge.net>; Tue, 8 Jun 2004 17:58:49 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

we maintain on the Bull NFSv4 web page ( http://nfsv4.bullopensource.org/ )=
 a=20
list of patches and code sources produced.

"exportfsvia" is command line tool for NFSv4: it is a wrapper to "exportfs"=
=20
which makes easier the export of a directory by masking the "mount --bind"=
=20
(it emulates a NFSv3 behaviour.)

Downloads are on this page:
http://nfsv4.bullopensource.org/patches/admin_code.html#exportfsvia

Comments and bug reports are welcome.

Regards,
=46r=E9d=E9ric.


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
