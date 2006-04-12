From: Neil Brown <neilb@suse.de>
Subject: ANNOUNCE: nfs-utils 1.0.8 (final)
Date: Wed, 12 Apr 2006 13:19:44 +1000
Message-ID: <17468.29136.672049.677855@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTVu3-0001g6-K9
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 20:20:23 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FTVu2-0002yL-8e
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 20:20:23 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 9A85BF074
	for <nfs@lists.sourceforge.net>; Wed, 12 Apr 2006 05:20:17 +0200 (CEST)
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



I have made a final release of  nfs-utils 1.0.8

It can be downloaded from 
  http://sourceforge.net/project/showfiles.php?group_id=14
or
  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/

It is over a year since the last release of nfs-utils and there are 
quite a lot of changes in 1.0.7. Most of these are bug fixes and minor
functionality improvements.  NFSv4 and GSS support has seen a lot
of work and should be more stable.

Possibly the most visible change is a rework of how makefiles are managed.

This release requires libnfsidmap, libevent, and a krb5 instalation to compile
properly.  If these are not available, and you don't require nfsv4 or gss support
configure with "--disable-nfsv4 --disable-gss".
See README for more details.

Have a merry, and safe, Easter.

NeilBrown 12-April-2006


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
