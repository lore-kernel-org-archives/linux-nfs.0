From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Mon, 28 Feb 2005 12:33:14 +0100
Message-ID: <20050228113314.GG4822@suse.de>
References: <20050223162808.GB17774@suse.de> <1109176559.10142.4.camel@lade.trondhjem.org> <Pine.LNX.4.58.0502241055521.2188@wombat.indigo.net.au> <1109218999.11180.49.camel@lade.trondhjem.org> <20050224101449.GB11336@suse.de> <1109268742.11433.14.camel@lade.trondhjem.org> <20050225092809.GD15249@suse.de> <1109352644.15877.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5j9Q-0005Bk-Ab
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 03:33:24 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D5j9O-0000mT-D6
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 03:33:24 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109352644.15877.10.camel@lade.trondhjem.org>
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

On Fri, Feb 25, 2005 at 09:30:44AM -0800, Trond Myklebust wrote:
> As far as I know, all vendors use more or less the same scheme for the
> duplicate replay cache.
> ...and yes, the cache is important for TCP connections, since in the
> case of a network partition, the client may still have to resend RPC
> calls.

I understand the theoretical reasons, but I wonder about the practical
value. Any problem that causes retransmits over TCP is non-transient,
otherwise TCP retransmit would simply fix it for us (question - there
doesn't seem to be any code in sunrpc that breaks the connection after
a timeout, major or minor: I think we want that)

To make matters worse, the Linux client is fairly conservative on TCP
reconnects.  TCP connects will time out after 60 seconds, and if the first
reconnect fails, we'll delay future reconnects by another 15 seconds.
In general I believe this is A Good Thing, but this timing pattern will
make sure there's not a shred of valid data left in your retransmit
cache by the time the connection comes back...

Finally, those 120 seconds are the upper limit on the life time of a
cached reply - those 1024 entries in the cache are far from sufficient if
you plan to deal with a few hundred workstations. If a client's
connection is dropped while he's in the middle of a sillyrename, the
server side cache will have been clobbered by the time he comes back.

And this is not theoretical; I've seen this happen in our R&D network.
The client/nfsd thread ratio was too high, so that nfsd started to drop
connections frequently.  That caused interesting failures with silly
renames that were real fun to debug :)

> We are in the process of fixing the whole duplicate replay cache thingy
> in NFSv4.1, but until then, the current broken schemes that rely on RPC
> XID+program number+ipaddress+port number are liable to remain in use.

The most common case (AUTH_SYS) could be fixed by using the aup_machname
field from the credentials (NO, put down that clue stick, don't hit me,
I know it's wrong, ouch...!)

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
