From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: Client tuning
Date: Wed, 11 Dec 2002 16:10:20 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.40.0212111544400.6400-100000@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a.smtp-out.sonic.net ([208.201.224.38])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MHrq-0007hn-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 17:10:22 -0800
To: Jose Celestino <japc@co.sapo.pt>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Jose Celestino wrote:
>
> I have the option of choosing between NFSv2/v3 and TCP/UDP and the
> freedom to fully configure/reconfigure the client boxes. Any thoughs on
> what I might tweak and look for? Any experiences on this?
>

First off I would recommend subscribing to and staying subscribed to this
list. If you use linux NFS (as client and/or server) then this list will
be invaluable.

The UDP/TCP question should probably be in the FAQ, as it has come up
many times before on the list. If you have a mismatch
in network speeds (e.g. 1000BaseT on server and 100BaseT on client) TCP
will give you better speeds. However, UDP support has been more
historically reliable in the linux kernel, and more widely used.

I wouldn't recommend using TCP NFS client before 2.4.20, out of the box,
2.4.20 is stable for me so far.

You can try tweaking mount(8) parameters, kernel patches (applying various
patches from Trond's site, at http://www.fys.uio.no/~trondmy/src), and
even vendor kernel RPM's (most vendors include some subset of Trond's
patches).

But, mostly you will need to run tests with your own setup to determine
what is the most stable and best-performing combination of kernel and
mount parameters. And if you find bugs, report them to the list so they
can be fixed in future versions.


cheers,
andrew



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
