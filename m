From: jason andrade <jason@dstc.edu.au>
Subject: e1000 intel driver bug (which impacts nfs)
Date: Sun, 26 May 2002 23:06:06 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.OSF.4.20.0205262256430.16951-100000@azure.dstc.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from piglet.dstc.edu.au ([130.102.176.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Bxiu-0007GZ-00
	for <nfs@lists.sourceforge.net>; Sun, 26 May 2002 06:06:12 -0700
Received: from azure.dstc.edu.au (azure.dstc.edu.au [130.102.176.27])
	by piglet.dstc.edu.au (8.11.3/8.11.3) with ESMTP id g4QD66r19308
	for <nfs@lists.sourceforge.net>; Sun, 26 May 2002 23:06:06 +1000 (EST)
To: mailto: ;
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


Hi,

I'd spent many hours trying to diagnose and get a fix for what i thought
was a nfs performance bug.  It turns out that i'm 99% sure this has ended
up being a bug in the Intel E1000 driver for the Intel 1000T (or any
Intel Gigabit Ethernet adapter in copper for me anyway).  It's present in
both the older 3.X drivers and the new 4.X driver including 4.1.7 (the
current version)

The symptom/problem is that nfs will simply "hang" - clients will start
to queue requests and we were unable to figure out anything on the server
that would clear this except a reboot.  With some more testing we were
able to verify and reproduce and resolve the problem by stopping nfs,
downing the gigabit interface, unloading the driver, reloading it,
reconfiguring the interface and restarting nfs.  Within 2 minutes the
clients would start responding again.

Someone else has told me he can achieve the same effect with a ifconfig
down, pause, ifconfig up on that interface but this to date has not
worked for me.

I hope this helps anyone else trying to debug mysterious "nfs hangs" under
2.4.X.  It doesn't seem to be tickled unless you are doing quite large
amounts of nfs traffic (we're pushing 1-1.5T a day on this interface)
and it's quite random (i've had a lockup from 4 hours to 10 days after
a reboot)

I am still trying to work out why 8K nfs mounts do not work (UDP) for
us (back to 1K now) and to try 8/16/32K mounts over TCP instead.

Since i now finally have a pure gigE network with a 9000 MTU for the
backend between servers i'm hoping this might work a bit better.



I'd also like to second Seth Vidal's comments about getting Neil, Trond
and co to provide a definitive (revised weekly? monthly?)

"this is what our recommend patchlist is and against which kernels and why"
on the nfs list and/or as part of the faq.

it is increasingly hard to track the major nfs patch contributors to work
out what should be applied and what can wait as well as figuring out the 
patch dependencies.


cheers,

-jason


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
