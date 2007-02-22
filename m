From: Neil Brown <neilb@suse.de>
Subject: ANNOUNCE: nfs-utils 1.0.11
Date: Thu, 22 Feb 2007 16:17:51 +1100
Message-ID: <17885.10111.791755.714451@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HK6Lm-0002ut-Bt
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 21:18:40 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HK6Lm-0002aj-Cu
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 21:18:39 -0800
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 3BF08124E1
	for <nfs@lists.sourceforge.net>; Thu, 22 Feb 2007 06:18:37 +0100 (CET)
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



I have just made a release of  nfs-utils 1.0.11

It can be downloaded from 
  http://sourceforge.net/project/showfiles.php?group_id=14
or
  cc=country.
  http://www.{cc}kernel.org/pub/linux/utils/nfs/
or
  git://linux-nfs.org/nfs-utils

This should be the last 1.0 release.
I hope to do a 1.1.0 soonish that flips the default for subtree_check
to no_subtree_check, and removes "rpc.lockd" which is not needed by
any but two very old kernel releases.

There are various bugfixes and improvements.  Read through the log at 

   http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=log

for details.

NeilBrown 22-Feb-2007


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
