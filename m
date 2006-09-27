From: "Bob Fozard " <Bob.Fozard@datadomain.com>
Subject: Re: client write ordering
Date: Wed, 27 Sep 2006 12:18:45 -0700
Message-ID: <3A8D2969972400448F9C908CFE890D9503A34786@exchange1.DataDomain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSevi-0001mR-Ib
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 12:18:50 -0700
Received: from mail2.datadomain.com ([207.47.14.83] helo=fred.datadomain.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSevi-0007ed-2j
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 12:18:51 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Trond,

I very much appreciate your responses.  While I will experiment with
/proc/sys/vm/dirty_ratio to understand its effects, what I see as the
issue here is not so much _when_ the client decides to start flushing,
but _how_ it goes about flushing.  Do you have some idea as to how the
vm sorts pages for flushing?  Is it intended to mimic the order in which
the application wrote them to any extent?  Surely its not random, but
clearly it can take large jumps from time to time.  Even a simple LRU
algorithm would give desirable behavior.

Bob
  

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
Sent: Wednesday, September 27, 2006 11:15 AM
To: Bob Fozard 
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] client write ordering

On Wed, 2006-09-27 at 10:33 -0700, Bob Fozard wrote:
> You've hit it on the head.  Yes, the server caches until memory 
> pressure forces a flush, and yes elevator algorithms are employed.  
> The issue here is that >1GB is a fairly hefty slice of cache to 
> provide a single file in order to mask the re-ordering affects from 
> the client.  Again, it used to be a few MB, now we're seeing >1GB, 
> what's going on in the client?  BTW, the server I'm working with is
not Linux, its our own.

In 2.6 kernels the client will follow standard close-to-open rules for
when to flush the data to disk.

IOW: it will cache writes until one of the following conditions happen:

 - The application close()s the file
 - The client's VM decides to reclaim memory
 - The application sets/frees a BSD or POSIX lock.

This is pretty standard behaviour for almost all NFS clients out there
on the market (apart from Linux-2.4).

In Linux 2.4 there was no way for the VM to indicate to NFS that it
needed to reclaim memory, and so we had to have a hard (completely
arbitrary) limit of 256 outstanding read/write requests per mount point.
Upon hitting that limit, the client would flush the writes.

Note that even in 2.6 kernels, you can fiddle about with the values of
the global dirty page soft limit /proc/sys/vm/dirty_ratio in order to
tell the VM to start flushing out writes at an earlier time (see
Documentation/filesystems/proc.txt).

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
