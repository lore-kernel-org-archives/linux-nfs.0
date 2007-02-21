From: wolfgang@noten5.maas-noten.de
Subject: mount problems - possibly 64bit
Date: 21 Feb 2007 11:38:27 -0000
Message-ID: <wolfgang-1070221123827.A0217144@noten5.maas-noten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJpoO-0007fk-3i
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 03:39:04 -0800
Received: from maas-noten.de ([213.239.193.103])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HJpoO-0004kq-Kh
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 03:39:06 -0800
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



I am trying to replace servers in an existing network by better ones (kernel 2.6.16 on amd 64bit)
The server has nfs-server-2.2beta51-225.x86_64.rpm installed

Trying to mount from an old (32bit) client ends with
mount: wrong fs type, bad option, bad superblock on server:/data
The server reports: /data has been mounted by 192.168.75.31
Trying to mount from a new system (2.6.16 running on a Pentium D) the result is
mount: cannot mount server:/data read-only
Again the server says that the mount was successful

Wolfgang




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
