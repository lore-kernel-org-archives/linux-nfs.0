From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Must statd be running before nfs client makes mounts?
Date: Tue, 17 Sep 2002 09:26:02 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15750.26762.274141.71457@notabene.cse.unsw.edu.au>
References: <20020915225226.GI11002@perlsupport.com>
	<15749.5917.443602.600792@notabene.cse.unsw.edu.au>
	<20020915164956.A21841@lucon.org>
	<15749.7947.298657.940521@notabene.cse.unsw.edu.au>
	<20020916071259.B1149@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17r7Jb-0006D7-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 18:38:11 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <hjl@lucon.org>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Tue, 17 Sep 2002 11:38:02 +1000
To: "H. J. Lu" <hjl@lucon.org>
In-Reply-To: message from H. J. Lu on Monday September 16
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Monday September 16, hjl@lucon.org wrote:
> > 
> > However I don't see a problem with doing this via a sysctl, quite
> > possibly a sysctl under /proc/sys/sunrpc/  (as it is an RPC service).
> > 
> 
> Does it work with sunrpc as module?
> 

Well.....
 modprobe lockd
 echo 3033 > /proc/sys/sunrpc/lockd/udp_port
 echo 3033 > /proc/sys/sunrpc/lockd/tcp_port

should work.

It wouldn't work for module auto-loading, but if you wanted that you
could use the currently available module parameters.

Certainly it would be nice to have a single mechanism that always
worked, but I don't think the kernel infrastructure is up to that at
the moment.  Rusty Russel was talking at the Kernel Summit about
unifying kernel parameters, module parameters and some /proc like
thing (where it be sysctl or /proc or driverfs or....).  It would be
good but it isn't there yet.

That said, it would probably be possible to arrange auto-loading to
trigger off /proc/sys access...  I'm keen to do away with the nfsd
system call altogether.

   echo 32 > /proc/sys/sunrpc/nfsd/nthreads
starts the server,
   echo 0 >  /proc/sys/sunrpc/nfsd/nthreads
stops it.

However this is only a vague idea as yet.

NeilBrown


-------------------------------------------------------
Sponsored by: AMD - Your access to the experts on Hammer Technology! 
Open Source & Linux Developers, register now for the AMD Developer 
Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
