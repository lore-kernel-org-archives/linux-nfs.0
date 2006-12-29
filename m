From: "howard chen" <howachen@gmail.com>
Subject: NFS has caching?
Date: Fri, 29 Dec 2006 10:22:07 +0800
Message-ID: <b66ddc900612281822n3df54e44se296b937b58d158@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H07No-0001eE-TR
	for nfs@lists.sourceforge.net; Thu, 28 Dec 2006 18:22:08 -0800
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H07Np-00074R-7x
	for nfs@lists.sourceforge.net; Thu, 28 Dec 2006 18:22:10 -0800
Received: by ug-out-1314.google.com with SMTP id z38so4254296ugc
	for <nfs@lists.sourceforge.net>; Thu, 28 Dec 2006 18:22:07 -0800 (PST)
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

I have around 100 files, currently NFS shared among 5 servers, all
servers access the file quite frequently, e.g. 10 hits per second per
server.

I cannot afford to rync since i want the delay of write as small as
possible, e.g. less than 1 second.


I want to know, since the file will be accessed quite frequent, does
NFS has build-in caching functions that if files are not modified, it
will not try to fetch from the network?


Thanks.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
