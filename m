From: Dejan Muhamedagic <dejan@hello-penguin.com>
Subject: Re: intermittent errors with AIX server
Date: Fri, 7 Feb 2003 16:51:49 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030207165149.A18840@smp.colors.kwc>
References: <6440EA1A6AA1D5118C6900902745938E07D552B0@black.eng.netapp.com>
Reply-To: Dejan Muhamedagic <dejan@hello-penguin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pinguin13.kwc.at ([193.228.81.158] helo=mail.hello-penguin.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18hAng-0005QZ-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Feb 2003 07:52:25 -0800
Received: from dejan by mail.hello-penguin.com with local (Exim 3.33 #3)
	id 18hAn7-00053O-00
	for nfs@lists.sourceforge.net; Fri, 07 Feb 2003 16:51:49 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D552B0@black.eng.netapp.com>
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

Hi Charles,

There are two differences between the AIX client and the Linux
clients: AIX mounted the NFS fs with tcp and hard options.  Right,
the Linux boxes should mount with the hard option too.  The
retransmit options on the Linux boxes were default (.7sec times
3).

The Linux boxes are brand new 4-way SMP with 6GB of memory.  The
errors were there from the beginning, causing an occasional batch
job to fail.  This is mainly happening during the night when the
load on the server is by far lower than during the day at which
time there are ~350 interactive users.  Another oddity is that the
failure would always occur on a smallish log file during the
create operation.  It is hard to believe that the 6-way DB server
would be under serious pressure caused by these batch jobs.  At
least that's what I was told by the SAP people here.  With
interactive users though, the machine is getting close to the
maximum load.  This is why I suspected that there could be an
interoperability problem or a bug.

I've already switched from soft to hard,intr on Linux boxen a few
hours ago and hope that will help.  If the errors persist, I will
try with the tcp which should eventually fix the problem.

Incidentally, I saw some patches for NFS at
http://www.fys.uio.no/~trondmy/src/ which are not present in the
official 2.4.20.  The page says "experimental", but some of them
seem to pertain to the retransmitting code and SMP race conditions
which sounds interesting (in the beginning we had some serious
performance problems).  Is it safe/recommendable to use these
patches?

Cheers!

Dejan

On Fri, Feb 07, 2003 at 06:51:07AM -0800, Lever, Charles wrote:
> hello dejan-
> 
> > I've got a problem I'm not sure how to tackle.  Few times a 
> > day both Linux NFS clients report:
> > 
> > Feb  6 13:16:32 lx kernel: nfs: server aix not responding, 
> > timed out Feb  6 16:18:17 lx kernel: nfs: server aix not 
> > responding, timed out Feb  7 04:13:08 lx kernel: nfs: server 
> > aix not responding, timed out Feb  7 07:19:59 lx kernel: nfs: 
> > server aix not responding, timed out
> > 
> > Otherwise, there are no problems reported.  No errors on the 
> > network i/f either.  The third NFS client is an AIX box and 
> > it has been running flawless for a few years.  It seems like 
> > the load on the network at the time when error occurs is not 
> > particularly high.
> > 
> > The NFS is v3 over UDP with options 
> > soft,rsize=8192,wsize=8192. The NFS server is AIX and it's 
> > running the Oracle RDBMS.  The three NFS clients are running 
> > SAP apps.  The network is Gb ethernet and there are no 
> > network errors.  AIX is 4.3.3 and Linux kernel is 2.4.20-ac2.
> 
> first there are significant risks when using UDP and soft
> with a short retransmit timeout.  even if your workload is
> entirely reads, these timeouts can result in corrupt data
> appearing in your client's data cache.  the only way to get
> rid of the corruption is to unmount/mount, or to lock/unlock
> the corrupt file (or another client can touch the file).  if
> the client then writes the corrupt data back to the server,
> the corruption appears in the permanent file.
> 
> that's just with a read workload.  if your workload is write
> intensive, a soft timeout on a write request results in data
> not appearing in the permanent version of the file.  this
> may or may not be reported in a timely manner to the 
> applications that are using the file.  again, the end
> result is corruption in the permanent file.
> 
> if you insist on using soft, then you should switch to TCP,
> use a very long retransmit timeout, or use a large retrans-
> mit retry count.  that will increase the time the client
> waits before giving up on any particular request, and decrease
> the window of probability that a soft timeout will occur.
> 
> second, please tell us a few vital pieces of information.
> are the mount options on your AIX client the same as on your
> Linux clients?  is the retransmit timeout the same?
> 
> is the server itself very busy when these timeouts occur?
> 
> did this recently start occurring, or has it always occurred
> as long as you've had Linux clients?
> 
> 
> -------------------------------------------------------
> This SF.NET email is sponsored by:
> SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
> http://www.vasoftware.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
