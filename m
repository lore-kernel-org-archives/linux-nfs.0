From: Olaf Kirch <okir@suse.de>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 19:13:09 +0100
Message-ID: <20061130181308.GA12747@suse.de>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Astrand <astrand@cendio.se>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpqPJ-0007Vo-9S
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 10:13:14 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GpqPH-00054W-QF
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 10:13:14 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Nov 30, 2006 at 09:58:00AM -0800, Murali Bashyam wrote:
> So this version of unfsd would fork several processes and there would be
> some dispatching process to hand RPC requests to them? I assume these are
> not multiple daemons invoked from the shell. The unfsd version available for
> download seems to be strictly single process, and doesn't seem to be doing
> this.

Search for older suse nfs-server RPMs; that unfsd should have the
support.

And no, there's no dispatching. You start "rpc.nfsd 8" and that
will open a UDP and TCP socket on port 2049, then fork 7 children.
UDP requests are handled by whichever daemon wakes up first.
Same for incoming TCP connects; after the connection is established,
it is handled by one daemon.

> And what happens if multiple processes handle writes on behalf of different
> clients to the same file? I just want to make sure the 8 process server can
> handle what ever the clients do i.e lock, read, write etc. Presumably there
> are inefficiencies, of course such as independent file handle caches within
> each process and not much sharing between them.

unfsd doesn't do NFS file locking, but otherwise the file handle cache
is robust enough to handle even writes.

Anything multithreaded would require writing your own librpc.
There's no way you can make the current RPC code reasonably
efficient wrt multithreading.

I just wish people would leave this old code to Rot In Peace :)

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
