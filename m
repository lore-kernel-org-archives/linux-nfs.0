From: Brad Barnett <lists@L8R.net>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp
 operation
Date: Mon, 28 Feb 2005 11:20:18 -0500
Message-ID: <20050228112018.34fdeb2b@be.back.l8r.net>
References: <20050226082854.2a496ec3@be.back.l8r.net>
	<20050228100633.GA4822@suse.de>
	<20050228102307.3788a184@be.back.l8r.net>
	<20050228154455.GS4822@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5nd5-00015e-J4
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:20:19 -0800
Received: from l8r.net ([64.26.155.43] ident=aliens)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D5nd4-0002XJ-Sm
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:20:19 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050228154455.GS4822@suse.de>
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

On Mon, 28 Feb 2005 16:44:55 +0100
Olaf Kirch <okir@suse.de> wrote:

> On Mon, Feb 28, 2005 at 10:23:07AM -0500, Brad Barnett wrote:
> > During my tests involving "ls", no one else was accessing the server. 
> > I have noatime set for both client and server mounts.. just in case.
> > 
> > So, there should be no writes for knfsd to do.  There was only one
> > read operation, and that was a "ls -R /nfsmount".
> 
> Well, you were talking about rsync and cp, so it's either reads or
> writes going over the wire, or both.

The rsync or cp operation are on the server.

> 
> > >  -	by tying up all knfsd threads on the server. Try to bump the
> > >  	number of nfsd processes
> > > 
> > >  -	by tying up all RPC slots on the client. Make sure your wsize
> > >  	isn't too big (8k is reasonable)
> > 
> > There is only one client (during my tests), so #1 can't be the case. 
> 
> One NFS client can issue many requests simultaenously, thereby tying
> up more than one nfsd thread.

Yes, but the only activity is a single "ls" on the client.. I don't think
this would use more than one thread.

> 
> > This is what I don't understand.  Why is one single 'ls' on a single
> > client, the only nfs client, brought to a standstill by a single cp or
> > rsync?  It's very weird, and it does not seem to be because of write
> > operations the client is performing.
> 
> Where do these cp and rsync calls occur? From your first message I
> assumed they were on the client, operating on the NFS mounted file
> system.
> 

The cp or rsync are occurring locally on the server.  

Eg

One client has an nfs mount.  It issues an "ls".  The response is instant,
without slowdowns.

I start a long and extensive cp -a process on the nfs server.  Local 'ls'
responses are instant.  Write and read operations are instant (it's a raid
10) on the local box, as well.  However, my single remote client's "ls"
operation changes to a jerky, slow operation.. with upwards of 5 second
pauses in reads.








-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
