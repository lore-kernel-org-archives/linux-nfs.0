From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Wed, 07 Aug 2002 10:19:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D515689.DE925A02@attbi.com>
References: <Pine.LNX.4.44.0208071142060.1462-100000@duran.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
 	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc01.attbi.com ([204.127.202.61])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cUOx-0002q8-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 10:15:15 -0700
To: Rex Dieter <rdieter@math.unl.edu>
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

Rex Dieter wrote:
> 
> On Wed, 7 Aug 2002, Trond Myklebust wrote:
> 
> >
> > If you are getting that performance with v3, then it does indeed sound
> > like a bug somewhere. Try with a stock 2.4.19 kernel instead...
> 
> I just tested things with a test kernel (2.4.18-7) from redhat, and it
> sync write speeds were again way up there.  Problem fixed, as far as I'm
> concerned... hopefully, they'll release an errata soon.
> 
> --
> Rex A. Dieter                   rdieter@unl.edu
> Computer System Administrator   http://www.math.unl.edu/~rdieter/
> Mathematics and Statistics
> University of Nebraska Lincoln

and

"Lever, Charles" wrote:
> 
> hi jeff-
> 
> >    I remember reading on the list about the terrible NFS
> > performance of the latest RH kernels. Would someone
> > care to summarize this for me (UDP or TCP, etc.)? Also,
> > does anyone have any rough estimates of the performance
> > hit?
> 
> if you are referring to bad NFS client performance, this
> is due to a bug in the Linux IP fragmentation logic which
> causes it to send part of a fragmented packet, and drop
> the rest, if it runs out of socket buffer space during
> the fragmentation process.
> 
> thus it only affects NFS over UDP.
> 
> there is an easy workaround:  enlarge the size of the
> RPC transport socket's buffers.  see the NFS FAQ for
> instructions.
> 
> a bug was reported in the eepro100 driver too, and that
> may have some effect on client performance.
> 

So if this is one and the same bug, then enlarging the transport
socket size is actually discussed in the performance section
of the howto documents (section 5.7) at 
http://nfs.sourceforge.net/nfs-howto/performance.html#MEMLIMITS

Tom
--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
