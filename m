From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: fcntl locks prevent unmounting of underlying filesystem
Date: Thu, 27 May 2004 10:27:16 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085668036.6111.2.camel@tesla.mmt.bellhowell.com>
References: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTLqq-0000Et-DB
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 07:27:20 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTLqq-0004F0-1V
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 07:27:20 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id 27FB1E485
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 10:27:11 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 13058-08 for <nfs@lists.sourceforge.net>;
	Thu, 27 May 2004 10:27:10 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 3A752AED2
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 10:27:10 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
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

FWIW, I've also been able to replicate this problem on the 2.4 kernels
as well. I'm unable to unmount the underlying filesystem of the NFS
server until the POSIX locks that the clients hold have been released.
Needless to say, this is not good for a HA-NFS server, since it prevents
me from reliably failing over. How have others dealt with this problem?
Or perhaps I don't have something configured correctly?

Any help or insight would be much appreciated...

-- Jeff




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
