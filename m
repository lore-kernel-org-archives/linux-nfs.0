From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 0/22] Introduction to lockd patches
Date: Sat, 5 Aug 2006 15:06:47 +0200
Message-ID: <20060805130647.GA8011@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrf-00078h-Qi
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:52 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lre-0000Sx-PJ
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:52 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id C0AED1FF4C
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:47 +0200 (CEST)
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

Subject: Introduction to lockd patches

This set of patches does various cleanups in the lockd code, adds the
ability to use the client host name instead of the IP address (which
is something the HA folks asked us for), and the ability to switch
between the user space rpc.statd and a new kernel statd implementation.

The latter needs a separate user space utility named sm-notify that
sends out the NSM_NOTIFY calls at boot. The utility is available
from ftp://ftp.lst.de/pub/people/okir/sm-notify.

This code has been in several Suse releases. I forward ported this to
2.6.18-rc3 and made sure it compiles. I have *not* done any testing yet,
as I ran out of time (I'm leaving for vacation tomorrow). I wanted to
post this code for your review nevertheless, since I promised Steve
Dickson I'd do that :)

If the kernel statd code is too controversial, I'm fine with keeping
that in the suse tree a little longer. But I do believe it makes things
a lot easier for users (one configuration mistake less); and it also
makes the code simpler (no more funky upcalls to user land).

Note that both the use of hostnames instead of addresses, and the use
of kernel statd, are switchable, and default to off.

Olaf

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
