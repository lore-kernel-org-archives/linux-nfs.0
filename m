From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: "Server not responding" after periods of client inactivity
Date: Sat, 30 Jul 2005 16:32:16 +0200
Message-ID: <20050730143216.GA2339@fox>
References: <20050714212514.GA23867@fox> <20050730131031.GA1668@fox> <1122732943.8248.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DysO7-0000V2-OQ
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 07:32:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DysO7-0005CX-AP
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 07:32:31 -0700
Received: from mail-mx6.uio.no ([129.240.10.47])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DysO2-0002Fi-DK
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 16:32:26 +0200
Received: from 231.80-203-47.nextgentel.com ([80.203.47.231] helo=fox.venod.com)
	by mail-mx6.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DysNy-0006dn-22
	for nfs@lists.sourceforge.net; Sat, 30 Jul 2005 16:32:22 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1122732943.8248.13.camel@lade.trondhjem.org>
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

Trond,

> If the server drops the connection, then the client will wait 15 seconds
> before retrying. The reason for this is that client has to assume that
> the server is disconnecting due to congestion issues.
> Note that if congestion really is an issue, your Linux server should
> normally send an error message to the effect of "too many open TCP
> sockets, consider increasing the number of nfsd threads" to your syslog.

Congestion is almost definitely not the case here, since the NFS
server is located in my own home, and is typically only used by one
client at a time.  During these timeouts, it isn't doing anything.
This is why I first thought that the problem was that the server
disks had spun down to save power.

Btw, one thing I haven't tried yet is upgrading to NFSv4.  Do you
think that could help?

> You can fiddle with RPC_REESTABLISH_TIMEOUT if you want to change the 15
> second delay, but I wouldn't recommend this unless you are sure you know
> what you are doing. (FYI, the fixed timeout is, BTW, soon due to be
> replaced with an exponential backoff-based timeout.)
> 
> Otherwise, you should note that the client too will attempt to drop the
> connection after 5 minutes of idle activity on the socket. That should
> normally not lead to a 15 second wait, though.
> If the client fails to disconnect the idle connection, then the server
> will do so after 6 minutes (i.e. ~ 1 minute after the client timeout
> should have occurred).

Hmm, what did you make of the result I got with tcpdump/Ethereal?
(Reposted below for convenience.) It looks like the problem is on
the server side.

  Source  Time  Packets
  ------  ----  -------
  client  0.00  V3 ACCESS Call, FH:0x02120000
  client  0.10  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  0.31  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  0.71  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  1.53  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  3.16  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  6.42  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  7.12  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client  8.52  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  client 11.32  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
  server 15.30  V3 ACCESS Reply

-- 
 Haakon


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
