From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Please remove getkversion
Date: Thu, 4 Jan 2007 14:45:05 +0100
Message-ID: <20070104134504.GA31206@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2StS-0006z1-3V
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 05:44:30 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2StR-0003Sa-FX
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 05:44:31 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1H2StN-0004I2-35
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 14:44:25 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1H2Su1-00087f-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jan 2007 14:45:05 +0100
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

getkversion fails when building against newer kernel headers, since
UTS_RELEASE is no longer exported to userspace (nor is there any adequate
replacement that I know of). This has already hit Ubuntu (making nfs-utils
not build anymore), so they've simply stopped building it -- we're doing so
in Debian as well, as we'll probably hit the same problems, and getkversion
isn't really in use anyhow.

Could we simply remove the tool from upstream git? Is there any known use
for it?

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
