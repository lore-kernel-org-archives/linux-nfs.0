From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: nfs_safe_remove: B/LCK-rses- busy, d_count=2
Date: Thu, 25 Nov 2004 10:06:41 +0100
Message-ID: <20041125090641.GA31716@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CXFaZ-0000gw-UZ
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 01:06:55 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CXFaT-0003sP-Mf
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 01:06:55 -0800
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

I'm starting to see these on 2.4.27 after changing the config from UP
to SMP on a P4 with hyperthreading. At the same time unlink() starts to
report EBUSY to userland:

	unlink /usr/src/c166/tut/B/LCK-rses-: Device or resource busy

Is this a known problem?

I'll move to 2.4.28 anyway.


-- 
Frank


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
