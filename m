From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: [NFS] Does "sync" cause the FUA bit to be set?
Date: Tue, 10 Jun 2008 12:43:13 +0200
Message-ID: <484E5AC1.3020200@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44569 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbYFJKnb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 06:43:31 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K61K2-0005Mq-HI
	for linux-nfs@vger.kernel.org; Tue, 10 Jun 2008 20:43:26 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we have a raid controller serving a file system that we export and
mount with NFS. Depending on the performance profile we chose for the 
raid controller, the are huge performance differences on the NFS client 
side between two profiles. Those two profiles both use write cache and
no journaling, but one honors the FUA bit if it is set, and the other 
profile ignores it (there might be more differences, but the manual
doesn't state any others but the FUA bit).

With the profile ignoring the FUA bit, copying or deleting directories
of e.g. 10M with a about 1000 files is factor 5 faster than with the
profile honoring the FUA bit.

We export with the "sync" option. Does that option maybe set the FUA bit
for all write operations on the NFS server?

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

