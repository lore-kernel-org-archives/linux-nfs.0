From: Jordi Prats <jprats@cesca.es>
Subject: reply cache
Date: Mon, 15 Oct 2007 18:53:52 +0200
Message-ID: <47139B20.7070805@cesca.es>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhT5U-00042A-ML
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 09:46:40 -0700
Received: from carlit.cesca.es ([84.88.0.2])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IhT5Y-0000b7-P1
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 09:46:46 -0700
Received: from carlit.cesca.es (localhost [127.0.0.1])
	by carlit.cesca.es (Postfix) with ESMTP id 6789E33056F
	for <nfs@lists.sourceforge.net>; Mon, 15 Oct 2007 18:46:14 +0200 (CEST)
Received: from [213.97.212.36] (36.Red-213-97-212.staticIP.rima-tde.net
	[213.97.212.36])
	by carlit.cesca.es (Postfix) with ESMTP id A34B833013D
	for <nfs@lists.sourceforge.net>; Mon, 15 Oct 2007 18:46:13 +0200 (CEST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,
According to the file fs/nfsd/nfscache.c (line 30 on 2.6.23), reply 
cache is fixed size. Why is this a fixed size cache? Shouldn't be 
relative to the number of nfsd threads? I've a server with this statistics:

rc 0 959398 336415498

By what I've been researching this means: 0 hits, 959398 misses (I 
supose that means something like "recently deleted") and 336415498 not 
in cache (and never has been). Is that right?

Modifying the CACHESIZE to a bigger size do you think it could enhance 
NFS performance by getting some hits on the reply cache?

Thanks!
Jordi

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
