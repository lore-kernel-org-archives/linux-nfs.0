From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: ANNOUNCE: nfs-utils 1.0.7 (final)
Date: Fri, 17 Dec 2004 15:23:12 +1100
Message-ID: <16834.24368.869308.53649@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cf9eB-0001NJ-Se
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 20:23:19 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cf9e7-0004ve-Ux
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 20:23:19 -0800
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 17 Dec 2004 15:23:13 +1100
Received: from neilb by notabene.cse.unsw.edu.au with local (Exim 4.34)
	id 1Cf9e4-0002Sb-Sz
	for nfs@lists.sourceforge.net; Fri, 17 Dec 2004 15:23:12 +1100
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


I have made a final release of  nfs-utils 1.0.7.

It can be downloaded from 
  http://sourceforge.net/project/showfiles.php?group_id=14
or
  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/

It is over a year since the last release of nfs-utils and there are 
quite a lot of changes in 1.0.6. These include:

 - nfsv4 support
 - gss authnetication support
 - callouts from statd and mountd to support high-availabilty clusters
 - an assortment of bug fixes and minor improvements.

This release requires libnfsidmap, libevent, and a krb5 instalation to compile
properly.  If these are not available, and you don't require nfsv4 or gss support
configure with "--disable-nfsv4 --disable-gss".
See README for more details.

Have a merry, and safe, Christmas.

NeilBrown 17-December-2004


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
