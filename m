From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: ANNOUNCE: nfs-utils 1.0.7-pre2
Date: Fri, 10 Dec 2004 12:50:23 +1100
Message-ID: <16825.223.924965.582375@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcZvQ-00069I-LW
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 17:50:28 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcZvP-0001iI-UR
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 17:50:28 -0800
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 10 Dec 2004 12:50:24 +1100
Received: from neilb by notabene.cse.unsw.edu.au with local (Exim 4.34)
	id 1CcZvM-0001A7-0R
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 12:50:24 +1100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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



I have made available a second pre-release of nfs-utils 1.0.7.

It can be downloaded from 
  http://sourceforge.net/project/showfiles.php?group_id=14
or
  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/

This release adds some statd fixes and a couple of other small bug fixes,
and also gets ./configure to complain if libnfsidmap or libevent aren't installed
(unless --disable-nfsv4 is selected).
README also says where to get these libraries from.

I still hope to put this out as a final 1.0.7 before Christmas.
Having lots of people say "Yes, I've tried it, and it works OK" would
make a great Christmas present :-)

NeilBrown 10-December-2004


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
