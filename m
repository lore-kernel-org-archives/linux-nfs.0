From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Manpage inconsistency
Date: Thu, 4 Jan 2007 14:10:46 +0100
Message-ID: <20070104131046.GA30920@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2SMG-0003hD-5B
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 05:10:12 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2SMG-0000UZ-G2
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 05:10:13 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1H2SMB-00020H-5y
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 14:10:07 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1H2SMo-000835-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jan 2007 14:10:46 +0100
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

Hi,

It seems like the man page for rpc.statd claims that it lives in /sbin.
However, make install puts it in /usr/sbin. Which should be corrected? :-)

(It should be mentioned that in Debian, we move both rpc.statd, rpc.lockd and
showmount into /sbin, since we might need them at boot time and patch the
manpages appropriately, but at least upstream should be consistent with
itself.)

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
