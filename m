From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: fcntl locks prevent unmounting of underlying filesystem
Date: Sun, 30 May 2004 08:51:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16569.5128.54766.582893@cse.unsw.edu.au>
References: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkYQ-0006gP-3y
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:06 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkYP-0006hJ-8Z
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:05 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <jtlayton@poochiereds.net>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Sun, 30 May 2004 08:51:59 +1000
To: Jeffrey Layton <jtlayton@poochiereds.net>
In-Reply-To: message from Jeffrey Layton on Wednesday May 26
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

On Wednesday May 26, jtlayton@poochiereds.net wrote:
> I've seem to have run across a problem with NFS and fcntl locks. I'm
> trying to implement a HA-NFS solution using heartbeat, DRBD, LVM2, etc.
> I'm running the following:
> 
> 2.6.6 kernel
> nfs-kernel-server and nfs-common 1.0.6-3 (debian packages)
> 
> The underlying filesystem is reiserfs. Essentially what I'm seeing is
> that when I try to shut down NFS and unmount the filesystem for a
> failover, I'm unable to unmount if I have an fcntl lock on the file.

You need to make sure that lockd gets killed as well.
Just shutting down nfsd doesn't necessarily kill lockd, as if you have
any active nfs mounts lockd will stay up for them.
So, when you have shut down nfsd and before you try to unmount, could
you check if lockd is still running or not?
If it is, send it a SIGKILL.  It won't exit, but it should release any
locks that it is holding.

If lockd has gone away at this point but locks are still being held,
then that is a real problem and I will try to look into it.

NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
