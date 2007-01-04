From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Please add AM_MAINTAINER_MODE to configure.in
Date: Thu, 4 Jan 2007 14:22:51 +0100
Message-ID: <20070104132251.GA31023@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2SXv-0004tL-Bv
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 05:22:17 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2SXw-0005ml-O1
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 05:22:17 -0800
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1H2SXr-0002m6-3p
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 14:22:13 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1H2SYV-00084o-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jan 2007 14:22:51 +0100
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

Could you please add AM_MAINTAINER_MODE to configure.in? I'd like to set
--enable-maintainer-mode in the Debian packages (to prevent configure and
friends from being regenerated from possibly broken or incompatible autofoo),
but the macro needs to be in place in configure.in (which should probably be
renamed to configure.ac by now?) for the switch to exist.

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
