From: Julian Cowley <julian@lava.net>
Subject: Re: Re: PATCH - RPC/TCP 2 of 4 - Allow  SO_REUSEADDR for NFS
 sockets
Date: Tue, 13 Aug 2002 15:04:40 -1000 (HST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSI.4.44.0208131439170.7431-100000@malasada.lava.net>
References: <15704.41158.32143.348415@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chuck Lever <cel@citi.umich.edu>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cheesecake.lava.net ([64.65.64.31])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17emah-00079u-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 18:04:51 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15704.41158.32143.348415@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, 13 Aug 2002, Neil Brown wrote:
> [ cc list trimmed ]
> On Monday August 12, cel@citi.umich.edu wrote:
> > it's been suggested that the client should also try reusing the port
> > number when reconnecting over TCP... any thoughts on that?
>
> Why?
> You would not be able to reconnect until the TCP timeout on connection
> re-use has passed, and by that time any benefit that you might gain is
> probably lost.
> How does the TCP timeout compare with the replay-cache timeout??

Just an aside here...

The last time I looked at NFS over TCP on Linux (maybe 6-12 months
ago?), there was a problem related to this.  With my test setup,
I required NFS clients to use a reserved port (the "secure" option
in mountd, although the server was acutally an OpenBSD machine).
After the server would reboot, the Linux client would reconnect,
but it would reconnect using a non-reserved port number even though
the original mount used a reserved port number.  This meant that the
mount would never come back up.

If the client used the same port number, at least it would reconnect in
this case.  A better solution would be to have it keep track of whether
a reserved port was required for the mount or not.



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
