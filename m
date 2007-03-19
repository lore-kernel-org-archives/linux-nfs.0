From: Neil Brown <neilb@suse.de>
Subject: rpc.statd  in /sbin or /usr/sbin ??
Date: Mon, 19 Mar 2007 12:14:13 +1100
Message-ID: <17917.58341.502839.29524@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT6S4-0007yS-Ec
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 18:14:20 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HT6S5-0004S9-BZ
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 18:14:22 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id E952E215C2
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 02:14:18 +0100 (CET)
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


Hi,
 I have noticed that some distros like to install statd in /sbin
 rather than /usr/sbin.
 I would like to know why.

 If it is generally agreed that it needs to be in /sbin, then I'll
 change nfs-utils to install it there, but as yet I am unconvinced.

 The only reason I can see for putting statd in /sbin is if it were
 needed for mounting /usr (in cases where /usr is accessed via NFS).

 However in that case (as in the case for an NFS root), I think it is
 appropriate to use the "nolock" flag on the basis that /usr is not
 expected to be share-writeable (i.e. either readonly or
 single-client).  In that case there is no need for locking requests
 to go over the network, and no need for statd to be running before
 /usr is mounted.

 So: can anyone try to convince me that rpc.statd should go in /sbin??

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
