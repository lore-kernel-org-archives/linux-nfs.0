From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: fcntl locks prevent unmounting of underlying filesystem
Date: Sun, 30 May 2004 06:53:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085914384.3079.2.camel@localhost>
References: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
	 <16569.5128.54766.582893@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUNwK-0007iB-4g
	for nfs@lists.sourceforge.net; Sun, 30 May 2004 03:53:16 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUNwJ-0007Yo-Pw
	for nfs@lists.sourceforge.net; Sun, 30 May 2004 03:53:15 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16569.5128.54766.582893@cse.unsw.edu.au>
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

> You need to make sure that lockd gets killed as well.
> Just shutting down nfsd doesn't necessarily kill lockd, as if you have
> any active nfs mounts lockd will stay up for them.
> So, when you have shut down nfsd and before you try to unmount, could
> you check if lockd is still running or not?
> If it is, send it a SIGKILL.  It won't exit, but it should release any
> locks that it is holding.
> 
> If lockd has gone away at this point but locks are still being held,
> then that is a real problem and I will try to look into it.
> 
> NeilBrown

Ahh, Thanks for the info! That does indeed seem to take care of the hold
on the underlying filesystem. I need to do a little more testing to see
how locks are handled, but that at least removes my current logjam.

Cheers!
-- 
Jeff Layton <jtlayton@poochiereds.net>


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
