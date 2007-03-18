From: Albert Hopkins <marduk@letterboxes.org>
Subject: rpc.mountd memory leak?
Date: Sun, 18 Mar 2007 15:10:57 -0500
Message-ID: <1174248657.21998.6.camel@blackwidow.nbk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT1iV-00014t-Ei
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 13:10:59 -0700
Received: from out5.smtp.messagingengine.com ([66.111.4.29])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HT1iW-0000uO-Bo
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 13:11:01 -0700
Received: from out1.internal (unknown [10.202.2.149])
	by out1.messagingengine.com (Postfix) with ESMTP id B2EE6208099
	for <nfs@lists.sourceforge.net>; Sun, 18 Mar 2007 16:10:57 -0400 (EDT)
Received: from [192.168.31.10] (cpe-76-185-203-114.tx.res.rr.com
	[76.185.203.114])
	by www.fastmail.fm (Postfix) with ESMTP id 1717E2AA88
	for <nfs@lists.sourceforge.net>; Sun, 18 Mar 2007 16:10:59 -0400 (EDT)
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

I am using 1.0.12 of nfs-utils (linux/x86).  I have a problem in that
after a while rpc.mountd starts to eat up gobs of memory (sometimes >
1GB) and usually I am required to stop/restart NFS services to regain
memory.  I do not have many exported filesystems and very few clients
have anything mounted at a given time, so I'm not sure why it would need
as much memory so I'm guessing it's some kind of leak.  Please let me
know what I can do to debug this situation.

thanks
--
Albert W. Hopkins


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
