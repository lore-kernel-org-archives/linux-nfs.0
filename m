From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: intermittent errors with AIX server
Date: Fri, 7 Feb 2003 08:50:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D552B1@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18hBiH-0000rO-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Feb 2003 08:50:54 -0800
To: "'Dejan Muhamedagic'" <dejan@hello-penguin.com>
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

hi dejan-

> The Linux boxes are brand new 4-way SMP with 6GB of memory.  
> The errors were there from the beginning, causing an 
> occasional batch job to fail.  This is mainly happening 
> during the night when the load on the server is by far lower 
> than during the day at which time there are ~350 interactive 
> users.  Another oddity is that the failure would always occur 
> on a smallish log file during the create operation.  It is 
> hard to believe that the 6-way DB server would be under 
> serious pressure caused by these batch jobs.  At least that's 
> what I was told by the SAP people here.  With interactive 
> users though, the machine is getting close to the maximum 
> load.  This is why I suspected that there could be an 
> interoperability problem or a bug.
> 
> I've already switched from soft to hard,intr on Linux boxen a 
> few hours ago and hope that will help.  If the errors 
> persist, I will try with the tcp which should eventually fix 
> the problem.

switching to hard will prevent corruption and probably allow
your batch jobs to complete successfully, but i expect you
will continue to see log messages with "timed out..." replaced
by "retrying..." and some indication of when the server
finally responded.

switching to TCP will lengthen the default retransmission
timeout, which may make the log messages disappear too.

the problem may be that the NFS server on your AIX system is
not responding quickly to some CREATE requests.  to tell what's
really going on, you must capture a network trace between the
client and server right as one of these messages occur.

there may be some background job on your AIX server that is
consuming I/O bandwidth and preventing disk accesses from
completing quickly.

> Incidentally, I saw some patches for NFS at 
> http://www.fys.uio.no/~trondmy/src/ which are not present in 
> the official 2.4.20.  The page says "experimental", but some 
> of them seem to pertain to the retransmitting code and SMP 
> race conditions which sounds interesting (in the beginning we 
> had some serious performance problems).  Is it 
> safe/recommendable to use these patches?

i don't see any on that page that is relevant to your problem.
if you determine why the client detects these delays, we might
know a little more about how to fix it.

you might consider number 16 (waitq) if you see applications
on your Linux systems hanging indefinitely while waiting for
an NFS read to complete.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
