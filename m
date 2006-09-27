From: "Bob Fozard " <Bob.Fozard@datadomain.com>
Subject: client write ordering
Date: Wed, 27 Sep 2006 09:26:51 -0700
Message-ID: <3A8D2969972400448F9C908CFE890D9503A34783@exchange1.DataDomain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GScFI-0003Cz-AU
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 09:26:52 -0700
Received: from mail2.datadomain.com ([207.47.14.83] helo=fred.datadomain.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GScFI-0006cw-0i
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 09:26:53 -0700
Received: from datadomain.com (exchange1.datadomain.com [192.168.244.205])
	by fred.datadomain.com (8.13.1/8.13.1) with ESMTP id k8RGQpNQ025203
	for <nfs@lists.sourceforge.net>; Wed, 27 Sep 2006 09:26:51 -0700
To: <nfs@lists.sourceforge.net>
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

Using the NFSv3 client on Redhat's 2.6.15 x86, I've noticed that when
writing large sequential files, it will sometimes send write RPC's to
the server with very large gaps (> 1GB) in the file offset (i.e. my nice
sequential writes are being occasionally randomized in a big way).
While the ordering of write RPC's on the wire have often been noticed to
be shuffled somewhat in earlier (e.g. 2.4) kernels, they were typically
within a few MB's of each other at most.  The large gaps in
sequentiality we're seeing with 2.6 are pretty undesirable to our server
(and I dare say they're undesirable in general) and I'm searching for
some insight as to how I might be able to bring back the 2.4 behavior,
or whether this may be fixed in newer code.   BTW, we've noticed this
with earlier FC4 versions also (e.g. 2.6.11), but has not been
reproduced when running the x86_64 versions of the same kernels.  It
should be noted that the x86 client has 3GB RAM, the x86_64 box has 4GB.
Any suggestions are gratefully appreciated.
 
Bob

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
