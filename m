From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 0 of 5 - Introduction
Date: Fri, 06 Feb 2004 16:13:17 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040206161050.27799.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoyJ3-0008IB-Td
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:33 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AoyJ3-0004gk-Hf
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 6 Feb 2004 16:13:20 +1100
To: Andrew Morton <akpm@osdl.org>
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

Hi Andrew,
 Here are 5 nfsd related patches that are suitable for 2.6.3.

 The first three fix some subtle bugs in the authentication cache code.
 The second two have been sitting in my inbox since september :-(
 One converts the stats files to seq_file and the other cleans up
 some #if DEBUG code.

Thanks,
NeilBrown


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
