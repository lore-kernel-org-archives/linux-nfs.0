From: Erik Hensema / HostingXS Internet Services <hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Subject: [NFS] Forcefully resetting a lock
Date: Wed, 16 Apr 2008 11:17:24 +0200
Message-ID: <200804161117.24734.hensema@hostingxs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39129 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101AbYDPJRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 05:17:48 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jm3ly-0004pR-JT
	for linux-nfs@vger.kernel.org; Wed, 16 Apr 2008 19:17:46 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

Sometimes a file lock gets stuck. Is there any way on either server or 
client to obtain a list of locks? Or a list of processes/clients 
locking a particular file?
And the million dollar question: is it possible to forcefully remove a 
lock?

I'm using NFSv4 on Linux 2.6.18 (server and client).

Met vriendelijke groet,


Erik Hensema
-- 
HostingXS
eXcellent Service

Telefoon: 024 - 324 91 77
E-mail:   hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org
Website:  http://www.hostingxs.nl/

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

