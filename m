From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 0 of 8 - Introduction
Date: Thu, 25 Mar 2004 12:06:51 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKr-0006bc-V8
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:05 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKr-0007pV-KJ
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:05 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:06:57 +1100
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
 here are a bunch of nfsd patches from the NFSv4 team at umich.
 There are an assortment of minor bug fixes, a new attribute supported
 and, probably most significantly, code to unwrap and wrap requests with
 GSS integrity checking.

 The only places they touch non-"experimental" code are absolutely trivial, 
 so the should be OK to go to Linus.

NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
