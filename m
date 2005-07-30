From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "Server not responding" after periods of client
	inactivity
Date: Sat, 30 Jul 2005 10:15:43 -0400
Message-ID: <1122732943.8248.13.camel@lade.trondhjem.org>
References: <20050714212514.GA23867@fox>  <20050730131031.GA1668@fox>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dys8H-0008KK-EW
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 07:16:09 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dys8F-0003MA-Ux
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 07:16:09 -0700
Received: from mail-mx2.uio.no ([129.240.10.30])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1Dys84-0000Ym-No
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 16:15:56 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050730131031.GA1668@fox>
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

lau den 30.07.2005 Klokka 15:10 (+0200) skreiv Haakon Riiser:
> I have now tried this with another NFS client (Fedora Core 4)
> connected to the NFS server simultaneously with client used
> in the below problem report.  The same problem happens on
> the new client as well, even when the other client has just
> experienced the hang.
> 
> That is, after the stalled NFS operation completes on client A,
> it is still possible to observe the same problem on client B.
> It looks to me like this is caused by the server disconnecting idle
> clients, and when a new request suddenly occurs, it takes a while
> before the server manages to resurrect the connection.  I tried
> adding a cron job that does 'ls -l /NFS-MOUNT-POINT >/dev/null'
> every few minutes, but surprisingly, that didn't keep the the
> connection alive.  Is this because of client side caching?  Is there
> anything I can do?  These hangs are getting very annoying; it
> would be great if I could somehow change the idle timeout.

If the server drops the connection, then the client will wait 15 seconds
before retrying. The reason for this is that client has to assume that
the server is disconnecting due to congestion issues.
Note that if congestion really is an issue, your Linux server should
normally send an error message to the effect of "too many open TCP
sockets, consider increasing the number of nfsd threads" to your syslog.
You can fiddle with RPC_REESTABLISH_TIMEOUT if you want to change the 15
second delay, but I wouldn't recommend this unless you are sure you know
what you are doing. (FYI, the fixed timeout is, BTW, soon due to be
replaced with an exponential backoff-based timeout.)

Otherwise, you should note that the client too will attempt to drop the
connection after 5 minutes of idle activity on the socket. That should
normally not lead to a 15 second wait, though.
If the client fails to disconnect the idle connection, then the server
will do so after 6 minutes (i.e. ~ 1 minute after the client timeout
should have occurred).

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
