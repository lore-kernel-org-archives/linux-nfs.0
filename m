From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: Linux' NFS locking b0rken?
Date: Thu, 27 May 2004 12:24:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085675096.7390.7.camel@tesla.mmt.bellhowell.com>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov>
	 <1085523068.12612.58.camel@lade.trondhjem.org>
	 <20040526075058.GA7463@suse.de>
	 <1085587441.3763.4.camel@lade.trondhjem.org>
	 <20040527161412.GA19288@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTNgj-0000mi-TF
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 09:25:01 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BTNgh-00062V-N0
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 09:24:59 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id 30F39E4A8
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 12:24:51 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 17294-07 for <nfs@lists.sourceforge.net>;
	Thu, 27 May 2004 12:24:50 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 699FAE439
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 12:24:50 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040527161412.GA19288@suse.de>
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

Just for posterity, the Solaris manpage for flock(3UCB) says:

"The compatibility version of flock() has been implemented on top of 
fcntl(2) locking."

----------------

My guess is that if Linux were to adopt a similar scheme it would likely
not break much, if anything...

But what do I know? ;-)

-- Jeff




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
