From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Fri, 3 Dec 2004 16:23:14 +1100
Message-ID: <16815.63554.437489.308079@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ca5uc-0003DB-Cu
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 21:23:22 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ca5uZ-0001kI-O4
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 21:23:21 -0800
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 3 Dec 2004 16:23:14 +1100
Received: from neilb by notabene.cse.unsw.edu.au with local (Exim 4.34)
	id 1Ca5uU-0003WC-Eq
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 16:23:14 +1100
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



I have made available a pre-release of nfs-utils 1.0.7.

It can be downloaded from 
  http://sourceforge.net/project/showfiles.php?group_id=14
or
  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/


The reason for the pre-release is that there are a number of changes that
I haven't had a chance to test properly, and some that I am not in a position
to test.

There are an assortment of bug-fixes, some support for fail-over clustering,
and support for 'gss' authentication.

I would appreciate it if people could check that it compiles and works for them,
and let me know the success rate.

I hope to put this out as a final 1.0.7 before Christmas.  Having lots of people 
say "Yes, I've tried it, and it works OK" would make a great Christmas present :-)

NeilBrown 03-December-2004


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
