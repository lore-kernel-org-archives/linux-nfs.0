From: Chris Worley <cworley@lnxi.com>
Subject: NFS not negotiating MTU correctly?
Date: 25 May 2004 07:18:46 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085491125.30311.20808.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BScpu-0006bK-4h
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 07:23:22 -0700
Received: from 208.177.141.226.ptr.us.xo.net ([208.177.141.226] helo=localhost.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BScpt-000231-Ou
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 07:23:21 -0700
Received: from localhost (localhost [127.0.0.1])
	by localhost.localdomain (8.11.6/8.11.6) with ESMTP id i4PDIlh16993
	for <nfs@lists.sourceforge.net>; Tue, 25 May 2004 07:18:48 -0600
To: nfs@lists.sourceforge.net
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

I don't know why this is an NFS specific problem (I'd think this would
be part of IP)...

I run 9K MTU's on all my NFS servers and most of my clients.  Great
performance (the servers are also channel bonded... but that's
irrelevant).

Clients that can't do 9K MTU's work with the 9K MTU systems for all
sorts of network tasks, except NFS.

To get NFS to work, I either have to use NFS over TCP, or set my w/rsize
below 1500 bytes.  Both cause performance problems.

In grilling my switch vendor, they assure me that it's the client &
servers job to negotiate properly fragmented packets based on the lessor
MTU.

Chris



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
